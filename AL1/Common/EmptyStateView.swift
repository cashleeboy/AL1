//
//  EmptyStateView.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import UIKit
import SnapKit

// 定义一个闭包类型用于按钮点击事件
typealias EmptyViewButtonAction = () -> Void

class EmptyStateView: UIView {
    
    // MARK: - 组件
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    // 按钮点击时的回调
    private var buttonAction: EmptyViewButtonAction?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - 视图设置
    
    private func setupViews() {
        
        // 1. 配置子控件属性 (保持原样，移除 translatesAutoresizingMaskIntoConstraints)
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.textColor = AppColorStyle.shared.textBlack
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        subtitleLabel.textColor = .lightGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        actionButton.titleLabel?.font = AppFontProvider.shared.getFont16Bold()
        actionButton.backgroundColor = AppColorStyle.shared.brandPrimary
        actionButton.layer.cornerRadius = 8
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        
        // 2. 配置 StackView
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel, actionButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill // 默认值，由子视图撑开高度
        
        self.addSubview(stackView)
        
        // 3. 使用 SnapKit 设置约束
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)    // 顶部边距
            make.bottom.equalToSuperview().offset(-20) // 底部边距
            
            // 左右边距
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            
            make.centerX.equalToSuperview()
        }
        
        // 4. 配置子控件特定约束
        imageView.snp.makeConstraints { make in
            make.height.equalTo(150).priority(.low) // 示例高度，优先级设低以便自适应
        }
        
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    // MARK: - 公共配置方法

    /// 配置 EmptyStateView 的内容
    func configure(image: UIImage?,
                   title: String?,
                   subtitle: String?,
                   buttonTitle: String?,
                   buttonAction: EmptyViewButtonAction?) {
        
        // 图像配置
        imageView.image = image
        imageView.isHidden = (image == nil)
        
        // 标题配置
        titleLabel.text = title
        titleLabel.isHidden = (title == nil)
        
        // 副标题配置
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle == nil)
        
        // 按钮配置
        if let buttonTitle = buttonTitle {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.isHidden = false
            self.buttonAction = buttonAction
        } else {
            actionButton.isHidden = true
            self.buttonAction = nil
        }
    }
    
    @objc private func handleButtonTap() {
        buttonAction?()
    }
}
