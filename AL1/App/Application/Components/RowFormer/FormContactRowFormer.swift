//
//  FormContactFormableRow.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

protocol FormContactFormableRow: FormableRow {
    func getRelacionField() -> AppInputTextField?
    func getNombresField() -> AppInputTextField?
    func getNumeroField() -> AppInputTextField?
    func updateInfoModel(with item: ContactInfoModel)
    func getContactBookButton() -> UIButton?
    
    func updateRelacionFileStatus(_ status: FormFileStatus?)
    func updateNumeroFileStatus(_ status: FormFileStatus?)
    func updateNombresFileStatus(_ status: FormFileStatus?)
}

class FormContactRowFormer<T: UITableViewCell>: BaseRowFormer<T>, Formable where T: FormContactFormableRow
{
    var onRelacionHandler: ((FormContactRowFormer) -> Void)?
    var onNombresHandler: ((String?) -> Void)?
    var onNumeroHandler: ((String?) -> Void)?
    var onContactTapHandler: (() -> Void)?
    var infoModel: ContactInfoModel?
    
    // update model
    var keyStrings: [String]?
    
    var relacionFieldText: String? {
        didSet {
            cell.getRelacionField()?.text = relacionFieldText
        }
    }
    var nombresFieldText: String? {
        didSet {
            cell.getNombresField()?.text = nombresFieldText
        }
    }
    var numeroFieldText: String? {
        didSet {
            cell.getNumeroField()?.text = numeroFieldText
        }
    }
    var relacionStatus: FormFileStatus? {
        didSet {
            // show error
            cell.updateRelacionFileStatus(relacionStatus)
        }
    }
    var numeroStatus: FormFileStatus? {
        didSet {
            // show error
            cell.updateNumeroFileStatus(numeroStatus)
        }
    }
    var nombresStatus: FormFileStatus? {
        didSet {
            cell.updateNombresFileStatus(nombresStatus)
        }
    }
        
    required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    override func cellInitialized(_ cell: T) {
        super.cellInitialized(cell)
    }
    
    //
    func relacionHandler(_ hander: @escaping ((FormContactRowFormer) -> Void)) -> Self {
        onRelacionHandler = hander
        return self
    }
    func nombresTextHandler(_ handler: @escaping ((String?) -> Void)) -> Self {
        onNombresHandler = handler
        return self
    }
    func contactTapHandler(_ handler: @escaping (() -> Void)) -> Self {
        onContactTapHandler = handler
        return self
    }
    func numeroTextHandler(_ handler: @escaping ((String?) -> Void)) -> Self {
        onNumeroHandler = handler
        return self
    }

    override func update() {
        super.update()
        
        guard let infoModel else {
            return
        }
        cell.updateInfoModel(with: infoModel)
        
        // relation
        if let field = cell.getRelacionField() {
            field.shouldBeginEditing = { [weak self] in
                guard let self else { return false }
                onRelacionHandler?(self)
                return false
            }
        }
        
        // name
        if let field = cell.getNombresField() {
            field.shouldChangeCharacters = { currentText, replacement in
                // 允许删除操作
                if replacement.isEmpty { return true }
                if replacement.containsForbiddenChars { return false }
                let prospectiveText = (currentText ?? "") + replacement
                if prospectiveText.hasPrefix(" ") {
                    return false
                }
                return true
            }
        }
        if let btn = cell.getContactBookButton() {
            btn.addTarget(self, action: #selector(contactBookAction), for: .touchUpInside)
        }
        
        // numero
        if let field = cell.getNumeroField() {
            field.shouldChangeCharacters = { [weak self] currentText, replacement in
                guard let self else { return false }
                if replacement.containsForbiddenChars {
                    return false
                }
                guard replacement.allSatisfy({ $0.isNumber }) else {
                    return false
                }
                numeroStatus = .normal
                onNumeroHandler?(currentText)
                return true
            }
        }
    }
    
    @objc func contactBookAction() {
        onContactTapHandler?()
    }
}

