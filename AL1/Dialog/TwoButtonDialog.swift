//
//  Dialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

class TwoButtonDialog: BaseDialog {
    
    // MARK: - UI Components
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    private let iconImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()
    
    // 按钮水平堆栈 (取消 | 确定)
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 15
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.backgroundColor = UIColor(hex: "#F0F0F0") // 浅灰色背景
        button.setTitleColor(UIColor(hex: "#7E848F"), for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont18Semibold()
        return button
    }()
    
    // MARK: - Actions
    var secondaryAction: DialogAction?
    
    override init() {
        super.init()
        secondaryButton.addTarget(self, action: #selector(handleSecondaryAction), for: .touchUpInside)
    }
    
    @objc private func handleSecondaryAction() {
        secondaryAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupViews() {
        // 1. 移除父类默认添加方式，改为进入 StackView 统一管理
        titleLabel.removeFromSuperview()
        messageLabel.removeFromSuperview()
        primaryButton.removeFromSuperview()
        
        contentView.addSubview(mainStackView)
        
        // 2. 按顺序添加组件
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(iconImageView)
        mainStackView.addArrangedSubview(messageLabel)
        mainStackView.addArrangedSubview(buttonStackView)
        
        // 3. 将按钮加入水平堆栈
        buttonStackView.addArrangedSubview(secondaryButton)
        buttonStackView.addArrangedSubview(primaryButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        // 整个容器的边距约束
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-25)
        }
        
        // 图片尺寸约束
        iconImageView.snp.makeConstraints { make in
            make.height.equalTo(140) // 根据插画比例调整
            make.width.equalToSuperview()
        }
        
        // 按钮组高度
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview()
        }
        
        contentView.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-60)
        }
    }
    
    // MARK: - Configuration
    
    /// 完整配置方法
    func configure(
        title: String?,
        message: String?,
        imageName: String? = nil,
        primaryTitle: String = "Continuar",
        secondaryTitle: String = "Abandonar"
    ) {
        titleLabel.text = title
        titleLabel.isHidden = (title == nil)
        
        messageLabel.text = message
        
        if let name = imageName {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: name)
        } else {
            iconImageView.isHidden = true
        }
        
        primaryButton.setTitle(primaryTitle, for: .normal)
        secondaryButton.setTitle(secondaryTitle, for: .normal)
        
        // 调整文字间距或样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        if let msg = message {
            messageLabel.attributedText = NSAttributedString(
                string: msg,
                attributes: [.paragraphStyle: paragraphStyle]
            )
        }
    }
}


