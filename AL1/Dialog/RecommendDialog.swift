//
//  RecommendDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

class RecommendDialog: BaseDialog {
    
    // MARK: - 独有组件
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = AppColorStyle.shared.textGrayD9
        return imageView
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dialog_recommend")
        return imageView
    }()
    
    private let priceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = AppColorStyle.shared.brandSecondary
        return imageView
    }()
    
    private let priceValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorStyle.shared.backgroundWhite
        label.font = AppFontProvider.shared.getFont16Regular()
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorStyle.shared.backgroundWhite
        label.font = AppFontProvider.shared.getFont18Bold()
        return label
    }()
    
    // 滚动视图内的内容容器
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 15 // 默认内容间距
        return stack
    }()
    
    // MARK: - 动作与状态
    var secondaryAction: DialogAction?
    
    // MARK: - 初始化
    
    override init() {
        super.init()
        
        messageLabel.removeFromSuperview()
        cancelButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 动作处理
    
    @objc private func handleSecondaryAction() {
        secondaryAction?()
        // 可以选择在这里调用 dismiss()
    }
    
    @objc func cancelTap() {
        
    }
    
//    @objc override func handlePrimaryAction() {
//        // 父类 primaryAction?()
//        super.handlePrimaryAction()
//        // 可以选择在这里调用 dismiss()
//    }

    // MARK: - 布局设置
    override func setupViews() {
        super.setupViews()

        // 假设这些自定义组件已在子类中定义并添加到 BaseDialog.contentView 中
        // 注意：titleLabel 已经在 super.setupViews() 中添加，但它需要被约束。
        
        // 移除不使用的组件
        messageLabel.removeFromSuperview()

        // 确保这些自定义组件被添加到 contentView
        contentView.addSubview(iconImageView)
        contentView.addSubview(priceImageView)
        
        priceImageView.addSubview(priceValueLabel)
        priceImageView.addSubview(priceLabel)
        
        contentView.addSubview(rightImageView)
        contentView.addSubview(contentStackView)
        addSubview(cancelButton)

        // 确保 contentView 不裁剪子视图，因为 rightImageView（钱袋子）可能超出 contentVie w顶部
        // ⚠️ 注意：如果 Dialog 的 content 视图 (contentView) 的子视图溢出，SwiftEntryKit
        // 可能会裁剪。如果 rightImageView 真的需要溢出，可能需要将其直接添加到 BaseDialog 根视图或采取其他措施。
        contentView.clipsToBounds = false
        
        // --- 定义常量 ---
        let horizontalPadding: CGFloat = 20
        let buttonHeight: CGFloat = 55
        let topMargin: CGFloat = 20
        
        // 1.1 左侧图标
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(31)
            make.leading.equalToSuperview().offset(horizontalPadding)
            make.top.equalToSuperview().offset(topMargin)
        }

        // 1.2 标题 (继承自 BaseDialog)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.trailing.lessThanOrEqualTo(rightImageView.snp.leading).offset(-8)
        }

        // 1.3 右侧大图标/钱袋子 (注意：它可能在视觉上位于 priceImageView 上方)
        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-horizontalPadding)
            make.bottom.equalTo(iconImageView.snp.bottom)
        }

        priceImageView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(topMargin)
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.height.equalTo(85) // 固定高度
        }
        
        priceValueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.bottom.equalToSuperview().offset(5)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(priceImageView.snp.bottom).offset(25) // 间距调整为 25
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            // 高度由内部内容决定
        }

        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(contentStackView.snp.bottom).offset(35) // 按钮上方更大的间距
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.height.equalTo(buttonHeight)
            make.bottom.equalToSuperview().offset(-topMargin) // 撑开 contentView 底部
        }

        let width = UIScreen.main.bounds.width - 50
        contentView.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(width)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom).offset(40)
        }
    }
    
    // MARK: - 核心配置方法
    
    /// 用于配置 Dialog 的通用方法
    /// - Parameters:
    ///   - title: 顶部标题
    ///   - primaryTitle: 主按钮标题
    ///   - secondaryTitle: 次要按钮标题 (可选)
    ///   - customContent: 外部创建的 UIView 数组，用于填充 contentStackView
    ///   - primaryAction: 主操作闭包
    ///   - secondaryAction: 次要操作闭包 (可选)
    func configure(
        title: String,
        primaryTitle: String,
        secondaryTitle: String? = nil,
        customContent: [UIView],
        primaryAction: DialogAction?,
        secondaryAction: DialogAction? = nil
    ) {
        titleLabel.text = title
        primaryButton.setTitle(primaryTitle, for: .normal)
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        
        // 移除旧内容并添加新内容
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        customContent.forEach { contentStackView.addArrangedSubview($0) }
    }
}

extension RecommendDialog {
    
    func createTitleItem(for title: String) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = title
        label.font = AppFontProvider.shared.getFont12Regular() // 使用小字体
        label.textColor = AppColorStyle.shared.textGray
        container.addSubview(label)
        
        let valueLabel = UILabel()
        valueLabel.text = title
        valueLabel.font = AppFontProvider.shared.getFont12Regular() // 使用小字体
        valueLabel.textColor = AppColorStyle.shared.textGray
        container.addSubview(valueLabel)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
//            make.bottom.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return container
    }

}
