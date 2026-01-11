//
//  TitleValueView.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit

class TitleValueView: UIView {
    let title: String
    let value: String
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = AppFontProvider.shared.getFont12Medium()
        titleLabel.textColor = AppColorStyle.shared.textGray66
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    private lazy var valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.font = AppFontProvider.shared.getFont14Semibold()
        valueLabel.textColor = AppColorStyle.shared.textBlack33
        valueLabel.numberOfLines = 0
        return valueLabel
    }()
    
    init(frame: CGRect, title: String, value: String) {
        self.title = title
        self.value = value
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        let attributedText = NSMutableAttributedString.makeStyledText(
            fullText: title,
            boldParts: [value],
            font: AppFontProvider.shared.getFont12Regular(),
            boldFont: AppFontProvider.shared.getFont14Semibold(),
            textColor: AppColorStyle.shared.textGray66,
            boldTextColor: UIColor(hex: "0x2B2B2B"),
            lineSpacing: nil
        )
        titleLabel.attributedText = attributedText
    }
    
    private func createMenuIconItem(for title: String, value: String) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFontProvider.shared.getFont12Regular()
        titleLabel.textColor = AppColorStyle.shared.textGray
        titleLabel.textAlignment = .left
        
        let valueLabel = UILabel()
        valueLabel.text = value
        // 重点：设置橙色字体和加粗，与图片保持一致
        valueLabel.font = AppFontProvider.shared.getFont13Regular()
        valueLabel.textColor = AppColorStyle.shared.brandPrimary
        valueLabel.textAlignment = .right
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        // 使用 SnapKit 布局内部子项
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
            // 限制 titleLabel 宽度为容器的一半
            make.width.equalToSuperview().multipliedBy(0.5).offset(-5)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(10) // 保持间隔
        }
        return container
    }
    
}
