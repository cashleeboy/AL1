//
//  PrestamoHeaderSelectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import UIKit
import SnapKit
import Foundation
import SkeletonView

struct PrestamoHome: IdentifiableTableItem {
    let identifier: String = "PrestamoHeaderSelectionCell"
    
    // 基础配置
    let title: String = "Monto hasta"
    let buttonTitle: String = "Solicitar Ahora"
    
    // 动态数值
    var value: String?
    var marketLoanDays: String?
    
    var bottomTitle: String {
        guard let marketLoanDays else {
            return "Plazo del préstamo - meses"
        }
        return "Plazo del préstamo \(marketLoanDays) meses"
    }
    var solicitarAhoraAction: (() -> Void)
    
    // 完善初始化器
    init(value: String? = nil, marketLoanDays: String? = nil, solicitarAhoraAction: @escaping () -> Void) {
        self.value = value
        self.marketLoanDays = marketLoanDays
        self.solicitarAhoraAction = solicitarAhoraAction
    }
}

extension PrestamoHome: PrestamoRowConvertible {
    func toRow(action: ((PrestamoHome) -> Void)?) -> RowRepresentable {
        return ConcreteRow<PrestamoHome, PrestamoHeaderSelectionCell>(item: self, didSelectAction: action)
    }
}

class PrestamoHeaderSelectionCell: BaseConfigurablewCell {
    private var buttonTapHandler: ButtonAction?
    
    private let topBackgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "prestamo_top_BG")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let BackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont18Semibold()
        label.textColor = AppColorStyle.shared.texBlack33
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont50Bold()
        label.textColor = AppColorStyle.shared.textBlack
        label.textAlignment = .center
//        label.isSkeletonable = true
//        label.linesCornerRadius = 10
//        label.lastLineFillPercent = 100
//        label.skeletonTextLineHeight = .fixed(40)
//        label.showAnimatedSkeleton()
        return label
    }()
    
    private let confirmButton: UIButton = {
        let label = UIButton()
        label.layer.cornerRadius = 10
        label.backgroundColor = AppColorStyle.shared.brandPrimary
        label.titleLabel?.font = AppFontProvider.shared.getFont18Semibold()
        label.setTitleColor(AppColorStyle.shared.backgroundWhite, for: .normal)
        return label
    }()
    
    private let bottomTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.textBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc func didTapConfirmButton() {
        buttonTapHandler?()
    }
    
    // MARK: - 布局设置
    override func setupViews() {
        contentView.addSubview(topBackgroundImage)
        contentView.addSubview(BackgroundView)
        
        BackgroundView.addSubview(titleLabel)
        BackgroundView.addSubview(valueLabel)
        BackgroundView.addSubview(confirmButton)
        BackgroundView.addSubview(bottomTitleLabel)
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        let cardHorizontalPadding: CGFloat = 17 // 卡片左右边距
        let cardBottomMargin: CGFloat = 10      // 卡片底部边距
        let internalPadding: CGFloat = 30       // 卡片内部上下间距
        let verticalSpacing: CGFloat = 15       // 内部组件间距
        let buttonHeight: CGFloat = 50          // 按钮高度
        
        // 1. topBackgroundImage: 铺满 Cell 顶部
        topBackgroundImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(280) 
        }
        
        // 2. BackgroundView (白色圆角卡片)
        BackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(cardHorizontalPadding)
            make.trailing.equalToSuperview().offset(-cardHorizontalPadding)
            make.bottom.equalToSuperview().offset(-cardBottomMargin)
            make.top.equalTo(topBackgroundImage.snp.bottom).offset(-90)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(internalPadding)
            make.leading.trailing.equalTo(BackgroundView).inset(40)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.leading.trailing.equalTo(BackgroundView).inset(40)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(buttonHeight)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        bottomTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-internalPadding)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        BackgroundView.layer.masksToBounds = true
        confirmButton.layer.masksToBounds = true
    }
    
    
    // MARK: - CellConfigurable 协议实现
    
    override func configure(with item: any TableItemProtocol) {
        guard let homeItem = item as? PrestamoHome else { return }
        
        titleLabel.text = homeItem.title
        valueLabel.text = homeItem.value
        confirmButton.setTitle(homeItem.buttonTitle, for: .normal)
        bottomTitleLabel.text = homeItem.bottomTitle
        self.buttonTapHandler = homeItem.solicitarAhoraAction
    }
}
