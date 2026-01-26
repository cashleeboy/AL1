//
//  SelectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import UIKit
import SnapKit

// 1. 定义功能类型
enum UserProfileType: String {
    case loanHistory = "loanHistory"    // 借贷记录
    case bankAccount = "bankAccount"    // 银行账户
    case feedback = "feedback"       // 反馈
    case aboutUs = "aboutUs"        // 关于我们
    case privacy = "privacy"        // 隐私政策
    case settings = "settings"       // 设置
}

enum CardPositoin {
    case top
    case middle
    case bottom
}

// 1. 数据模型 (必须是 Hashable)
struct UserProfile: TableItemProtocol {
    let identifier: String
    let title: String
    var icon: String
    var position: CardPositoin
    var type: UserProfileType // 增加类型字段
}


extension UserProfile: PrestamoRowConvertible {
    func toRow(action: ((UserProfile) -> Void)?) -> RowRepresentable {
        return ConcreteRow<UserProfile, ProfileSelectionCell>(item: self, didSelectAction: action)
    }
}

class ProfileSelectionCell: BaseConfigurablewCell {
    
    // MARK: - UI 组件
    private let backgroundCardView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        return view
    }()
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Regular() // 较小字体
        label.textColor = AppColorStyle.shared.textBlack50 // 次要颜色
        return label
    }()
    
    private let arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icn_right_point")
        return imageView
    }()
    
    // StackView，用于包裹标题和值
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImage, titleLabel, arrowImage])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        let internalPadding: CGFloat = 10
        let internalVerticalPadding: CGFloat = 15
        stack.layoutMargins = UIEdgeInsets(
            top: internalVerticalPadding,
            left: internalPadding,
            bottom: internalVerticalPadding,
            right: internalPadding
        )
        return stack
    }()
    
    override func setupViews() {
        contentView.addSubview(backgroundCardView)
        backgroundCardView.addSubview(textStackView)
        
        let sideMargin: CGFloat = 20
        let verticalSpacing: CGFloat = 0
        let cardPadding: CGFloat = 10
        
        backgroundCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(verticalSpacing)
            make.bottom.equalToSuperview().offset(-verticalSpacing)
            make.leading.equalToSuperview().offset(sideMargin)
            make.trailing.equalToSuperview().offset(-sideMargin)
        }
        
        textStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(cardPadding)
            make.trailing.equalToSuperview().offset(-(cardPadding))
        }
        
        iconImage.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        arrowImage.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
    
    // MARK: - CellConfigurable 协议实现
    override func configure(with item: any TableItemProtocol) {
        guard let profile = item as? UserProfile else {
            return
        }
        
        titleLabel.text = profile.title
        iconImage.image = UIImage(named: profile.icon)
        
        switch profile.position {
        case .top:
            backgroundCardView.setCornerRadius(10, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        case .middle:
            backgroundCardView.layer.cornerRadius = 0
        case .bottom:
            backgroundCardView.setCornerRadius(10, maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }
    }
}
