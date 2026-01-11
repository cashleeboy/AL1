//
//  PrestamoCommonItemView.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit
import SnapKit

class PrestamoCommonItemView: UIView {
    // 定义点击回调
    var onValueClick: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // 右侧图标容器
    private lazy var rightIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true // 默认隐藏
        return imageView
    }()
    
    // 1. 定义点击容器
    private lazy var clickContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // 视觉透明
        view.isUserInteractionEnabled = true
        return view
    }()
    
    init(title: String,
         value: String,
         titleFont: UIFont? = nil,
         titleColor: UIColor? = nil,
         valueFont: UIFont? = nil,
         valueColor: UIColor? = nil) {
        
        super.init(frame: .zero)
        
        setupUI()
        setupGesture()
        
        titleLabel.text = title
        titleLabel.font = titleFont ?? AppFontProvider.shared.getFont12Regular()
        titleLabel.textColor = titleColor ?? AppColorStyle.shared.textGray66
        
        valueLabel.text = value
        valueLabel.font = valueFont ?? AppFontProvider.shared.getFont13Regular()
        valueLabel.textColor = valueColor ?? AppColorStyle.shared.brandPrimary
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(clickContainerView) // 添加容器
        clickContainerView.addSubview(valueLabel)
        clickContainerView.addSubview(rightIconImageView)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-10)
        }
        
        // 2. 扩大容器的约束范围（这就是实际的点击范围）
        clickContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(valueLabel.snp.leading).offset(0) // 甚至可以向左扩一点
        }
        
        // 3. 内部组件相对于容器布局
        rightIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 14, height: 14))
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(rightIconImageView.snp.trailing)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview() // 确保容器宽度包裹 Label
        }
    }
    
    // 3. 绑定点击手势
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleValueTap))
        clickContainerView.addGestureRecognizer(tap)
    }
    
    @objc private func handleValueTap() {
        onValueClick?()
    }
    
    // MARK: - 暴露给外部的方法
    
    /// 设置 Value 文字颜色
    func setValueColor(_ color: UIColor) {
        valueLabel.textColor = color
    }
    
    /// 显示右箭头（通常用于跳转）
    func showArrow(color: UIColor? = nil) {
        showRightIcon(named: "common_right_arrow", color: color)
    }
    
    /// 显示问号图标（通常用于费用解释提示）
    func showQuestionIcon(color: UIColor? = nil) {
        showRightIcon(named: "common_question_mark", color: color)
    }
    
    /// 显示右侧图标的核心通用方法
    private func showRightIcon(named imageName: String, color: UIColor? = nil) {
        var image = UIImage(named: imageName)
        if let color {
            image = image?.withTintColor(color)
        }
        rightIconImageView.image = image
        rightIconImageView.isHidden = false
        
        // 使用 remake 彻底重做约束，避免 update 找不到对应约束的报错
        valueLabel.snp.remakeConstraints { make in
            make.trailing.equalTo(rightIconImageView.snp.leading).offset(-4)
            make.centerY.equalTo(titleLabel)
            // 这里的 Leading 约束如果不加，重做后会丢失，所以要补齐
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
        }
    }
    
    func update(value: String) {
        valueLabel.text = value
    }
}
