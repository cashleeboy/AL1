//
//  ReembolsoBaseTableViewCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit

class ReembolsoBaseTableViewCell: BaseTableViewCell {
    let buttonHeight: CGFloat = 25
    var onConfirmToggle: ((Bool) -> Void)?
    
    lazy var whiteBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pre_pro_icon")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "产品名称"
        label.textColor = AppColorStyle.shared.textBlack33
        label.font = AppFontProvider.shared.getFont12Semibold()
        return label
    }()
    
    lazy var tagLabel: TextInsetLabel = {
        let label = TextInsetLabel() 
        label.font = AppFontProvider.shared.getFont12Medium()
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6) // 设置内边距
        return label
    }()
    
    lazy var orderStackView: UIStackView = {
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
        button.layer.cornerRadius = buttonHeight / 2
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var confirmButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "pre_pro_disable"), for: .normal)
        button.setImage(UIImage(named: "pre_pro_enable"), for: .selected)
        button.addTarget(self, action: #selector(confirmAction(_:)), for: .touchUpInside)
        button.isHidden = true
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
        whiteBackgroundView.addSubview(confirmButton)
        
        whiteBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(outerPadding)
            make.leading.trailing.equalToSuperview().inset(outerPadding)
            make.bottom.equalToSuperview() // 撑开 Cell 的底部
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(24)
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
        
        confirmButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.leading.equalTo(iconImageView.snp.leading)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        ahoraButton.snp.makeConstraints { make in
            make.top.equalTo(orderStackView.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-15)
            make.width.greaterThanOrEqualTo(100)
            make.width.lessThanOrEqualTo(200)
            make.centerY.equalTo(confirmButton)
        }
        
    }

    func configure(with item: OrderListItem, onConfirmToggle: @escaping ((Bool) -> Void))
    {
        self.onConfirmToggle = onConfirmToggle
        
        titleLabel.text = item.productName
        iconImageView.loadImage(item.productLogo, placeholder: UIImage(named: "pre_pro_icon"))
        
        tagLabel.textColor = item.status.titleColor
        tagLabel.backgroundColor = item.status.tagcolor
        tagLabel.text = item.statusDisplayStr
        
        ahoraButton.text = item.status.buttonTitle
        ahoraButton.textColor = item.status.buttonTitleColor
        ahoraButton.backgroundColor = item.status.buttonTitleBgColor
        
        orderStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        let amountText = item.loanAmount.formattedNumber()
        let loanAmountTitle = "Monto a pagar: S/\(amountText)"
        let v1 = TitleValueView(frame: .zero, title: loanAmountTitle, value: "S/\(amountText)")
        orderStackView.addArrangedSubview(v1)
        
        let repayDateStr = item.repayDateStr ?? ""
        let repayDateStrTitle = "Monto a pagar: S/\(repayDateStr)"
        let v2 = TitleValueView(frame: .zero, title: repayDateStrTitle, value: "S/\(repayDateStr)")
        orderStackView.addArrangedSubview(v2)
        
    }
    
    @objc func confirmAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        onConfirmToggle?(sender.isSelected)
    }
    
}
