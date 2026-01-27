//
//  ConfirmLoanTableViewCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//

import UIKit
import Foundation

struct ConfirmLoanItemModel: IdentifiableTableItem {
    let identifier: String = "ConfirmLoanItemModel"
    let uuid = UUID().uuidString
    let item: LoanProductItem
    var isOnlyOne: Bool = false
    var onSelected: ((String, Bool) -> Void)?
}

extension ConfirmLoanItemModel: PrestamoRowConvertible {
    func toRow(action: ((ConfirmLoanItemModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<ConfirmLoanItemModel, ConfirmLoanTableViewCell>(item: self, didSelectAction: action)
    }
}

class ConfirmLoanTableViewCell: BaseConfigurablewCell {
    private var buttonTapHandler: ((Bool) -> Void)?
    private var confirmLoan: ConfirmLoanItemModel?
    
    // 1. 白色卡片背景
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    // 2. 顶部产品图标
    private lazy var productIcon: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    // 3. 产品名称
    private lazy var productNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = AppFontProvider.shared.getFont16Semibold()
        return label
    }()
    
    // 4. 右侧勾选框 (灰色的圆圈勾选框)
    private let checkIcon: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pre_pro_disable"), for: .normal)
        button.setImage(UIImage(named: "pre_pro_enable"), for: .selected)
        return button
    }()
    
    // 5. 分割线
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#EEEEEE")
        return view
    }()

    // 6. 详情 StackView (原本已有的)
    private lazy var itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    // MARK: - 布局设置
    override func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(productIcon)
        containerView.addSubview(productNameLabel)
        containerView.addSubview(checkIcon)
        containerView.addSubview(lineView)
        containerView.addSubview(itemsStackView)
        
        checkIcon.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        productIcon.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        productNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(productIcon)
            make.leading.equalTo(productIcon.snp.trailing).offset(10)
        }
        
        checkIcon.snp.makeConstraints { make in
            make.centerY.equalTo(productIcon)
            make.trailing.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(productIcon.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(1)
        }
        
        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    @objc func updateStatus(_ sender: UIButton) {
        if confirmLoan?.isOnlyOne == false {
            sender.isSelected.toggle()
        }
        buttonTapHandler?(sender.isSelected)
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let loanItem = item as? ConfirmLoanItemModel else { return }
        confirmLoan = loanItem
        var model = loanItem.item
        
        // 设置基本信息
        productNameLabel.text = model.productName
        productIcon.loadImage(model.productLogo)
        
        buttonTapHandler = { isSelected in
            model.isSelected = isSelected
            loanItem.onSelected?(loanItem.uuid, isSelected)
        }
        checkIcon.isSelected = model.isSelected
        
        // 清理 StackView 防止复用重叠
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 1. Límite de préstamo (额度范围)
        let loanLimit: String
        if model.rates.minLoanAmount == model.rates.maxLoanAmount {
            loanLimit = model.rates.minLoanAmount
        } else {
            loanLimit = "\(model.rates.minLoanAmount)  -  \(model.rates.maxLoanAmount)"
        }
        addCommonItem(title: "Límite de préstamo", value: loanLimit, isPrimary: true)
        
        // 2. Tipo interés diario (日利率)
        addCommonItem(title: "Tipo interés diario", value: "\(model.rates.dailyInterestRate)%")
        
        // 3. Plazo del préstamo (借款期限)
        let duration: String
        if model.rates.minLoanDay == model.rates.maxLoanDay {
            duration = "\(model.rates.minLoanDay)días"
        } else {
            duration = "\(model.rates.minLoanDay)–\(model.rates.maxLoanDay)días"
        }
        addCommonItem(title: "Plazo del préstamo", value: duration)
    }
        
    private func addCommonItem(title: String, value: String, isPrimary: Bool = false) {
        let valueColor = isPrimary ? AppColorStyle.shared.brandPrimary : UIColor(hex: "#333333")
        let view = PrestamoCommonItemView(title: title,
                                          value: value,
                                          valueColor: valueColor)
        itemsStackView.addArrangedSubview(view)
    }
}
