//
//  InformationConfirmDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

struct ConfirmItem {
    let title: String
    let content: String
}

class InformationConfirmDialog: BaseDialog {
    
    // MARK: - UI Components
    
    /// 承载中部信息条目的容器
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .fill
        return stack
    }()
    
    /// 左侧“修改”按钮 (次要按钮)
    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0) // 浅灰色
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont14Semibold()
        return button
    }()
    
    // MARK: - Actions
    var secondaryAction: DialogAction?
    
    // MARK: - Setup
    
    override func setupViews() {
        titleLabel.font = AppFontProvider.shared.getFont14Regular()
        // 配置基础组件 (从父类继承)
        primaryButton.layer.cornerRadius = 12
        primaryButton.backgroundColor = AppColorStyle.shared.brandPrimary 
        primaryButton.titleLabel?.font = AppFontProvider.shared.getFont14Semibold()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(secondaryButton)
        contentView.addSubview(primaryButton)
        
        // 布局约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.right.equalToSuperview().inset(30)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(28)
        }
        
        secondaryButton.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(45)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(secondaryButton)
            make.left.equalTo(secondaryButton.snp.right).offset(16)
            make.right.equalToSuperview().offset(-24)
            make.width.equalTo(secondaryButton) // 按钮等宽
            make.height.equalTo(45)
        }
        
        secondaryButton.addTarget(self, action: #selector(handleSecondaryAction), for: .touchUpInside)
    }
    
    @objc private func handleSecondaryAction() {
        secondaryAction?()
    }
    
    // MARK: - Configuration Method
    
    /// 核心配置方法
    /// - Parameters:
    ///   - title: 弹窗主标题 (如: Verifique su información bancaria)
    ///   - items: 信息对列表 (如: ["Banco": "TMB..."])
    ///   - secondaryTitle: 左侧按钮文字 (Modificar)
    ///   - primaryTitle: 右侧按钮文字 (Confirmar)
    func configure(title: String, items: [ConfirmItem], secondaryTitle: String, primaryTitle: String) {
        titleLabel.text = title
        
        secondaryButton.setTitle(secondaryTitle, for: .normal)
        primaryButton.setTitle(primaryTitle, for: .normal)
        
        // 清空旧的 stack 视图
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 动态添加信息条目
        for item in items {
            let itemContainer = UIStackView()
            itemContainer.axis = .vertical
            itemContainer.spacing = 15
            
            let itemTitleLabel = UILabel()
            itemTitleLabel.font = AppFontProvider.shared.getFont14Regular()
            itemTitleLabel.textColor = UIColor.lightGray
            itemTitleLabel.text = item.title
            
            let itemContentLabel = UILabel()
            itemContentLabel.font = AppFontProvider.shared.getFont14Regular()
            itemContentLabel.textColor = AppColorStyle.shared.textBlack
            itemContentLabel.numberOfLines = 0
            itemContentLabel.text = item.content
            
            itemContainer.addArrangedSubview(itemTitleLabel)
            itemContainer.addArrangedSubview(itemContentLabel)
            infoStackView.addArrangedSubview(itemContainer)
        }
    }
}
