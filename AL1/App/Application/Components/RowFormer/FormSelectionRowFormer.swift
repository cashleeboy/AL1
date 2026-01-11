//
//  FormSelectionRowFormer.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

enum FormFileStatus {
    case normal
    case showRedError(message: String)
}

protocol FormSelectionFormableRow: FormableRow
{
    func getSubTitleLabel() -> UILabel?
    func getSelectionField() -> AppInputTextField?
    
    func setUpAttributed(with attributedString: NSAttributedString?)
    func updateInfoModel(with item: IdentityInfoModel)
    func updateFileStatus(_ status: FormFileStatus?)
}

class FormSelectionRowFormer<T: UITableViewCell>: BaseRowFormer<T>, IdentityFormRow, Formable where T: FormSelectionFormableRow
{
    var onSelectionFieldHandler: ((FormSelectionRowFormer) -> Void)?
    var onHighLightLabelHandler: (() -> Void)?
    var onTextFieldTextHandler: ((FormSelectionRowFormer, String?)-> Void)?
    var onTextFieldDidEndHandler: ((String?)-> Void)?
    var onTextFieldDidEnd: ((String?)-> Void)?
    
    // for value
    var keyStrings: [String]?
    var filedText: String? {
        didSet {
            cell.getSelectionField()?.text = filedText
        }
    }
    var attributedSubTitle: NSAttributedString? {
        didSet {
            cell.setUpAttributed(with: attributedSubTitle)
        }
    }
    var infoModel: IdentityInfoModel? {
        didSet {
            if infoModel?.type == .CCI {
                maxCount = 20
            }
        }
    }
    var currentGener: GeneroType? { nil }
    
    var maxCount: Int?
    var fileStatus: FormFileStatus? {
        didSet {
            // show error
            cell.updateFileStatus(fileStatus)
        }
    }
    
    required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    override func cellInitialized(_ cell: T) {
        super.cellInitialized(cell)
    }
    
    func selectionFieldHandler(_ hander: @escaping ((FormSelectionRowFormer) -> Void)) -> Self {
        onSelectionFieldHandler = hander
        return self
    }
    
    func highLightHandler(_ handler: @escaping (() -> Void)) -> Self {
        onHighLightLabelHandler = handler
        return self
    }
    
    func textFieldTextHandler(_ handler: @escaping ((FormSelectionRowFormer, String?) -> Void)) -> Self {
        onTextFieldTextHandler = handler
        return self
    }
    
    func textFieldDidEndEditHandler(_ handler: @escaping ((String?) -> Void)) -> Self {
        onTextFieldDidEnd = handler
        return self
    }
    
    override func update() {
        super.update()
        guard let infoModel else {
            return
        }
        cell.updateInfoModel(with: infoModel)

        if infoModel.parentKey == BackendUserBankInfoKeys.bankInfoNode,
           let extraString = infoModel.extraString {
            let attributed = NSMutableAttributedString(string: extraString, color: AppColorStyle.shared.brandPrimary)
            cell.setUpAttributed(with: attributed)
        }
        
        if let field = cell.getSelectionField() {
            field.shouldBeginEditing = { [weak self] in
                guard let self else { return false }
                onSelectionFieldHandler?(self)
                return infoModel.fieldType.isKeyboardInput
            }
            field.textChanged = { [weak self] text in
                guard let self else { return }
                onTextFieldTextHandler?(self, text)
            }
            field.didEndEditing = { [weak self] text in
                guard let self else { return }
                onTextFieldDidEnd?(text)
            }
            field.shouldChangeCharacters = { [weak self] currentText, replacement in
                guard let self else { return true }
                let prospectiveText = (currentText ?? "") + replacement
                if prospectiveText.hasPrefix(" ") {
                    return false
                }
                if let count = maxCount {
                    return (currentText?.count ?? 0) <= count
                }
                return true
            }
        }
        
        // high light(attribute) tap gesture
        if let label = cell.getSubTitleLabel() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
            label.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapAction() {
        onHighLightLabelHandler?()
    }
}
