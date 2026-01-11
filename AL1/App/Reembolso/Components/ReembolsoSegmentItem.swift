//
//  ReembolsoSegmentItem.swift
//  AL1
//
//  Created by cashlee on 2026/1/7.
//

import UIKit

class ReembolsoSegmentItem: UIView {
    
    // UI 组件
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .lastBaseline // 让文字和数字底部对齐更自然
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Regular()
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Regular()
        return label
    }()
    
    // 状态属性
    var isSelected: Bool = false {
        didSet { updateStyle() }
    }
    
    init(title: String, count: Int) {
        super.init(frame: .zero)
        setupUI(title: title, count: count)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI(title: String, count: Int) {
        titleLabel.text = title.trimmingCharacters(in: .whitespaces)
        if count > 0 {
            countLabel.text = "(\(count))"
        }
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(countLabel)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        updateStyle()
    }
    
    private func updateStyle() {
        let activeColor = AppColorStyle.shared.brandPrimary
        let inactiveColor = AppColorStyle.shared.textGray94
        
        titleLabel.textColor = isSelected ? activeColor : inactiveColor
        countLabel.textColor = isSelected ? activeColor : inactiveColor
        
        // 选中时加粗，未选中时常规
        let font = isSelected ? AppFontProvider.shared.getFont16Bold() : AppFontProvider.shared.getFont16Regular()
        titleLabel.font = font
        countLabel.font = font
        
    }
    
    func updateCount(_ count: Int) {
        guard count > 0 else {
            countLabel.text = nil
            return
        }
        countLabel.text = "(\(count))"
        // 重新布局，因为数字位数变化可能影响宽度
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
    }
}

