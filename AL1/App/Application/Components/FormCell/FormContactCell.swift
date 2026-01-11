//
//  FormContactCell.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit
import SnapKit

class FormContactCell: BaseFormCell {
    
    // MARK: - UI Components
    private lazy var contactTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Bold()
        label.textColor = AppColorStyle.shared.textBlack
        return label
    }()
    
    /// 关系
    private lazy var relacionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont13Regular()
        label.textColor = AppColorStyle.shared.textGrayForm
        return label
    }()
    private lazy var relacionField: AppInputTextField = {
        let input = AppInputTextField()
        input.rightViewMode = .always
        input.backgroundColor = UIColor(hex: "#F5F4F4")
        input.layer.cornerRadius = 10
        input.layer.borderWidth = 0
        input.textColor = UIColor(hex: "#333333")
        input.font = AppFontProvider.shared.getFont14Semibold()
        input.placeholder = "Por favor elija"
        input.setRightIcon(UIImage(named: "right_arrow_icon"), size: CGSize(width: 13, height: 13))
        return input
    }()
    
    // 名字
    private lazy var nombresLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont13Regular()
        label.textColor = AppColorStyle.shared.textGrayForm
        return label
    }()
    private lazy var contactBookButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 16, height: 16)))
        button.setImage(UIImage(named: "contact_book_icon"), for: .normal)
//        button.addTarget(self, action: #selector(contactBookAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var nombresField: AppInputTextField = {
        let input = AppInputTextField()
        input.rightViewMode = .always
        input.backgroundColor = UIColor(hex: "#F5F4F4")
        input.layer.cornerRadius = 10
        input.layer.borderWidth = 0
        input.textColor = UIColor(hex: "#333333")
        input.font = AppFontProvider.shared.getFont14Semibold()
        input.rightView = contactBookButton
//        input.setRightIcon(contactBookButton, size: CGSize(width: 16, height: 16))
        return input
    }()
    
    // numero de Celular
    private lazy var numeroLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont13Regular()
        label.textColor = AppColorStyle.shared.textGrayForm
        return label
    }()
    lazy var numeroField: AppInputTextField = {
        let input = AppInputTextField()
        input.rightViewMode = .always
        input.backgroundColor = UIColor(hex: "#F5F4F4")
        input.layer.cornerRadius = 10
        input.layer.borderWidth = 0
        input.textColor = UIColor(hex: "#333333")
        input.font = AppFontProvider.shared.getFont14Semibold()
        input.keyboardType = .asciiCapableNumberPad
        return input
    }()

    
    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(contactTitleLabel)
        contentView.addSubview(relacionLabel)
        contentView.addSubview(relacionField)
        contentView.addSubview(nombresLabel)
        contentView.addSubview(nombresField)
        contentView.addSubview(numeroLabel)
        contentView.addSubview(numeroField)
        
        setupLayout()
    }
    
    private func setupLayout() {
        contactTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        relacionLabel.snp.makeConstraints { make in
            make.top.equalTo(contactTitleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        relacionField.snp.makeConstraints { make in
            make.top.equalTo(relacionLabel.snp.bottom).offset(8)
            make.left.right.equalTo(relacionLabel)
            make.height.equalTo(48) // 标准表单高度
        }
        
        nombresLabel.snp.makeConstraints { make in
            make.top.equalTo(relacionField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        nombresField.snp.makeConstraints { make in
            make.top.equalTo(nombresLabel.snp.bottom).offset(8)
            make.left.right.equalTo(relacionLabel)
            make.height.equalTo(48) // 标准表单高度
        }
        
        numeroLabel.snp.makeConstraints { make in
            make.top.equalTo(nombresField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        numeroField.snp.makeConstraints { make in
            make.top.equalTo(numeroLabel.snp.bottom).offset(8)
            make.left.right.equalTo(relacionLabel)
            make.height.equalTo(48) // 标准表单高度
            make.bottom.equalToSuperview().offset(-12) // 撑开 Cell 高度
        }
    }
}

extension FormContactCell: FormContactFormableRow
{
    func getRelacionField() -> AppInputTextField? {
        return relacionField
    }
    func getNombresField() -> AppInputTextField? {
        return nombresField
    }
    func getNumeroField() -> AppInputTextField? {
        return numeroField
    }
    
    func updateInfoModel(with item: ContactInfoModel) {
        contactTitleLabel.text = item.contactTitle
        relacionLabel.text = item.relaction
        relacionField.placeholder = item.relactionType.holderName
        
        nombresLabel.text = item.name
        nombresField.placeholder = item.nameType.holderName
        
        numeroLabel.text = item.mobile
        numeroField.placeholder = item.mobileType.holderName
    }
    
    func getContactBookButton() -> UIButton? {
        contactBookButton
    }
}
