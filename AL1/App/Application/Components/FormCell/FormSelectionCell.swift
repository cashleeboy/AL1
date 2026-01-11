//
//  Cell.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit
import SnapKit

class FormSelectionCell: BaseFormCell {
    
    // MARK: - UI Components
    // 1. 定义 StackView
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .fill
        return stack
    }()
    
    /// 顶部标题标签
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont13Regular()
        label.textColor = AppColorStyle.shared.textGrayForm
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = AppColorStyle.shared.brandPrimary
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    /// 自定义的输入框 (展示选择结果)
    private lazy var selectionField: AppInputTextField = {
        let input = AppInputTextField()
        input.rightViewMode = .always
        
        input.backgroundColor = UIColor(hex: "#F5F4F4")
        input.layer.cornerRadius = 10
        input.layer.borderWidth = 0
        input.textColor = UIColor(hex: "#333333")
        input.font = AppFontProvider.shared.getFont14Semibold()
        return input
    }()
    
    private lazy var bottomTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#FF0000")
        label.isHidden = true
        return label
    }()
    
    // MARK: - Setup
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        stackView.addArrangedSubview(selectionField)
        stackView.addArrangedSubview(bottomTitleLabel)
        
        setupLayout()
    }
    
    private func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        selectionField.snp.makeConstraints { make in
//            make.top.equalTo(stackView.snp.bottom).offset(8)
//            make.leading.trailing.equalTo(stackView)
            make.height.equalTo(48)
//            make.bottom.equalToSuperview().offset(-12)
        }
        
        if let rightView = selectionField.rightView {
            rightView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 14, height: 14))
            }
        }
    }
}

extension FormSelectionCell: FormSelectionFormableRow
{
    func getSelectionField() -> AppInputTextField? {
        return selectionField
    }
    
    func getSubTitleLabel() -> UILabel? { return subTitleLabel }
    
    func setUpAttributed(with attributedString: NSAttributedString?) {
        subTitleLabel.attributedText = attributedString
        // StackView 会自动处理 subTitleLabel 隐藏后的高度收缩和间距移除
        subTitleLabel.isHidden = (attributedString == nil || attributedString?.length == 0)
    }
    
    func updateInfoModel(with item: IdentityInfoModel) {
        
        titleLabel.text = item.type.display
        selectionField.placeholder = item.fieldType.holderName
        
        if !item.fieldType.isKeyboardInput {
            selectionField.setRightIcon(UIImage(named: "right_arrow_icon"), size: CGSize(width: 16, height: 16))
        }
    }
    
    func updateFileStatus(_ status: FormFileStatus?) {
        guard let status else {
            bottomTitleLabel.isHidden = true
            return
        }
        switch status {
        case .normal:
            bottomTitleLabel.isHidden = true
        case .showRedError(let message):
            bottomTitleLabel.isHidden = false
            bottomTitleLabel.text = message
        }
    }
}
