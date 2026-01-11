//
//  RewardFillingDialog.swift
//  AL1
//
//  Created by cashlee on 2026/1/8.
//

import UIKit
import SnapKit

class RewardFillingDialog: BaseDialog {
    
    // 顶部溢出的装饰背景图
    private lazy var dialogBackgroundView: UIImageView = {
        guard let originalImage = UIImage(named: "reward_filling_bg") else {
            return UIImageView()
        }
        let edgeInsets = UIEdgeInsets(top: 0, left: 60, bottom: 60, right: 60)
        
        // 3. 创建可拉伸的图片
        let resizableImage = originalImage.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch)
        let bgImageView = UIImageView(image: resizableImage)
        bgImageView.isUserInteractionEnabled = true
        return bgImageView
    }()
    
    // 位于卡片外部底部的关闭按钮
    private lazy var externalCloseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "dialog_cancel_icon"), for: .normal) // 对应 UI 中的白色 X
        return button
    }()
    
    // MARK: - Setup
    
    override func setupViews() {
        contentView.clipsToBounds = false  // 关键：允许背景图向上溢出
        contentView.backgroundColor = .clear
        
        contentView.addSubview(dialogBackgroundView)
        dialogBackgroundView.addSubview(titleLabel)
        dialogBackgroundView.addSubview(messageLabel)
        dialogBackgroundView.addSubview(primaryButton)
        
        self.addSubview(externalCloseButton)
        
        // 3. 样式微调以复刻 UI
        titleLabel.font = AppFontProvider.shared.getFont15Semibold()
        titleLabel.textColor = UIColor(hex: "#1A1D33") // 视觉深蓝色
        titleLabel.textAlignment = .left
        
        messageLabel.font = AppFontProvider.shared.getFont14Regular()
        messageLabel.textColor = UIColor(hex: "#666666")
        messageLabel.textAlignment = .left // UI 中内容左对齐
        
        primaryButton.layer.cornerRadius = 8
        primaryButton.titleLabel?.font = AppFontProvider.shared.getFont16Medium()
        
        setupConstraints()
        
        // 4. 逻辑绑定
        externalCloseButton.addTarget(self, action: #selector(handleCancelAction), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // 卡片宽度设定
        
        contentView.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            make.width.equalTo(screenWidth * 0.8).priority(.high)
            make.height.equalTo(screenHeight * 0.4).priority(.high)
        }
        
        // 装饰背景图：向上偏移溢出
        dialogBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(dialogBackgroundView.snp.leading).offset(20)
            make.trailing.equalTo(dialogBackgroundView.snp.trailing).offset(-40)
            make.bottom.equalTo(messageLabel.snp.top).offset(-10)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(dialogBackgroundView).inset(20)
            make.bottom.equalTo(primaryButton.snp.top).offset(-20)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(dialogBackgroundView).inset(30)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(42)
        }
        
        // 外部关闭按钮布局
        externalCloseButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(44)
        }
    }
    
    // MARK: - Logic
    
    func configure(title: String, content: String, primaryTitle: String) {
        titleLabel.text = title
        messageLabel.text = content
        primaryButton.setTitle(primaryTitle, for: .normal)
    }
}
