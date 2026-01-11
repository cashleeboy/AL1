//
//  ShootCoverViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit
import AVFoundation

class ShootCoverViewController: UIViewController
{
    // MARK: - Camera
    private let faceCameraManager = FaceCameraManager()
    
    private lazy var cameraManager: CameraManager = {
        var cameraManager = CameraManager()
        cameraManager.shouldKeepViewAtOrientationChanges = true
        cameraManager.shouldRespondToOrientationChanges = true
        return cameraManager
    }()
    
    // 白色拍照区域
    private lazy var cameraPreviewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    // 2. 初始化黄色角视图
    private lazy var cornerDecoratorView = CameraCornerView()
    
    private var croppedImage: UIImage?
    private lazy var coverImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.isHidden = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let originOrientation: ScreenRotator.Orientation?
    init(orientation: ScreenRotator.Orientation, originOrientation: ScreenRotator.Orientation?) {
        self.originOrientation = originOrientation
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // back item
    private lazy var backBarItem = createBackBarItem()
    private lazy var titleLabel = createTitleLabel()
    private lazy var cameraButton = createCameraButton()
    
    private lazy var donwButton = createDoneButton()
    private lazy var cancelButton = createCancelButton()
    
    var onFinishPhoto: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "0x656565")
        navigation.bar.isHidden = true
     
        setupUI()
        setupFaceCameraManager()
    }
    
    private func setupFaceCameraManager() {
        // 1. 设置错误回调
        faceCameraManager.onError = { [weak self] msg in
            print("相机错误: \(msg)")
        }
        
        // 2. 设置权限拒绝回调
        faceCameraManager.onPermissionDenied = { [weak self] in
            // 这里可以弹出 Alert 引导用户去设置
        }
        
        // 3. 设置拍照成功回调
        faceCameraManager.onImageCaptured = { [weak self] image in
            guard let self = self else { return }
            croppedImage = image
//            coverImageView.isHidden = false
//            coverImageView.image = image
            
            faceCameraManager.stopRunning()
//            let croppedImage = image.cropImage(to: previewLayer)
//            print("拍照完成：\(croppedImage.size)")
//            onFinishPhoto?(croppedImage)
//            self.capturedImage = image
        }
        
        // 4. 启动预览
        faceCameraManager.prepareCamera(in: cameraPreviewContainer, initialPosition: .back)
    }
    
    private func setupUI() {
        view.addSubview(backBarItem)
        backBarItem.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(2)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.size.equalTo(35)
        }
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width).multipliedBy(0.5)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBarItem)
        }
        
        view.addSubview(cameraButton)
        cameraButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-5)
            make.centerY.equalToSuperview()
            make.size.equalTo(70)
        }
        
        // 白色拍照区域
        view.addSubview(cameraPreviewContainer)
        view.addSubview(coverImageView)

        view.addSubview(cornerDecoratorView)
        cameraPreviewContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.width.equalTo(view.snp.width).multipliedBy(0.55)
            make.height.equalTo(cameraPreviewContainer.snp.width).multipliedBy(0.60)
        }
        coverImageView.snp.makeConstraints { make in
            make.edges.equalTo(cameraPreviewContainer)
        }
        
        cornerDecoratorView.snp.makeConstraints { make in
            let offset = cornerDecoratorView.lineWidth / 2
            make.edges.equalTo(cameraPreviewContainer).inset(UIEdgeInsets(top: -offset, left: -offset, bottom: -offset, right: -offset))
        }
        
        view.addSubview(donwButton)
        view.addSubview(cancelButton)
        donwButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-5)
            make.top.equalTo(cameraPreviewContainer.snp.top).offset(40)
            make.size.equalTo(50)
        }
        cancelButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-5)
            make.bottom.equalTo(cameraPreviewContainer.snp.bottom).offset(-40)
            make.size.equalTo(50)
        }
    }
}

// action
extension ShootCoverViewController {
    
    @objc func shouldBackAction() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Self.willClose(originOrientation)) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cameraAction(_ sender: UIButton) {
        sender.isHidden = true
        donwButton.isHidden = false
        cancelButton.isHidden = false
        
        faceCameraManager.takePhoto()
    }
    
    @objc func cameraDoneAction() {
        DispatchQueue.main.async { [self] in
            shouldBackAction()
            if let croppedImage {
                onFinishPhoto?(croppedImage)
            }
        }
    }
    
    @objc func cameraCancelAction(_ sender: UIButton) {
        cameraButton.isHidden = false
        donwButton.isHidden = true
        sender.isHidden = true
        coverImageView.isHidden = true
        
        faceCameraManager.startRunning()
    }
}

extension ShootCoverViewController {
    
    private func createBackBarItem() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        button.setImage(UIImage(named: "nav_backitem_icon"), for: .normal)
        button.addTarget(self, action: #selector(shouldBackAction), for: .touchUpInside)
        return button
    }
    
    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Después de que el reconocimiento de la fotografía frontal sea exitoso, ingresará automáticamente el reverso."
        titleLabel.textColor = AppColorStyle.shared.backgroundWhite
        titleLabel.font = AppFontProvider.shared.getFont14Semibold()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        return titleLabel
    }
    
    private func createCameraButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        button.setImage(UIImage(named: "Icn_70x70_camera"), for: .normal)
        button.addTarget(self, action: #selector(cameraAction(_:)), for: .touchUpInside)
        return button
    }
    
    private func createDoneButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "Icn_50x50_camera_done"), for: .normal)
        button.addTarget(self, action: #selector(cameraDoneAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }
    
    private func createCancelButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "Icn_50x50_camera_cancel"), for: .normal)
        button.addTarget(self, action: #selector(cameraCancelAction(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }
}


extension ShootCoverViewController {
    static func push(from navCtr: UINavigationController?, orientation: ScreenRotator.Orientation, didFinishPhoto: @escaping ((UIImage) -> Void)) {
        let testVC = ShootCoverViewController(orientation: orientation, originOrientation: ScreenRotator.shared.orientation)
        testVC.onFinishPhoto = { image in
            didFinishPhoto(image)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + willShow(orientation)) {
            navCtr?.pushViewController(testVC, animated: true)
        }
    }
    
    private static func willShow(_ orientation: ScreenRotator.Orientation) -> Double {
        guard orientation != ScreenRotator.shared.orientation else { return 0 }
        ScreenRotator.shared.rotation(to: orientation)
        return 0.1
    }
    
    private static func willClose(_ orientation: ScreenRotator.Orientation?) -> Double {
        guard let orientation = orientation, orientation != ScreenRotator.shared.orientation else { return 0 }
        ScreenRotator.shared.rotation(to: orientation)
        return 0.1
    }
}
