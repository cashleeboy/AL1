//
//  ProfileHeaderSelectionView.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import UIKit
import SnapKit

struct HeaderProfile: IdentifiableTableItem {
    static let reuseIdentifier = "ProfileHeaderSelectionView"
    let identifier: String = reuseIdentifier
    let title: String = ""
    // Fácil Crédito
    
    var subtitle: String {
        // 自动读取 Info.plist 里的 Display Name
        let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "App"
        return "Bienvenido a \(name)"
    }
    var icon: String = "prefile_default_icon"
    var ahoraButtonTitle = "Pagar ahora"
    var topInset: CGFloat
    
    var userProfile: UserProfileModel?
}

extension HeaderProfile: PrestamoRowConvertible {
    func toRow(action: ((HeaderProfile) -> Void)?) -> RowRepresentable {
        return ConcreteRow<HeaderProfile, ProfileHeaderSelectionView>(item: self, didSelectAction: action)
    }
}

class ProfileHeaderSelectionView: BaseConfigurablewCell
{
    private var topInsetConstraint: Constraint?
    private var pagoViewBottomConstraint: Constraint? // 支付视图对底部的约束
    private var cardBottomToIconConstraint: Constraint? // 头像对卡片底部的备用约束

    // MARK: - UI 组件 (部分已在原代码中)
    private lazy var backgroundCardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var backgroundPagoView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "personal_pago_icon")
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30 // 假设头像尺寸 60，半径 30
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = AppColorStyle.shared.backgroundWhite // 默认白色背景
        return imageView
    }()
     
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Bold()
        label.textColor = AppColorStyle.shared.backgroundWhite
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = AppColorStyle.shared.backgroundWhite
        return label
    }()
    
    private lazy var ahoraButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(AppColorStyle.shared.backgroundWhite, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont14Regular()
        button.addTarget(self, action: #selector(ahoraAction), for: .touchUpInside)
        button.backgroundColor = AppColorStyle.shared.brandPrimary // 橙色背景
        button.layer.cornerRadius = 16
        return button
    }()
    
    private lazy var pagoLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont18Bold()
        label.textColor = AppColorStyle.shared.textGrayED
        return label
    }()
    
    private lazy var pagarLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Medium()
        label.textColor = AppColorStyle.shared.textGrayED
        return label
    }()

    // 动作闭包，用于回调给 Controller
    var ahoraButtonAction: (() -> Void)?
    
    private var isTopRow: Bool = false
        
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundCardView.applyGradient(with: [
            UIColor(hex: "#FF7A0E"),
            UIColor(hex: "#FEA626"),
            UIColor(hex: "#F3CC3E", opacity: 0)
        ])
    }
    
    // MARK: - 布局设置
    override func setupViews() {
        super.setupViews()
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        contentView.addSubview(backgroundCardView)
        
        backgroundCardView.addSubview(iconImage)
        backgroundCardView.addSubview(titleLabel)
        backgroundCardView.addSubview(subtitleLabel)
        
        backgroundCardView.addSubview(backgroundPagoView)
        
        backgroundPagoView.addSubview(pagoLabel)
        backgroundPagoView.addSubview(pagarLabel)
        backgroundPagoView.addSubview(ahoraButton)
        
        // --- 约束常量 ---
        let horizontalPadding: CGFloat = 20
        
        backgroundCardView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        iconImage.snp.makeConstraints { make in
            self.topInsetConstraint = make.top.equalToSuperview().offset(0).constraint
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(60)
            // ⭐️ 关键点：创建一个备用约束，当下方视图隐藏时，它负责支撑卡片高度
            // 优先级设为较低(999)，防止与有订单时的支付视图约束冲突
            self.cardBottomToIconConstraint = make.bottom.equalTo(backgroundCardView.snp.bottom).offset(-20).priority(999).constraint
            self.cardBottomToIconConstraint?.deactivate() // 初始先关闭
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImage.snp.trailing).offset(15)
            make.top.equalTo(iconImage).offset(5)
            make.trailing.equalToSuperview().offset(-horizontalPadding)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.trailing.equalToSuperview().offset(-horizontalPadding)
        }
        
        backgroundPagoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(85)
            make.top.equalTo(iconImage.snp.bottom).offset(15)
            // ⭐️ 记录这个底部约束，方便动态开关
            self.pagoViewBottomConstraint = make.bottom.equalTo(backgroundCardView.snp.bottom).offset(-20).constraint
        }
        
        ahoraButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(100)
        }
        
        pagoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalTo(backgroundPagoView.snp.centerY).offset(-5)
            make.trailing.equalTo(ahoraButton.snp.leading).offset(-10)
        }
        
        pagarLabel.snp.makeConstraints { make in
            make.leading.equalTo(pagoLabel)
            make.top.equalTo(backgroundPagoView.snp.centerY).offset(5)
        }
    }
    
    // MARK: - 数据配置
    
    override func configure(with item: any TableItemProtocol) {
        guard let profile = item as? HeaderProfile else {
            return
        }
        let model = profile.userProfile
        titleLabel.text = model?.userName
        subtitleLabel.text = profile.subtitle
        iconImage.image = UIImage(named: profile.icon) ?? UIImage(systemName: "person.circle.fill")
        
        // 更新顶部偏移
        topInsetConstraint?.update(offset: profile.topInset)
        
        let hasOrders = (profile.userProfile?.totalOrderNum ?? 0) > 0
        if hasOrders {
            // 显示
            backgroundPagoView.isHidden = false
            
            if let repayAmount = model?.repayAmount, repayAmount > 0 {
                let value = "S/\(repayAmount)"
                let pagoTitle = "\(value) （Pago Vencido）"
                
                let attributedString = NSMutableAttributedString.makeStyledText(fullText: pagoTitle,
                                                         boldParts: [value],
                                                         font: AppFontProvider.shared.getFont12Semibold(),
                                                         boldFont: AppFontProvider.shared.getFont18Semibold(),
                                                         textColor: AppColorStyle.shared.backgroundWhite,
                                                         boldTextColor: UIColor(hex: "#EECC83")
                )
                
                pagoLabel.attributedText = attributedString
                pagarLabel.text = "Monto a pagar"
                
            } else if let loanAmount = model?.loanAmount {
                let value = "S/\(loanAmount)"
                let pagoTitle = "\(value) （Ya levantado）"
                
                let attributedString = NSMutableAttributedString.makeStyledText(fullText: pagoTitle,
                                                         boldParts: [value],
                                                         font: AppFontProvider.shared.getFont12Semibold(),
                                                         boldFont: AppFontProvider.shared.getFont18Semibold(),
                                                         textColor: AppColorStyle.shared.backgroundWhite,
                                                         boldTextColor: UIColor(hex: "#EECC83")
                )
                
                pagoLabel.attributedText = attributedString
                pagarLabel.text = "Monto disponible para pedir prestado"
            }
            
            ahoraButton.setTitle(profile.ahoraButtonTitle, for: .normal)
            // --- 约束逻辑 ---
            cardBottomToIconConstraint?.deactivate() // 关闭头像到卡片底部的连接
            pagoViewBottomConstraint?.activate()     // 开启支付卡片到底部的连接
        } else {
            // 隐藏
            backgroundPagoView.isHidden = true
            
            pagoViewBottomConstraint?.deactivate()   // 关闭支付卡片底部的连接（防止它把下方撑开）
            cardBottomToIconConstraint?.activate()   // 让卡片底部直接跟着头像走，消除空白
        }
        
        setNeedsLayout()
    }
    
    @objc func ahoraAction() {
        ahoraButtonAction?()
    }
}
