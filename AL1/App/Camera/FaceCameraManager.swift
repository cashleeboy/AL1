//
//  FaceCameraManager.swift
//  AL1
//
//  Created by cashlee on 2025/12/26.
//

import AVFoundation
import UIKit

enum CameraPermissionStatus {
    case authorized    // 已授权
    case denied        // 用户拒绝
    case restricted    // 受限（如家长控制）
    case notDetermined // 尚未请求
}

class FaceCameraManager: NSObject {
    // 状态回调
    var onImageCaptured: ((UIImage) -> Void)?
    var onError: ((String) -> Void)?
    // 新增：权限状态回调，方便 UI 弹出引导弹窗
    var onPermissionDenied: (() -> Void)?
    
    private let captureSession = AVCaptureSession()
    private lazy var photoOutput: AVCapturePhotoOutput = {
        let output = AVCapturePhotoOutput()
        return output
    }()
    
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "com.camera.sessionQueue")
    // 记录当前活跃的摄像头位置，默认为前置
    private var currentPosition: AVCaptureDevice.Position = .front
    // 灵活配置方向：默认设为横屏右
    var currentVideoOrientation: AVCaptureVideoOrientation = .landscapeRight
    // 新增：旋转协调器
    private var rotationCoordinator: Any? // 使用 Any 兼容低版本
    private var rotationObservation: NSKeyValueObservation?
    
    // MARK: - 权限检查
    private func checkPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            // 第一次申请权限
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .denied, .restricted:
            completion(false)
            onPermissionDenied?()
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - 初始化设置
    func prepareCamera(in view: UIView, initialPosition: AVCaptureDevice.Position = .front, orientation: AVCaptureVideoOrientation = .landscapeRight) {
        self.currentPosition = initialPosition
        self.currentVideoOrientation = orientation
        
        checkPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.sessionQueue.async {
                    // 如果已经配置过且正在运行，只需确保预览层在正确的视图上
                    if self.captureSession.isRunning {
                        DispatchQueue.main.async {
                            self.setupPreviewLayer(in: view)
                        }
                        return
                    }
                    self.setupSession(in: view, position: initialPosition)
                }
            } else {
                self.onError?("Sin permiso de cámara...")
            }
        }
    }
    
    func startRunning() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            // 只有当没有正在进行的配置事务时，isRunning 的检查和启动才是安全的
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopRunning() {
        if captureSession.isRunning {
            sessionQueue.async { self.captureSession.stopRunning() }
        }
    }
    
    deinit {
        print("*** deinit")
    }
    
    // MARK: - 拍照功能
    func takePhoto() {
        guard captureSession.isRunning else {
            onError?("La cámara no está activa.")
            return
        }
        let settings = AVCapturePhotoSettings()
        // 确保开关匹配
        settings.isHighResolutionPhotoEnabled = photoOutput.isHighResolutionCaptureEnabled
        if let photoConnection = photoOutput.connection(with: .video) {
            if #available(iOS 17.0, *), let coordinator = rotationCoordinator as? AVCaptureDevice.RotationCoordinator {
                // 使用拍照建议角度
                let captureAngle = coordinator.videoRotationAngleForHorizonLevelCapture
                if photoConnection.isVideoRotationAngleSupported(captureAngle) {
                    photoConnection.videoRotationAngle = captureAngle
                }
            } else {
                // 旧版本适配
                photoConnection.videoOrientation = self.currentVideoOrientation
            }
            
            if photoConnection.isVideoMirroringSupported {
                photoConnection.isVideoMirrored = (currentPosition == .front)
            }
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
     
}

extension FaceCameraManager
{
    private func setupSession(in view: UIView, position: AVCaptureDevice.Position) {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // 1. 设置输入
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else {
            onError?("No se puede acceder a la cámara.")
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // 2. 设置输出
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            // 必须先开启 Output 的开关，Settings 里的开关才有效
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        // 获取当前设备引用用于协调器
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else { return }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.main.async {
            self.setupPreviewLayer(in: view)
            // 在预览层创建后，启动协调器
            self.setupRotationCoordinator(for: device, previewLayer: self.videoPreviewLayer!)
            self.startRunning()
        }
    }
    
    private func setupPreviewLayer(in view: UIView) {
        // 如果已经存在预览层，更新 frame 即可
        if let existingLayer = self.videoPreviewLayer {
            existingLayer.frame = view.bounds
            updatePreviewOrientation()
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        self.videoPreviewLayer = previewLayer
        
        updatePreviewOrientation()
        updatePreviewMirroring()
    }
    
    // 关键逻辑：根据当前摄像头位置决定预览是否镜像
    private func updatePreviewMirroring() {
        guard let connection = videoPreviewLayer?.connection else { return }
        if connection.isVideoMirroringSupported {
            // 必须关闭自动调整，手动设置才能生效
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = (currentPosition == .front)
        }
    }
    
    private func updatePreviewOrientation() {
        guard let connection = videoPreviewLayer?.connection else { return }
        if #available(iOS 17.0, *) {
            // 0 度通常是传感器的原生方向（Landscape）。
            // 要让图像在竖屏(Portrait)下看起来是正的，通常需要旋转 90 度。
            let angle: CGFloat
            switch self.currentVideoOrientation {
            case .portrait:
                angle = 90
            case .portraitUpsideDown:
                angle = 270
            case .landscapeRight:
                angle = 0  // 原生横向
            case .landscapeLeft:
                angle = 180
            @unknown default:
                angle = 90
            }
            if connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        } else {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = self.currentVideoOrientation
            }
        }
    }
    
    //
    private func setupRotationCoordinator(for device: AVCaptureDevice, previewLayer: AVCaptureVideoPreviewLayer) {
        if #available(iOS 17.0, *) {
            // 创建协调器
            let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
            self.rotationCoordinator = coordinator
            // 监听建议的角度变化
            rotationObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { [weak self] _, change in
                guard let self = self, let newAngle = change.newValue else { return }
                DispatchQueue.main.async {
                    self.applyRotationAngle(newAngle)
                }
            }
        }
    }
    private func applyRotationAngle(_ angle: CGFloat) {
        guard let connection = videoPreviewLayer?.connection else { return }
        if #available(iOS 17.0, *) {
            if connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        }
    }
}

// MARK: - 拍照回调处理
extension FaceCameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            onError?(error.localizedDescription)
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        onImageCaptured?(image)
    }
}
