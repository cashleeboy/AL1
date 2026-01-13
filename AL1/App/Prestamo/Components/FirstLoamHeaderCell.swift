//
//  FirstLoamHeaderCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit
import SnapKit

struct FirstLoamHeaderModel: IdentifiableTableItem {
    let identifier: String = "FirstLoamHeaderCell"
    var loanInfoModel: LoanInfoModel
    var bankModel: BankModel?
    // bank info
    var bankInfoPopupAction: (() -> Void)
    
    // 综合服务,还款明细弹窗
    var serviceRepaymentPopupAction: ((String, [String], [String], Bool) -> Void)
}


extension FirstLoamHeaderModel: PrestamoRowConvertible {
    func toRow(action: ((FirstLoamHeaderModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<FirstLoamHeaderModel, FirstLoamHeaderCell>(item: self, didSelectAction: action)
    }
}

class FirstLoamHeaderCell: BaseConfigurablewCell {
    
    private lazy var topBackgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "first_mask_group")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private lazy var whiteCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Importe disponible"
        label.font = AppFontProvider.shared.getFont14Regular()
        label.textColor = AppColorStyle.shared.textGray66
        label.textAlignment = .center
        return label
    }()
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.text = "S/ "
        label.font = AppFontProvider.shared.getFont30Bold()
        label.textColor = AppColorStyle.shared.textBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var fechaIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "info_orange_icon"))
        return iv
    }()
    private lazy var fechaLabel: UILabel = {
        let label = UILabel()
        label.text = "Fecha de llegada estimada "
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = AppColorStyle.shared.brandPrimary
        label.textAlignment = .center
        return label
    }()
    private lazy var lineView: UIView = {
        let view = UIView()
        // 这里可以使用之前提到的虚线绘制方法，或者简单用背景色
        view.backgroundColor = AppColorStyle.shared.textGrayD9
        return view
    }()
    
    private lazy var itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - 布局设置
    override func setupViews() {
        contentView.addSubview(topBackgroundImage)
        contentView.addSubview(whiteCardView)
        
        whiteCardView.addSubview(titleLabel)
        whiteCardView.addSubview(valueLabel)
        
        let fechaStack = UIStackView(arrangedSubviews: [fechaIcon, fechaLabel])
        fechaStack.spacing = 4
        fechaStack.alignment = .center
        whiteCardView.addSubview(fechaStack)
        
        whiteCardView.addSubview(lineView)
        whiteCardView.addSubview(itemsStackView)
        
        // MARK: - Constraints
        topBackgroundImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(180) // 背景图高度
        }
        
        whiteCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120) // 露出顶部背景
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        fechaStack.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        fechaIcon.snp.makeConstraints { make in
            make.size.equalTo(13)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(fechaStack.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
        
        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    
    // MARK: - CellConfigurable 协议实现
    override func configure(with item: any TableItemProtocol) {
        guard let firstItem = item as? FirstLoamHeaderModel else { return }
        
        let info = firstItem.loanInfoModel
        
        valueLabel.text = "S/ \(info.loanAmount)"
        // 遍历 totalDays
        let totalSum = info.products.compactMap { $0.totalDays }.sum()
        if let repayDate = info.products.first?.repayDate, !repayDate.isEmpty {
            fechaLabel.text = "Plazo del préstamo：\(totalSum) días"
        }
        
        // 重要：复用时清空 StackView
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 1. 银行账户
        let v1 = PrestamoCommonItemView(title: "Cuenta bancaria receptora",
                                        value: firstItem.bankModel?.bankCardNo ?? info.bankCardNo,
                                        valueColor: AppColorStyle.shared.textBlack)
        v1.showArrow()
        v1.onValueClick = {
            firstItem.bankInfoPopupAction()
        }
        itemsStackView.addArrangedSubview(v1)
        
        // 2. 借款金额
        let v2 = PrestamoCommonItemView(title: "Cantidad real recibida",
                                        value: "$\(info.receiptAmount)",
                                        valueColor: AppColorStyle.shared.textBlack)
        itemsStackView.addArrangedSubview(v2)
        
        // 3. 综合服务费 (带问号提示)
        let compServiceFee = info.products.sum(for: \.compServiceFee)
        let v3 = PrestamoCommonItemView(title: "Tarifa de servicio integral",
                                        value: "$\(compServiceFee)")
        v3.setValueColor(AppColorStyle.shared.brandPrimary)
        v3.showQuestionIcon(color: AppColorStyle.shared.brandPrimary)
        v3.onValueClick = {
            let feeDetails = info.products.compactMap { model in
                model.feeDetail
            }
            //let interest = feeDetails.sum(for: \.interest)
            let creditServiceFee = feeDetails.sum(for: \.creditServiceFee)
            let payChannelFee = feeDetails.sum(for: \.payChannelFee)
            let serviceFee = feeDetails.sum(for: \.serviceFee)
            let taxation = feeDetails.sum(for: \.taxation)
            
            let rawData: [(title: String, value: String)] = [
                //("Interés", "$\(interest)"),
                ("Honorarios de crédito", "$\(creditServiceFee)"),
                ("Pagar tarifa de acceso", "$\(payChannelFee)"),
                ("Comisión", "$\(serviceFee)"),
                ("IVA", "$\(taxation)")
            ]
            let titles = rawData.map { $0.title }
            let values = rawData.map { $0.value }
            firstItem.serviceRepaymentPopupAction("Tarifa de servicio integral", titles, values, false)
        }
        itemsStackView.addArrangedSubview(v3)
        
        // 4. 利息
        let interest = info.products.sumString(for: \.interest) // "" -> "0", "1.5" -> "1.5"
        let v4 = PrestamoCommonItemView(title: "Interés",
                                        value: "$\(interest)",
                                        valueColor: AppColorStyle.shared.textBlack)
        itemsStackView.addArrangedSubview(v4)
        
        // 5. 还款明细
        let repaymentAmount = info.products.sum(for: \.repaymentAmount)
        let v5 = PrestamoCommonItemView(title: "Monto Pagado",
                                        value: "$\(repaymentAmount)")
        v5.setValueColor(AppColorStyle.shared.brandPrimary)
        v5.showArrow(color: AppColorStyle.shared.brandPrimary)
        v5.onValueClick = {
            let titles = [
                "Cantidad real recibida",       // 实际收到金额
                "Tarifa de servicio integral",
                "Interés",
                "Cantidad pagable"]
            
            let receiptAmount = info.products.sum(for: \.receiptAmount)
            let values = [
                "$\(receiptAmount)",
                "$\(compServiceFee)",
                "$\(interest)",
                "$\(repaymentAmount)"
            ]
            firstItem.serviceRepaymentPopupAction("Detalles de la cantidad de reembolso", titles, values, true)
        }
        itemsStackView.addArrangedSubview(v5)
    }
    
}
