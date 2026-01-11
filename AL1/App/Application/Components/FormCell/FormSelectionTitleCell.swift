//
//  FormSelectionTitleCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

class FormSelectionTitleCell: BaseFormCell
{
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Regular()
        label.textColor = AppColorStyle.shared.textGrayForm
        label.text = "Nivel educativo" // 默认文本，后续通过数据驱动修改
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(titleLabel)
        setupLayout()
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }

    }
}

extension FormSelectionTitleCell: FormSelectionTitleFormableRow {
    func titleFormable() -> UILabel? {
        titleLabel
    }
}
