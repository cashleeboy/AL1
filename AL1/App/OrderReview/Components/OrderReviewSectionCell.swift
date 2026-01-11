//
//  OrderReviewSectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/23.
//

import UIKit

struct OrderReviewItem: IdentifiableTableItem {
    let identifier: String = "OrderReviewCell"
    // 可以根据需要增加属性，如：title, subTitle, buttonTitle 等
    let title: String = "Su solicitud está en revisión. Por favor espere con paciencia."
    
    let contactarHandler: (() -> Void)

}

class OrderReviewCell: BaseConfigurablewCell {
    
    var orderReviceItem: OrderReviewItem?
    
    // MARK: - UI Components
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "empty_funding"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Su solicitud está en revisión. Por favor espere con paciencia."
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "El tiempo de revisión es de 1 a 5 minutos."
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = UIColor(hex: "#333333")
        label.textAlignment = .center
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.text = "Una vez aprobada la solicitud de préstamo, el préstamo se transferirá a su cuenta."
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#333333")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Contactar con Servicio al Cliente", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont16Bold()
        button.backgroundColor = AppColorStyle.shared.brandPrimary // 假设为橙色
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(contactarAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Setup
    
    override func setupViews() {
        super.setupViews()
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        contentView.addSubview(contentStackView)
        
        // 构建 UI 树
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.setCustomSpacing(40, after: iconImageView) // 图标下方间距较大
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.setCustomSpacing(50, after: titleLabel) // 标题与审核时间之间间距较大
        
        contentStackView.addArrangedSubview(timeLabel)
        contentStackView.setCustomSpacing(10, after: timeLabel)
        
        contentStackView.addArrangedSubview(detailLabel)
        contentStackView.setCustomSpacing(40, after: detailLabel)
        
        contentStackView.addArrangedSubview(confirmButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 86, height: 86))
        }
        
        confirmButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview() 
        }
    }
    
    @objc func contactarAction() {
        orderReviceItem?.contactarHandler()
    }
    
    // 如果有数据配置逻辑，可以在这里实现
    override func configure(with item: TableItemProtocol) {
        guard let reviewItem = item as? OrderReviewItem else { return }
        orderReviceItem = reviewItem
        
        titleLabel.text = reviewItem.title
    }
}
