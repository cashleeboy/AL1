//
//  RatingDialog.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//

import UIKit
import SnapKit

class RatingDialog: BaseDialog {
    
    // 1. 顶部横幅图片 (对应图片中的大拇指和星星背景)
    private let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "dialog_rating_banner")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    // 2. 星星评分堆栈视图
    private let starStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    // 存储星星按钮以便交互
    private var starButtons: [UIButton] = []
    var currentRating: Int = 0
    
    // MARK: - 初始化与布局
    override func setupViews() {
        super.setupViews()
        
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = false
        // 添加评分特有组件
        contentView.addSubview(bannerImageView)
        contentView.addSubview(starStackView)
        // 将关闭按钮添加到 self 而非 contentView，因为它在弹窗底部外面
        self.addSubview(cancelButton)
        
        setupRatingUI()
        setupConstraints()
    }
    
    private func setupRatingUI() {
        // 创建 5 个星星按钮
        for i in 1...5 {
            let btn = UIButton()
            // 默认显示未选中星星，第一个默认选中（参考图片）
            let imageName = (i == 1) ? "dialog_star_selected" : "dialog_star_unselected"
            btn.setImage(UIImage(named: imageName), for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(btn)
            starButtons.append(btn)
        }
        
        // 设置文字内容（参考图片）
        titleLabel.text = "Elogio de cinco estrellas"
        messageLabel.text = "Los comentarios de calidad son muy útiles para aumentar su límite de crédito."
        messageLabel.font = AppFontProvider.shared.getFont14Regular() // 图片中文案较细
        messageLabel.textColor = UIColor.gray // 图片中文案颜色较浅
        primaryButton.setTitle("Voy a comentar", for: .normal)
    }
    
    private func setupConstraints() {
        // 重新排布内容视图中的组件
        
        bannerImageView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.top).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160) // 根据图片比例调整
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bannerImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        starStackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(starStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
        // 底部关闭按钮（在白色卡片外）
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(40)
        }
    }
    
    // MARK: - 交互逻辑
    @objc private func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        currentRating = rating
        updateStars(rating: rating)
    }
    
    private func updateStars(rating: Int) {
        for (index, btn) in starButtons.enumerated() {
            let isSelected = (index + 1) <= rating
            let imageName = isSelected ? "dialog_star_selected" : "dialog_star_unselected"
            btn.setImage(UIImage(named: imageName), for: .normal)
        }
    }
}
