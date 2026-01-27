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
    private lazy var relacionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .fill
        return stack
    }()
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
    private lazy var bottomRelacionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#FF0000")
        label.isHidden = true
        return label
    }()

    private lazy var contactBookButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 16, height: 16)))
        button.setImage(UIImage(named: "contact_book_icon"), for: .normal)
        return button
    }()
    
    private lazy var nombresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .fill
        return stack
    }()
    private lazy var nombresLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont13Regular()
        label.textColor = AppColorStyle.shared.textGrayForm
        return label
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
        return input
    }()
    private lazy var bottomNombresLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#FF0000")
        label.isHidden = true
        return label
    }()
    
    private lazy var numeroStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .fill
        return stack
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
    private lazy var bottomNumeroLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont12Regular()
        label.textColor = UIColor(hex: "#FF0000")
        label.isHidden = true
        return label
    }()

    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(contactTitleLabel)
        
        contentView.addSubview(relacionStackView)
        relacionStackView.addArrangedSubview(relacionLabel)
        relacionStackView.addArrangedSubview(relacionField)
        relacionStackView.addArrangedSubview(bottomRelacionLabel)
        
        contentView.addSubview(nombresStackView)
        nombresStackView.addArrangedSubview(nombresLabel)
        nombresStackView.addArrangedSubview(nombresField)
        nombresStackView.addArrangedSubview(bottomNombresLabel)

        contentView.addSubview(numeroStackView)
        numeroStackView.addArrangedSubview(numeroLabel)
        numeroStackView.addArrangedSubview(numeroField)
        numeroStackView.addArrangedSubview(bottomNumeroLabel)
        
        setupLayout()
    }
    
    private func setupLayout() {
        contactTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        relacionStackView.snp.makeConstraints { make in
            make.top.equalTo(contactTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        relacionField.snp.makeConstraints { make in
            make.height.equalTo(48) // 标准表单高度
        }
        
        nombresStackView.snp.makeConstraints { make in
            make.top.equalTo(relacionStackView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        nombresField.snp.makeConstraints { make in
            make.height.equalTo(48) // 标准表单高度
        }
        
        numeroStackView.snp.makeConstraints { make in
            make.top.equalTo(nombresStackView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12) // 撑开 Cell 高度
        }
        numeroField.snp.makeConstraints { make in
            make.height.equalTo(48) // 标准表单高度
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
    // 优化后的公共调用方法
    func updateRelacionFileStatus(_ status: FormFileStatus?) {
        updateLabel(bottomRelacionLabel, with: status)
    }

    func updateNumeroFileStatus(_ status: FormFileStatus?) {
        updateLabel(bottomNumeroLabel, with: status)
    }

    func updateNombresFileStatus(_ status: FormFileStatus?) {
        updateLabel(bottomNombresLabel, with: status)
    }

    // 核心逻辑抽离
    private func updateLabel(_ label: UILabel, with status: FormFileStatus?) {
        guard let status = status, case .showRedError(let message) = status else {
            label.isHidden = true
            return
        }
        label.isHidden = false
        label.text = message
    }
}
