//
//  PrestamoProductCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

struct PrestamoProductItem: IdentifiableTableItem {
    let identifier: String = "PrestamoProductCell"
    let uuid = UUID().uuidString
    var productModel: LoanProductModel
    var isSelected: Bool = false
    var onSelected: ((String, Bool) -> Void)?
}

extension PrestamoProductItem: PrestamoRowConvertible {
    func toRow(action: ((PrestamoProductItem) -> Void)?) -> RowRepresentable {
        return ConcreteRow<PrestamoProductItem, PrestamoProductCell>(item: self, didSelectAction: action)
    }
}


class PrestamoProductCell: BaseConfigurablewCell {
    private var buttonTapHandler: ((Bool) -> Void)?
    
    private let BackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pre_pro_icon")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont18Semibold() // 较小字体
        label.textColor = AppColorStyle.shared.texBlack33 // 次要颜色
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pre_pro_disable"), for: .normal)
        button.setImage(UIImage(named: "pre_pro_enable"), for: .selected)
        return button
    }()
    
    private let itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - 布局设置
    
    override func setupViews() {
        contentView.addSubview(BackgroundView)
        BackgroundView.addSubview(iconImageView)
        BackgroundView.addSubview(titleLabel)
        BackgroundView.addSubview(statusButton)
        BackgroundView.addSubview(itemsStackView)
        
        statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
        
        let cardHorizontalPadding: CGFloat = 17
        let cardVerticalPadding: CGFloat = 10
        let internalPadding: CGFloat = 20
        let iconSize: CGFloat = 22
        
        // 1. BackgroundView (白色圆角卡片)
        BackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(cardHorizontalPadding)
            make.trailing.equalToSuperview().offset(-cardHorizontalPadding)
            make.top.equalToSuperview().offset(cardVerticalPadding)
            make.bottom.equalToSuperview().offset(-cardVerticalPadding)
        }
        
        // 2. iconImageView
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(internalPadding)
            make.leading.equalToSuperview().offset(internalPadding)
            make.size.equalTo(iconSize)
        }
        
        // 3. titleLabel (位于图标右侧，垂直居中)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            // 确保标题不会跑到状态图下方，给状态图留出空间
            make.trailing.equalTo(statusButton.snp.leading).offset(-10)
        }
        
        // 4. statusImageView (右上角)
        statusButton.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.trailing.equalToSuperview().offset(-internalPadding)
            // 假设状态图是固定的 V 标志
            make.size.equalTo(iconSize)
        }
        
        // 5. itemsStackView
        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(internalPadding)
            make.leading.equalToSuperview().offset(internalPadding)
            make.trailing.equalToSuperview().offset(-internalPadding)
            // 核心：约束 StackView 底部到 BackgroundView 底部，以撑开 Cell 高度
            make.bottom.equalToSuperview().offset(-internalPadding)
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let productItem = item as? PrestamoProductItem else { return }
        
        titleLabel.text = productItem.productModel.productName
        iconImageView.loadImage(productItem.productModel.productLogo, placeholder: UIImage(named: "pre_pro_icon"))
        
        // 2. 清除并重新添加 StackView 子项
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if !productItem.productModel.loanAmount.isEmpty {
            let itemView = PrestamoCommonItemView.init(title: "Monto del préstamo", value: productItem.productModel.loanAmount)
            itemsStackView.addArrangedSubview(itemView)
        }
        if !productItem.productModel.daysPerTerm.isEmpty {
            let itemView = PrestamoCommonItemView.init(title: "Plazo del préstamo",
                                                       value: productItem.productModel.daysPerTerm,
                                                       valueColor: UIColor(hex: "#141635")
            )
            itemsStackView.addArrangedSubview(itemView)
        }
        
        buttonTapHandler = { isSelected in
            productItem.onSelected?(productItem.uuid, isSelected)
        }
        statusButton.isSelected = productItem.isSelected
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 确保圆角裁剪生效
        BackgroundView.layer.masksToBounds = true
    }
    
    @objc func updateStatus(_ sender: UIButton) {
        sender.isSelected.toggle()
        buttonTapHandler?(sender.isSelected)
    }
}
