//
//  LoanOrderTableViewCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit

class LoanOrderTableViewCell: BaseTableViewCell {
    static let reuseIdentifier = "LoanOrderCell"
    
    private lazy var buttonHeight: CGFloat = 24
    
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pre_pro_icon")
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorStyle.shared.textBlack33
        label.font = AppFontProvider.shared.getFont12Semibold()
        return label
    }()
    
    private lazy var tagLabel: TextInsetLabel = {
        let label = TextInsetLabel()
        label.font = AppFontProvider.shared.getFont12Medium()
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6) // 设置内边距
        return label
    }()
    
    private lazy var orderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = AppColorStyle.shared.textGrayF7 // 浅灰色背景
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) // 设置 StackView 内边距
        stackView.layer.cornerRadius = 8
        return stackView
    }()
    
    private lazy var ahoraButton: TextInsetLabel = {
       let button = TextInsetLabel()
        button.textInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12) // 设置内边距
        button.font = AppFontProvider.shared.getFont12Medium()
//        button.addTarget(self, action: #selector(ahoraAction), for: .touchUpInside)
        button.layer.cornerRadius = buttonHeight / 2
        button.layer.masksToBounds = true
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(whiteBackgroundView)
        
        whiteBackgroundView.addSubview(iconImageView)
        whiteBackgroundView.addSubview(titleLabel)
        whiteBackgroundView.addSubview(tagLabel)
        
        contentView.addSubview(orderStackView)
        contentView.addSubview(ahoraButton)
        let outerPadding: CGFloat = 15 // Cell 外部边距
        
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(iconImageView)
        whiteBackgroundView.addSubview(titleLabel)
        whiteBackgroundView.addSubview(tagLabel)
        whiteBackgroundView.addSubview(orderStackView)
        whiteBackgroundView.addSubview(ahoraButton)
        
        whiteBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(outerPadding)
            make.leading.trailing.equalToSuperview().inset(outerPadding)
            make.bottom.equalToSuperview() // 撑开 Cell 的底部
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(24) // 假设图标尺寸
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalTo(iconImageView)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalTo(iconImageView)
        }
        
        orderStackView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        ahoraButton.snp.makeConstraints { make in
            make.top.equalTo(orderStackView.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-15)
            make.width.greaterThanOrEqualTo(120)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    func configure(with item: OrderListItem) {
        titleLabel.text = item.productName
        iconImageView.loadImage(item.productLogo, placeholder: UIImage(named: "pre_pro_icon"))
        
        tagLabel.textColor = item.status.titleColor
        tagLabel.backgroundColor = item.status.tagcolor
        tagLabel.text = item.statusDisplayStr
        
        ahoraButton.text = item.status.buttonTitle
        ahoraButton.textColor = item.status.buttonTitleColor
        ahoraButton.backgroundColor = item.status.buttonTitleBgColor
        
        // 清空旧的 stack 视图
        orderStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // order id
        let appOrderId = item.appOrderId
        let pedidoTitle = "Número de pedido: \(appOrderId)"
        let v1 = TitleValueView(frame: .zero, title: pedidoTitle, value: appOrderId)
        orderStackView.addArrangedSubview(v1)
        
        // 借款金额
        let loanAmount = item.loanAmount.formattedNumber()
        let préstamoTitle =  "Monto del préstamo: S/\(loanAmount)"
        let v2 = TitleValueView(frame: .zero, title: préstamoTitle, value: "S/\(loanAmount)")
        orderStackView.addArrangedSubview(v2)
        
        // 申请时间
        let applyDate = item.applyDateStr ?? ""
        let aplicacionTitle =  "Tiempo de aplicación: \(applyDate)"
        let v3 = TitleValueView(frame: .zero, title: aplicacionTitle, value: applyDate)
        orderStackView.addArrangedSubview(v3)
    }
    
}
