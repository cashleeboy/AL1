//
//  UserBankCardTableViewCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import UIKit

class UserBankCardTableViewCell: BaseTableViewCell {
    // 背景卡片视图
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12 // 根据图片调整圆角
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.layer.borderWidth = 1
        return view
    }()
    
    private let bankNameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = AppColorStyle.shared.textBlack
        return label
    }()
    
    private let bankNumberLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Regular()
        label.textColor = AppColorStyle.shared.textBlack
        return label
    }()
    
    private let checkIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "pre_login_enable")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override func setupViews() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(bankNumberLabel)
        containerView.addSubview(checkIcon)
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        bankNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(checkIcon.snp.left).offset(-10)
        }
        
        bankNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(bankNameLabel.snp.bottom).offset(20)
            make.left.equalTo(bankNameLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        checkIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
    }
    
    func configure(with item: UserBankCardItem) {
        bankNameLabel.text = item.bankName
        bankNumberLabel.text = item.bankNumberMasked // 建议使用脱敏后的卡号
        checkIcon.isHidden = !item.isSelected
        
        updateSelectionState(isSelected: item.isSelected)
    }
    
    private func updateSelectionState(isSelected: Bool) {
        if isSelected {
            // 选中状态：浅橘背景，橘色边框，显示图标
            containerView.backgroundColor = UIColor(hex: "#FFE0B8") // 根据 UI 取色
            containerView.layer.borderColor = AppColorStyle.shared.brandPrimary.cgColor
            checkIcon.isHidden = false
        } else {
            // 非选中状态：白色背景，无边框，隐藏图标
            containerView.backgroundColor = AppColorStyle.shared.backgroundWhite
            containerView.layer.borderColor = UIColor.clear.cgColor
            checkIcon.isHidden = true
        }
    }
}
