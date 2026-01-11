//
//  AddBankCardTableViewCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import UIKit
import SnapKit

class AddBankCardTableViewCell: BaseTableViewCell {

    // 背景卡片，用于绘制虚线
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // 虚线图层
    private let dashBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = AppColorStyle.shared.brandPrimary.cgColor
        layer.fillColor = nil
        layer.lineDashPattern = [4, 2] // 虚线长度 4，间隔 2
        layer.lineWidth = 1
        return layer
    }()
    
    // 水平堆叠视图，确保图标和文字整体居中
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isUserInteractionEnabled = false
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Añadir Tarjeta Bancaria"
        label.font = AppFontProvider.shared.getFont16Semibold()
        label.textColor = AppColorStyle.shared.brandPrimary
        return label
    }()
    
    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icn_add_bank_icon")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = AppColorStyle.shared.brandPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Lifecycle & Setup
    
    override func setupViews() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(iconImage)
        contentStackView.addArrangedSubview(titleLabel)
        
        containerView.layer.addSublayer(dashBorderLayer)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(36)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(60)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        iconImage.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
    }
    
    // 核心点：在布局改变时更新虚线路径
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorderLayer.frame = containerView.bounds
        let path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16)
        dashBorderLayer.path = path.cgPath
    }
    
}
