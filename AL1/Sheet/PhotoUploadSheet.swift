//
//  PhotoUploadSheet.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

class PhotoUploadSheet: BaseSheet {
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var cameraButton: UIButton = createVerticalButton(
        title: "cámara tomando fotos",
        imageName: "camera_sheet_icon",
        action: #selector(cameraAction)
    )
    
    lazy var galleryButton: UIButton = createVerticalButton(
        title: "Seleccionar del álbum",
        imageName: "gallery_sheet_icon",
        action: #selector(gallertAction)
    )
    
    var cameraHandler: (() -> Void)? = nil
    var galleryHandler: (() -> Void)? = nil
    
    override func setupViews() {
        titleLabel.text = "Elija el método de subida"
        
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(cameraButton)
        mainStackView.addArrangedSubview(galleryButton)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40) // 底部留白
            make.height.equalTo(120)
        }
    }
    @objc private func cameraAction() {
        handleCancelAction()
        cameraHandler?()
    }
    
    @objc private func gallertAction() {
        handleCancelAction()
        galleryHandler?()
    }
}

extension PhotoUploadSheet {
    // 辅助方法：创建图片在上文字在下的按钮
    private func createVerticalButton(title: String, imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.setTitleColor(UIColor(hex: "#484747"), for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont12Regular()
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        
        // iOS 15+ 推荐使用 Configuration
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.imagePlacement = .top
            config.imagePadding = 15
            config.baseForegroundColor = UIColor(hex: "#484747")
            button.configuration = config
        } else {
            // 旧版本通过偏移处理 (示意)
            let spacing: CGFloat = 15
            button.imageEdgeInsets = UIEdgeInsets(top: -spacing, left: 0, bottom: spacing, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -(button.imageView?.frame.width ?? 0), bottom: -spacing, right: 0)
        }
        
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
