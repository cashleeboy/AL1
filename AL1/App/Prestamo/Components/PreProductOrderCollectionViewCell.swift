//
//  PreProductOrderCollectionViewCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit
import SnapKit


class PreProductOrderView: UIView
{
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFF9F1") // 根据图片，背景略带浅米色
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "card_icon") // 替换为您的实际图标名
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorStyle.shared.textBlack33 // 深色标题
        label.font = AppFontProvider.shared.getFont12Regular() // 标题字体稍大
        return label
    }()
    
    private lazy var ahoraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(AppColorStyle.shared.textBlack33, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont16Medium()
        // 设置右侧箭头图标
        let arrowImage = UIImage(named: "common_right_arrow")?.withRenderingMode(.alwaysTemplate)
        button.setImage(arrowImage, for: .normal)
        button.tintColor = AppColorStyle.shared.textBlack33
        button.semanticContentAttribute = .forceRightToLeft // 图片在右侧
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()
    
    // 两个并排的子项视图
    private lazy var priceSubView = createSubInfoView()
    private lazy var countSubView = createSubInfoView()
    
    // MARK: - 初始化
    
    init(item: PrestamoProductOrderItem) {
        super.init(frame: .zero)
        setupViews()
        configure(with: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(ahoraButton)
        containerView.addSubview(priceSubView)
        containerView.addSubview(countSubView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(0) // 外部边距
        }
        
        // 顶部元素
        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.size.equalTo(32)
        }
        
        // 状态标题
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalTo(iconImageView)
        }
        
        // 右侧操作按钮
        ahoraButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(iconImageView)
        }
        
        // 左下方子项 (Monto pagado)
        priceSubView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.top.equalTo(iconImageView.snp.bottom).offset(20)
                make.bottom.equalToSuperview().offset(-16) // 这个约束非常重要，决定了卡片的高度
            }
        
        // 右下方子项 (Número de pedidos)
        countSubView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(priceSubView)
            make.bottom.equalTo(priceSubView)
            make.width.equalTo(priceSubView)
        }
    }
    
    // MARK: - 逻辑与填充
    
    func configure(with item: PrestamoProductOrderItem) {
        titleLabel.text = item.title
        ahoraButton.setTitle(item.type, for: .normal)
        
        // 填充金额视图
        if let title = priceSubView.subviews.first as? UILabel,
           let value = priceSubView.subviews.last as? UILabel {
            title.text = item.priceText
            value.text = item.price
            value.font = AppFontProvider.shared.getFont12Medium() // 金额数字大且加粗
        }
        
        // 填充数量视图
        if let title = countSubView.subviews.first as? UILabel,
           let value = countSubView.subviews.last as? UILabel {
            title.text = item.countText
            value.text = item.count
            value.font = AppFontProvider.shared.getFont12Medium()
        }
    }
    
    // MARK: - 辅助方法：创建子信息视图
    
    private func createSubInfoView() -> UIView {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.textColor = AppColorStyle.shared.textBlack50 // 浅灰色标签
        titleLabel.font = AppFontProvider.shared.getFont12Regular()
        view.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.textColor = AppColorStyle.shared.textBlack33 // 深色数值
        valueLabel.font = AppFontProvider.shared.getFont12Regular()
        view.addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return view
    }
}


class PreProductOrderCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI 组件
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFF9F1") // 浅米色背景
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "product_clock_icon") // 需替换为实际图片名
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pedido pendiente"
        label.textColor = UIColor(hex: "#252525")
        label.font = AppFontProvider.shared.getFont18Bold() // 标题加粗加大
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Monto del préstamo"
        label.textColor = UIColor(hex: "#656676")
        label.font = AppFontProvider.shared.getFont12Medium()
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = "$2,0000"
        label.textColor = UIColor(hex: "#121221")
        label.font = AppFontProvider.shared.getFont18Bold()
        return label
    }()
    
    private lazy var ahoraButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("verificar", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont12Medium()
        button.backgroundColor = UIColor(hex: "#F58D43") // 橙色背景
        button.layer.cornerRadius = 15
        
        // 添加右侧小箭头
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let arrow = UIImage(systemName: "chevron.right", withConfiguration: config)
        button.setImage(arrow, for: .normal)
        button.tintColor = .white
        
        // 图片在文字右侧显示
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        return button
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局逻辑
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(ahoraButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14)
            make.size.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.top.equalTo(iconImageView.snp.top).offset(2)
            make.trailing.lessThanOrEqualTo(ahoraButton.snp.leading).offset(-10)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(subTitleLabel.snp.trailing).offset(8)
            make.centerY.equalTo(subTitleLabel)
        }
        
        ahoraButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalTo(iconImageView.snp.top)
            make.width.equalTo(84)
            make.height.equalTo(30)
        }
    }
    
    /// 供外部调用的数据填充方法
    func configure(with item: PrestamoProductOrderItem) {
        titleLabel.text = item.title
        subTitleLabel.text = "Monto del préstamo" // 或者是 item.priceText
        amountLabel.text = item.price
        ahoraButton.setTitle("verificar", for: .normal)
        
        // 根据业务逻辑动态修改颜色或图标
        // iconImageView.image = UIImage(named: item.iconName)
    }
}
