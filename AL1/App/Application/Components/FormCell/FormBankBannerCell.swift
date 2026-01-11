//
//  FormBankBannerCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

class FormBankBannerCell: BaseFormCell {
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.backgroundColor = AppColorStyle.shared.lightBrandPrimary
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont11Regular()
        label.textColor = AppColorStyle.shared.textBlack33
        // 增加行间距逻辑
        let text = "Use la cuenta bancaria vinculada a su tarjeta de identidad y no use las cuentas bancarias de otras personas para evitar la falla del préstamo."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // 设置行间距
        let attributedString = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
        label.attributedText = attributedString
        label.numberOfLines = 0
        return label
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "allpy_ann_icon")
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        setupLayout()
    }
    
    private func setupLayout() {
        // 1. 外层容器，控制 Cell 的内边距
        containerView.snp.makeConstraints { make in
            // 根据 UI 图，上下留白较多，左右对齐表单边距
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.right.equalToSuperview().inset(15)
        }
        
        // 2. 左侧小喇叭图标
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.size.equalTo(CGSize(width: 15, height: 15))
            // 关键：与 Label 的第一行对齐，或者顶部对齐
            make.top.equalTo(titleLabel.snp.top).offset(2)
        }
        
        // 3. 多行描述文字
        titleLabel.snp.makeConstraints { make in
            // 文字距离图标留出间距
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            // 撑开容器上下间距
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}

extension FormBankBannerCell: FormSelectionTitleFormableRow {
    func titleFormable() -> UILabel? {
        return titleLabel
    }
}
