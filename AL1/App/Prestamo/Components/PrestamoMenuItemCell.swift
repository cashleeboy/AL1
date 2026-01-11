//
//  PrestamoMenuItemCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

struct PrestamoMenuItem: TableItemProtocol {
    let identifier: String = "PrestamoMenuItemCell"
    let title: String = "Obtenga un préstamo rápidamente"
    let items: [PrestamoMenuSubItem] = [
        PrestamoMenuSubItem(iconName: "home_menu_icon_1", title: "Solicitar ahora"),
        PrestamoMenuSubItem(iconName: "home_menu_icon_2", title: "Confirmar pedido"),
        PrestamoMenuSubItem(iconName: "home_menu_icon_3", title: "Recibir dinero")
    ]
}

extension PrestamoMenuItem: PrestamoRowConvertible {
    func toRow(action: ((PrestamoMenuItem) -> Void)?) -> RowRepresentable {
        return ConcreteRow<PrestamoMenuItem, PrestamoMenuItemCell>(item: self, didSelectAction: action)
    }
}

struct PrestamoMenuSubItem: TableItemProtocol {
    let identifier: String = UUID().uuidString
    let iconName: String
    let title: String
}


class PrestamoMenuItemCell: BaseConfigurablewCell {
    
    private let BackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 顶部标题 Label (例如: "Nivel educativo")
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.texBlack33
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // ⭐️ 新增：用于水平布局三个子项的 StackView
    private let itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    // MARK: - 布局设置
    
    override func setupViews() {
        contentView.addSubview(BackgroundView)
        
        BackgroundView.addSubview(titleLabel)
        BackgroundView.addSubview(itemsStackView)
        BackgroundView.addSubview(titleStackView)
        
        let cardHorizontalPadding: CGFloat = 17 // 卡片左右边距
        let internalPadding: CGFloat = 20       // 卡片内部上下间距

        BackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(cardHorizontalPadding)
            make.trailing.equalToSuperview().offset(-cardHorizontalPadding)
            make.bottom.equalToSuperview().offset(0)
            make.top.equalTo(contentView.snp.top).offset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(internalPadding)
            make.centerX.equalToSuperview()
        }
        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(internalPadding)
            make.leading.equalToSuperview().offset(internalPadding)
            make.trailing.equalToSuperview().offset(-internalPadding)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalTo(itemsStackView.snp.bottom).offset(internalPadding)
            // 左右留出内边距
            make.leading.equalToSuperview().offset(internalPadding)
            make.trailing.equalToSuperview().offset(-internalPadding)
            
            // ⭐️ 核心：约束 StackView 底部到 BackgroundView 底部，以撑开 Cell 高度
            make.bottom.equalToSuperview().offset(-internalPadding)
        }

    }
    
    @objc func onSliderChange() {
        
    }
    
    override func configure(with item: any TableItemProtocol) {
        guard let homeItem = item as? PrestamoMenuItem else { return }
        titleLabel.text = homeItem.title
        
        // 移除旧的子项视图，避免重用问题
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        titleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 动态添加子项视图
        for (index, subItem) in homeItem.items.enumerated() {
            let itemView = createMenuIconItem(for: subItem)
            itemsStackView.addArrangedSubview(itemView)
            let titleItemview = createMenuTitleItem(for: subItem)
            titleStackView.addArrangedSubview(titleItemview)
            
            // 增加箭头间隔符 (除了最后一个子项)
            if index < homeItem.items.count - 1 {
                let arrowView = createArrowView()
                itemsStackView.addArrangedSubview(arrowView)
                
                arrowView.snp.makeConstraints { make in
                    make.height.equalTo(15)
                }
            }
        }
    }
    
    private func createMenuIconItem(for item: PrestamoMenuSubItem) -> UIView {
        let container = UIView()
        
        let iconView = UIImageView()
        // 假设图片名可以获取到图片
        iconView.image = UIImage(named: item.iconName)
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)
        
        // 使用 SnapKit 布局内部
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48) 
            make.bottom.equalToSuperview()
        }
        return container
    }
    
    private func createMenuTitleItem(for item: PrestamoMenuSubItem) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = item.title
        label.font = AppFontProvider.shared.getFont12Regular() // 使用小字体
        label.textColor = AppColorStyle.shared.texBlack37
        label.textAlignment = .center
        label.numberOfLines = 2
        container.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return container
    }
    
    private func createArrowView() -> UIImageView {
        let arrow = UIImageView(image: UIImage(named: "prestamo_right_arrow"))
        arrow.tintColor = .lightGray
        arrow.contentMode = .scaleAspectFit
        return arrow
    }
}
