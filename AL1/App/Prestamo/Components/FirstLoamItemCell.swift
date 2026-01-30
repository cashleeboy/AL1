//
//  FirstLoamItemCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit

struct FirstLoamItemModel: IdentifiableTableItem {
    let identifier: String = "FirstLoamItemCell"
    let uuid: String = UUID().uuidString
    
    var loanInfoModel: LoanProductModel
    var isSelected: Bool
    var isOnlyOne: Bool = false
    var onSelected: ((String, Bool, [String: String]) -> Void)?
}

extension FirstLoamItemModel: PrestamoRowConvertible {
    func toRow(action: ((FirstLoamItemModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<FirstLoamItemModel, FirstLoamItemCell>(item: self, didSelectAction: action)
    }
}

class FirstLoamItemCell: BaseConfigurablewCell {
    private var buttonTapHandler: ((Bool) -> Void)?
    private var firstLoan: FirstLoamItemModel?
    
    private lazy var whiteCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Regular()
        label.textColor = AppColorStyle.shared.textGray66
        label.textAlignment = .center
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.textGrayDF
        return view
    }()
    // 左侧：金额信息容器
    private lazy var amountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Monto del préstamo"
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#9FA2B1")
        return label
    }()
    private lazy var amountValueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont18Semibold()
        label.textColor = AppColorStyle.shared.textBlack
        return label
    }()
    
    // 右侧：期限信息容器
    private lazy var termTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fecha de Pago"
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#9FA2B1")
        return label
    }()
    
    private lazy var termValueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont18Semibold()
        label.textColor = AppColorStyle.shared.textBlack
        return label
    }()
    
    private let statusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pre_pro_disable"), for: .normal)
        button.setImage(UIImage(named: "pre_pro_enable"), for: .selected)
        return button
    }()
    
    
    @objc func checkAction(_ sender: UIButton) {
        if firstLoan?.isOnlyOne == false {
            sender.isSelected.toggle()
        }
        buttonTapHandler?(sender.isSelected)
    }
    
    // MARK: - 布局设置
    override func setupViews() {
        contentView.addSubview(whiteCardView)
        whiteCardView.addSubview(iconImageView)
        whiteCardView.addSubview(titleLabel)
        whiteCardView.addSubview(lineView)
        
        whiteCardView.addSubview(amountTitleLabel)
        whiteCardView.addSubview(amountValueLabel)
        
        whiteCardView.addSubview(termTitleLabel)
        whiteCardView.addSubview(termValueLabel)
        
        whiteCardView.addSubview(statusButton)
        statusButton.addTarget(self, action: #selector(checkAction(_:)), for: .touchUpInside)
        
        // MARK: - Constraints
        whiteCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(1)
        }
        
        // 金额布局
        amountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
        }
        
        amountValueLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(amountTitleLabel)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        // 期限布局
        termTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTitleLabel)
            make.leading.equalTo(whiteCardView.snp.centerX).offset(-20)
        }
        
        termValueLabel.snp.makeConstraints { make in
            make.top.equalTo(amountValueLabel)
            make.leading.equalTo(termTitleLabel)
        }
        
        statusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let loanItem = item as? FirstLoamItemModel else { return }
        firstLoan = loanItem
        
        iconImageView.loadImage(loanItem.loanInfoModel.productLogo, placeholder: UIImage(named: "pre_pro_icon"))
        titleLabel.text = loanItem.loanInfoModel.productName
        
        amountValueLabel.text = loanItem.loanInfoModel.loanAmount.formattedNumber(prefix: "S/")
        // 还款日期
        termValueLabel.text = loanItem.loanInfoModel.repayDate
        
        let isOnlyOne = loanItem.isOnlyOne
        statusButton.isSelected = isOnlyOne ? true : loanItem.isSelected

        buttonTapHandler = { isSelected in
            let params: [String: String] = loanItem.loanInfoModel.fetchComfirmLoan()
            loanItem.onSelected?(loanItem.uuid, isSelected, params)
        }
    }
}
