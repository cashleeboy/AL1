//
//  ConfigurarSelectionCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/25.
//

import UIKit
import SnapKit

enum ConfigurarType {
    case cache
    case version
    
    var display: String {
        switch self {
        case .cache:
            "limpiar cache"
        case .version:
            "Versión actual"
        }
    }
    
    var icon: String {
        switch self {
        case .cache:
            "configurar_cache_icon"
        case .version:
            "configurar_version_icon"
        }
    }
}

struct ConfigurarSelectionModel: IdentifiableTableItem {
    var identifier: String = "ConfigurarSelectionCell"
    
    var type: ConfigurarType
    // 动态获取右侧显示的文本值
    var rightDetailValue: String? {
        switch type {
        case .cache:
            // 这里可以调用你的缓存管理工具获取大小，例如 "12.5 MB"
            return nil
        case .version:
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            return "V\(version)"
        }
    }
    
    // 逻辑控制：只有清除缓存需要显示箭头
    var shouldShowArrow: Bool {
        return type == .cache
    }
    
    var onContainerTap: (() -> Void)?
}

extension ConfigurarSelectionModel: PrestamoRowConvertible {
    func toRow(action: ((ConfigurarSelectionModel) -> Void)?) -> RowRepresentable {
        return ConcreteRow<ConfigurarSelectionModel, ConfigurarSelectionCell>(item: self, didSelectAction: action)
    }
}

class ConfigurarSelectionCell: BaseConfigurablewCell {
    var onContainerTap: (() -> Void)?
    // 背景卡片视图
    private let containerView: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = 12 // 根据图片调整圆角
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        return view
    }()
    
    private let iconImageView = UIImageView()
    
    private let leftTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Regular()
        label.textColor = UIColor(hex: "#484747")
        return label
    }()
    
    private let rightLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#A5A5A5")
        label.textAlignment = .right
        return label
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icn_right_point")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
        
    @objc func containerAction() {
        onContainerTap?()
    }
    
    override func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .clear // 确保背景透明显示卡片效果
        
        contentView.addSubview(containerView)
        containerView.addTarget(self, action: #selector(containerAction), for: .touchUpInside)
        containerView.addSubview(iconImageView)
        containerView.addSubview(leftTitleLabel)
        containerView.addSubview(rightLabel)
        containerView.addSubview(rightImageView)
        
        // MARK: - SnapKit 布局
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(56).priority(.high) // 固定高度或最小高度
        }
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        rightLabel.snp.makeConstraints { make in
            make.right.equalTo(rightImageView.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftTitleLabel.snp.right).offset(10)
        }
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let model = item as? ConfigurarSelectionModel else { return }
        onContainerTap = model.onContainerTap
        
        // 基础填充
        iconImageView.image = UIImage(named: model.type.icon)
        leftTitleLabel.text = model.type.display
        
        // 右侧逻辑处理
        let detailValue = model.rightDetailValue
        rightLabel.text = detailValue
        rightLabel.isHidden = (detailValue == nil)
        
        // 箭头显示处理
        rightImageView.isHidden = !model.shouldShowArrow
        
        // 布局动态微调：如果没有箭头，文字靠最右
        if model.shouldShowArrow {
            rightLabel.snp.remakeConstraints { make in
                make.right.equalTo(rightImageView.snp.left).offset(-8)
                make.centerY.equalToSuperview()
            }
        } else {
            rightLabel.snp.remakeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
        }
    }
}
