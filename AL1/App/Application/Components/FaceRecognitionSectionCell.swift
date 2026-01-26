//
//  FaceRecognitionSectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/26.
//

import UIKit
import AVFoundation

class FaceRecognitionSectionModel: IdentifiableTableItem {
    var identifier: String = "FaceRecognitionSectionCell"
    var onImageCaptured: ((UIImage) -> Void)
    // 触发拍照的回调：由 View 赋值给 Cell，由外部按钮调用
    var triggerCapture: (() -> Void)? = nil
    
    var onStopRuningCapture: (() -> Void)? = nil
    // 
    init(onImageCaptured: @escaping (UIImage) -> Void) {
        self.onImageCaptured = onImageCaptured
    }
}

class FaceRecognitionSectionCell: BaseConfigurablewCell {
    private var faceRecogModel: FaceRecognitionSectionModel?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Coloque la cámara a su rostro y manténgalo bien iluminado"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = AppColorStyle.shared.textBlack1C
        label.font = AppFontProvider.shared.getFont16Medium()
        return label
    }()
    
    // 预览视图容器
    private let cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return view
    }()
    
    // 遮罩层：用于实现圆圈外半透明灰色
    private let overlayLayer = CAShapeLayer()
    private lazy var cameraManager: FaceCameraManager = {
        let manager = FaceCameraManager()
        return manager
    }()
    
    override func setupViews() {
        contentView.addSubview(cameraView)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.top.equalToSuperview().offset(40)
        }
        
        cameraView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            // 保持正方形比例，宽度占屏幕的 80%
            make.width.equalToSuperview().multipliedBy(0.89)
            make.height.equalTo(cameraView.snp.width)
            make.bottom.equalToSuperview().offset(-40).priority(.low)
        }
        
        bindCameraManager()
    }
    
    private func bindCameraManager() {
        cameraManager.onError = { [weak self] message in
            DispatchQueue.main.async { self?.titleLabel.text = message }
        }
        cameraManager.onPermissionDenied = { [weak self] in
            self?.showPermissionDeniedUI()
        }
        cameraManager.onImageCaptured = { [weak self] image in
            self?.faceRecogModel?.onImageCaptured(image)
        }
    }
    
    // 当 Cell 即将离开屏幕时停止，节省资源
    override func prepareForReuse() {
        super.prepareForReuse()
        cameraManager.stopRunning()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 布局完成后，更新相机预览层的大小和遮罩
        updateCameraLayout()
    }
    
    func didClickCapture() {
        cameraManager.takePhoto()
    }
    
    func startRunning() {
        cameraManager.startRunning()
    }
    
    func stopRunning() {
        cameraManager.stopRunning()
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let item = item as? FaceRecognitionSectionModel else { return }
        faceRecogModel = item
        
        // 核心：每次配置时确保相机准备就绪
        // prepareCamera 内部已经处理了权限和 sessionQueue
        cameraManager.prepareCamera(in: cameraView, orientation: .portrait)
        
        item.triggerCapture = { [weak self] in
            self?.didClickCapture()
        }
        
        item.onStopRuningCapture = { [weak self] in
            self?.stopRunning()
        }
    }
}

extension FaceRecognitionSectionCell {
    
    private func updateCameraLayout() {
        // 让相机预览图层的 Frame 跟随容器
        cameraView.layer.sublayers?.forEach {
            if $0 is AVCaptureVideoPreviewLayer {
                $0.frame = cameraView.bounds
            }
        }
        setupCircleOverlay()
    }
    
    private func setupCircleOverlay() {
        // 1. 创建整体路径
        let path = UIBezierPath(rect: cameraView.bounds)
        
        // 2. 创建圆形镂空路径
        // 半径设为容器宽度的 45%，基本填满正方形但留有一点边距
        let radius = cameraView.bounds.width * 0.45
        let center = CGPoint(x: cameraView.bounds.midX, y: cameraView.bounds.midY)
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: 0,
                                      endAngle: .pi * 2,
                                      clockwise: true)
        
        // 3. 组合路径 (Even-Odd 填充规则实现镂空)
        path.append(circlePath)
        overlayLayer.path = path.cgPath
        overlayLayer.fillRule = .evenOdd 
        overlayLayer.fillColor = AppColorStyle.shared.backgroundWhite.cgColor
        
        // 移除旧的并添加新的覆盖层
        overlayLayer.removeFromSuperlayer()
        cameraView.layer.addSublayer(overlayLayer)
    }
}


extension FaceRecognitionSectionCell {
    
    private func showPermissionDeniedUI() {
        // 1. 修改标题文字
        titleLabel.text = "Acceso a la cámara denegado"
        
        // 2. 在 cameraView 中添加占位视图
        let deniedView = UIView()
        deniedView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        cameraView.addSubview(deniedView)
        deniedView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 3. 添加图标（建议使用 SF Symbols 或你项目中的相机图标）
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: "camera.fill.badge.ellipsis")
        }
        iconImageView.tintColor = .gray
        deniedView.addSubview(iconImageView)
        
        // 4. 添加引导按钮
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Ir a Configuración", for: .normal)
        settingsButton.titleLabel?.font = AppFontProvider.shared.getFont14Semibold()
        settingsButton.backgroundColor = AppColorStyle.shared.brandPrimary // 假设你有主题色
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.layer.cornerRadius = 8
        settingsButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        settingsButton.addTarget(self, action: #selector(openSystemSettings), for: .touchUpInside)
        
        deniedView.addSubview(settingsButton)
        
        // 布局
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.size.equalTo(60)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
    }
    
    @objc private func openSystemSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
}
