//
//  ServiceFeeDialog.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit

class ServiceFeeDialog: BaseDialog {
    let title: String
    let titles: [String]
    let values: [String]
    var showSecondaryButton: Bool = false
    
    // 增加底部文本按钮（对应图中的 "No necesito dinero"）
    private let secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "No necesito dinero"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppFontProvider.shared.getFont14Regular(),
            .foregroundColor: AppColorStyle.shared.textGray66,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
        return button
    }()

    private let itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fill
        return stack
    }()
    
    init(title: String, titles: [String], values: [String], showSecondary: Bool = false) {
        self.title = title
        self.titles = titles
        self.values = values
        self.showSecondaryButton = showSecondary
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupViews() {
        // 1. 添加组件
        contentView.addSubview(titleLabel)
        contentView.addSubview(itemsStackView)
        contentView.addSubview(primaryButton)
        contentView.addSubview(secondaryButton)
        
        // 2. 动态构建列表行
        buildListItems()
        
        // 3. 布局约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(25)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(itemsStackView.snp.bottom).offset(35)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(40)
        }
        
        let screenWidth = UIScreen.main.bounds.width

        contentView.snp.makeConstraints { make in
            make.width.equalTo(screenWidth * 0.75).priority(.high)
        }
        
        if showSecondaryButton {
            secondaryButton.isHidden = false
            secondaryButton.snp.makeConstraints { make in
                make.top.equalTo(primaryButton.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-25)
            }
        } else {
            secondaryButton.isHidden = true
            // 如果不显示次级按钮，则 PrimaryButton 距离底部
            primaryButton.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-35)
            }
        }
         
        // 4. 设置基础数据
        titleLabel.text = title// "Detalles de la cantidad de reembolso"
        titleLabel.font = AppFontProvider.shared.getFont14Semibold()
        primaryButton.setTitle("Confirmar Préstamo", for: .normal)
        
        // 绑定底部取消动作
        secondaryButton.addTarget(self, action: #selector(handleSecondaryAction), for: .touchUpInside)
    }
    
    private func buildListItems() {
        // 确保数据对等
        let count = min(titles.count, values.count)
        for i in 0..<count {
            let row = PrestamoCommonItemView(
                title: titles[i],
                value: values[i],
                titleFont: AppFontProvider.shared.getFont14Regular(),
                titleColor: AppColorStyle.shared.textGray66,
                valueFont: AppFontProvider.shared.getFont16Bold(),
                valueColor: AppColorStyle.shared.textBlack
            )
            itemsStackView.addArrangedSubview(row)
        }
    }
    
    @objc private func handleSecondaryAction() {
        // 触发 dismiss 逻辑
        cancelAction?()
    }
}

