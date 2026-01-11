//
//  LoanOrderDetailSectionCell.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import UIKit

struct LoanOrderDetailSectionModel: IdentifiableTableItem {
    let identifier: String = "LoanOrderDetailSectionCell"
    
    // 对应你之前定义的枚举
    let status: OrderStatus
    let statusStr: String      // 主标题 (如: Su solicitud está en revisión)
    let timeHint: String?      // 审核时间提示 (如: El tiempo de revisión es de 1 a 5 minutos)
    let subHintAttributed: NSMutableAttributedString?       // 审核后的操作提示
    // 按钮动作回调
    var onContactService: (() -> Void)?
}

extension LoanOrderDetailSectionModel: PrestamoRowConvertible {
    func toRow(action: ((LoanOrderDetailSectionModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<LoanOrderDetailSectionModel, LoanOrderDetailSectionCell>(item: self, didSelectAction: action)
    }
}


class LoanOrderDetailSectionCell: BaseConfigurablewCell {
    
    // MARK: - UI Components
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        return stack
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        // 默认放一个审核中的图标
        iv.image = UIImage(named: "ic_order_reviewing")
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.textBlack33
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.textBlack33
        label.textAlignment = .center
        return label
    }()
    
    private let subHintLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont13Regular()
        label.textColor = AppColorStyle.shared.textGray94
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = AppColorStyle.shared.brandPrimary
        btn.titleLabel?.font = AppFontProvider.shared.getFont16Semibold()
        btn.layer.cornerRadius = 12
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    private var contactAction: (() -> Void)?

    // MARK: - Setup
    
    override func setupViews() {
        selectionStyle = .none
        
        contentView.addSubview(containerStack)
        containerStack.addArrangedSubview(iconImageView)
        containerStack.addArrangedSubview(titleLabel)
        
        // 增加一个额外的容器处理中间的文案，控制间距
        let hintStack = UIStackView()
        hintStack.axis = .vertical
        hintStack.spacing = 8
        hintStack.alignment = .center
        
        hintStack.addArrangedSubview(timeLabel)
        hintStack.addArrangedSubview(subHintLabel)
        containerStack.addArrangedSubview(hintStack)
        
        contentView.addSubview(actionButton)
        
        // 约束布局
        containerStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview().inset(30)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 102, height: 102))
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(containerStack.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-40) // 撑开 Cell 高度
        }
        
        actionButton.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    
    @objc private func btnAction() {
        contactAction?()
    }

    // MARK: - Configuration
    
    override func configure(with item: any TableItemProtocol) {
        guard let model = item as? LoanOrderDetailSectionModel else { return }
        
        titleLabel.text = model.statusStr
        timeLabel.text = model.timeHint
        subHintLabel.attributedText = model.subHintAttributed
        
        // 根据状态切换图标 (示例逻辑)
        switch model.status {
        case .auditing:
            iconImageView.image = UIImage(named: "empty_funding")
            actionButton.setTitle("Contactar con Servicio al Cliente", for: .normal)
            actionButton.isHidden = false
        case .rejected:
            iconImageView.image = UIImage(named: "empty_funding_fail")
            actionButton.isHidden = true
        default:
            break
        }
        
        contactAction = model.onContactService
        
        // 处理动态显示隐藏
        timeLabel.isHidden = model.timeHint == nil
        subHintLabel.isHidden = model.subHintAttributed == nil
    }
}
