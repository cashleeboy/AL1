//
//  AgreementDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit

class AgreementDialog: BaseDialog {
    
    private let secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(AppColorStyle.shared.textGray, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont14Semibold()
        return button
    }()
    
    // E 样式独有的复选框视图
    private let checkboxContainer = UIView()
    private let checkboxImageView = UIImageView(image: UIImage(systemName: "checkmark.square.fill")) // 使用系统图标作为示例
    private let checkboxLabel = UILabel()

    var secondaryAction: DialogAction?
    
    @objc private func handleSecondaryAction() {
        secondaryAction?()
    }
    
    // 扩展配置，支持是否显示复选框
    func configure(
        title: String,
        message: String,
        buttonTitle: String,
        secondaryTitle: String?,
        primaryAction: DialogAction?,
        secondaryAction: DialogAction?,
        showCheckbox: Bool = false,
        checkboxMessage: String? = nil
    ) {
        titleLabel.text = title
        messageLabel.text = message
        primaryButton.setTitle(buttonTitle, for: .normal)
        secondaryButton.setTitle(secondaryTitle, for: .normal)
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        
        secondaryButton.isHidden = (secondaryTitle == nil)
        checkboxContainer.isHidden = !showCheckbox
        checkboxLabel.text = checkboxMessage
        
        // 动态重新设置布局
        setupLayout(showCheckbox: showCheckbox)
    }
    
    override init() {
        super.init()
        secondaryButton.addTarget(self, action: #selector(handleSecondaryAction), for: .touchUpInside)
        
        // 初始化复选框组件
        checkboxContainer.addSubview(checkboxImageView)
        checkboxContainer.addSubview(checkboxLabel)
        checkboxImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(24)
        }
        checkboxLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkboxImageView.snp.trailing).offset(8)
            make.trailing.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupViews() {
        // 初始时添加所有组件
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(checkboxContainer) // 样式 E
        contentView.addSubview(primaryButton)
        contentView.addSubview(secondaryButton) // 样式 D/E
        
        // 设置一个初始的默认布局，然后在 configure 中动态调整
        setupLayout(showCheckbox: false)
    }
    
    private func setupLayout(showCheckbox: Bool) {
        let margin: CGFloat = 25
        let buttonHeight: CGFloat = 55
        
        // 移除所有旧约束
        contentView.subviews.forEach { $0.snp.removeConstraints() }
        
        // 标题和消息约束 (通用)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(margin)
            make.leading.trailing.equalToSuperview().inset(margin)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(margin)
        }
        
        // 动态定位点：取决于是否有复选框
        let anchorView = showCheckbox ? checkboxContainer : messageLabel
        
        // 复选框约束 (如果显示)
        if showCheckbox {
            checkboxContainer.snp.makeConstraints { make in
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(margin)
                make.trailing.lessThanOrEqualToSuperview().offset(-margin)
            }
        }
        
        // 主按钮约束
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(anchorView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(margin)
            make.height.equalTo(buttonHeight)
        }
        
        // 次要按钮约束
        secondaryButton.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-margin) // 撑开底部
        }
        
        let width = UIScreen.main.bounds.width - 50
        contentView.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
    }
}
