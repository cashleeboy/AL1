//
//  BottomButtonContainer.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

enum BottomButtonStyle {
    // 带有主按钮和安全信息
    case primaryWithSecurity(title: String, securityText: String?, primaryAction: ButtonAction?)
    // 带有主按钮和次要按钮
    case primaryWithSecondary(primaryTitle: String, secondaryTitle: String?, primaryAction: ButtonAction?, secondaryAction: ButtonAction?)
    // 仅主按钮
    case primaryOnly(title: String, primaryAction: ButtonAction?)
    case customContentView(primaryTitle: String, topContentView: UIView?, bottomContentView: UIView?, primaryAction: ButtonAction?)
}

// MARK: - 2. 核心视图类

class BottomButtonContainer: UIView {
    
    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.backgroundColor = AppColorStyle.shared.brandPrimary
        button.setTitleColor(AppColorStyle.shared.backgroundWhite, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont18Semibold()
        return button
    }()
    
    private let secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFontProvider.shared.getFont18Semibold() // 次要字体
        button.setTitleColor(AppColorStyle.shared.textGray, for: .normal)
        return button
    }()
    
    private let securityInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorStyle.shared.textGray
        label.font = AppFontProvider.shared.getFont12Medium()
        label.textAlignment = .center
        return label
    }()
    
    private var topCustomView: UIView?
    private var bottomCustomView: UIView?
    
    // MARK: - 闭包存储
    private var primaryAction: ButtonAction?
    private var secondaryAction: ButtonAction?
    
    // MARK: - 初始化与布局
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = AppColorStyle.shared.backgroundWhite
        
        primaryButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(didTapSecondaryButton), for: .touchUpInside)
        
        self.addSubview(primaryButton)
        self.addSubview(secondaryButton)
        self.addSubview(securityInfoLabel)
        
        let verticalSpacing: CGFloat = 13
        let horizontalPadding: CGFloat = 16
        let buttonHeight: CGFloat = 48
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(verticalSpacing).priority(.low)
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.height.equalTo(buttonHeight)
        }
        
        secondaryButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        
        securityInfoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - 动作处理
    
    @objc private func didTapPrimaryButton() {
        primaryAction?()
    }
    
    @objc private func didTapSecondaryButton() {
        secondaryAction?()
    }
    
    // MARK: - 核心配置方法
    func setPrimaryState(isEnable: Bool?,
                         enableColor: UIColor = AppColorStyle.shared.brandPrimary,
                         disableColor: UIColor = AppColorStyle.shared.brandPrimaryDisabled) {
        
        guard let isEnable else {
            return
        }
        primaryButton.isEnabled = isEnable
        primaryButton.backgroundColor = isEnable ? enableColor : disableColor
    }
    
    func setPrimaryState(with title: String) {
        primaryButton.setTitle(title, for: .normal)
    }
    
    func setPrimaryBackground(with color: UIColor) {
        primaryButton.backgroundColor = color
    }
    
    /// 根据样式配置按钮容器的内容和布局
    func configure(with style: BottomButtonStyle) {
        // 1. 清理旧的自定义视图和所有现有约束，防止堆叠冲突
        topCustomView?.removeFromSuperview()
        bottomCustomView?.removeFromSuperview()
        topCustomView = nil
        bottomCustomView = nil
        
        // 关键：重置所有组件的约束，确保每次 configure 都是“干净”的
        primaryButton.snp.removeConstraints()
        secondaryButton.snp.removeConstraints()
        securityInfoLabel.snp.removeConstraints()
        
        // 2. 恢复默认状态
        primaryButton.isHidden = false
        secondaryButton.isHidden = true
        securityInfoLabel.isHidden = true
        
        // 基础水平约束 (所有模式通用)
        let horizontalInset = 16
        let buttonHeight = 48
        let verticalMargin = 15
        
        switch style {
        case .primaryOnly(let title, let action):
            primaryButton.setTitle(title, for: .normal)
            primaryAction = action
            
            primaryButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(verticalMargin)
                make.leading.trailing.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(buttonHeight)
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-verticalMargin).priority(.required)
            }

        case .primaryWithSecurity(let title, let securityText, let action):
            primaryButton.setTitle(title, for: .normal)
            primaryAction = action
            securityInfoLabel.isHidden = false
            securityInfoLabel.text = securityText
            
            securityInfoLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(verticalMargin)
                make.centerX.equalToSuperview()
            }
            primaryButton.snp.makeConstraints { make in
                make.top.equalTo(securityInfoLabel.snp.bottom).offset(verticalMargin)
                make.leading.trailing.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(buttonHeight)
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-verticalMargin).priority(.required)
            }

        case .primaryWithSecondary(let pTitle, let sTitle, let pAction, let sAction):
            primaryButton.setTitle(pTitle, for: .normal)
            primaryAction = pAction
            secondaryButton.isHidden = false
            secondaryButton.setTitle(sTitle, for: .normal)
            secondaryAction = sAction
            
            primaryButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(verticalMargin)
                make.leading.trailing.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(buttonHeight)
            }
            secondaryButton.snp.makeConstraints { make in
                make.top.equalTo(primaryButton.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-verticalMargin).priority(.required)
            }

        case .customContentView(let pTitle, let topView, let bottomView, let action):
            primaryButton.setTitle(pTitle, for: .normal)
            primaryAction = action
            
            // 绑定并添加视图
            topCustomView = topView
            bottomCustomView = bottomView
            if let tView = topView { self.addSubview(tView) }
            if let bView = bottomView { self.addSubview(bView) }
            
            // 串联布局逻辑
            var lastAnchor = self.snp.top
            
            if let tView = topView {
                tView.snp.makeConstraints { make in
                    make.top.equalTo(lastAnchor).offset(12)
                    make.leading.trailing.equalToSuperview().inset(20)
                }
                lastAnchor = tView.snp.bottom
            }
            
            primaryButton.snp.makeConstraints { make in
                make.top.equalTo(lastAnchor).offset(topView == nil ? 12 : 15)
                make.leading.trailing.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(buttonHeight)
            }
            
            if let bView = bottomView {
                bView.snp.makeConstraints { make in
                    make.top.equalTo(primaryButton.snp.bottom).offset(15)
                    make.leading.trailing.equalToSuperview().inset(20)
                    make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-12).priority(.required)
                }
            } else {
                primaryButton.snp.makeConstraints { make in
                    make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-12).priority(.required)
                }
            }
        }
    }
}
