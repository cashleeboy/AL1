//
//  ContactInfoApplyView.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit
import ContactsUI

class ContactInfoApplyView: BaseApplyViewController<ContactModuleViewModel>
{
    private var selectedContactInfo: ContactInfoModel?
    private lazy var contactStore: ContactStore = ContactStore()
    var contactContainerModel: EmergencyContactContainerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomContainer.setPrimaryState(isEnable: true)
        
        moduleVM.fetchData { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                contactContainerModel = data
                moduleVM.contactRows.enumerated().forEach { (index, row) in
                    if data.contacts.indices.contains(index) {
                        let model = data.contacts[index]
                        row.numeroFieldText = model.phoneNumber
                        row.nombresFieldText = model.name
                        if let relKey = Int(model.relationship) {
                            row.keyStrings = [String(relKey)]
                            row.relacionFieldText = IdentityDataSource.find(key: relKey, at: \.contactRelation)?.value ?? ""
                        }
                        let key = "Contacto de emergencia\(index + 1)"
                        self.moduleVM.updateContactValue(at: key, with: model)
                    }
                }
            case .failure(let error):
                showToast(error.message)
            }
        }
    }
    
    override func loadFormer() {
        super.loadFormer()
        
        let list = moduleVM.contactInfoFields()
        moduleVM.contactRows = list.map { model in
            let row = FormContactRowFormer<FormContactCell>(instantiateType: .Class) { cell in
            }.configure { cell in
                cell.rowHeight = UITableView.automaticDimension
            }.relacionHandler { [weak self] currentRow in
                guard let self else { return }
                view.endEditing(true)
                selectedContactInfo = model
                var selectRows: [Int] = []
                currentRow.keyStrings?.forEach { key in
                    if let index = currentRow.infoModel?.type.getIndexValue(for: key) {
                        selectRows.append(index)
                    }
                }
                showPickerSheet(delegate: self, dataSource: self, nameTitle: model.relaction, confirmTitle: "Confirmar", selectedRows: selectRows)
            }.nombresTextHandler { [weak self] text in
                guard let self else { return }
                moduleVM.updateContact(with: model, field: .identity(name: text, mobile: nil))
                
                if let error = moduleVM.checkMobileConflicts() {
                    showToast(error.message)
                }
            }.contactTapHandler { [weak self] in
                guard let self else { return }
                view.endEditing(true)
                selectedContactInfo = model
                handleContactAction()
                
            }.numeroTextHandler { [weak self] text in
                guard let self, let text else { return }
                moduleVM.updateContact(with: model, field: .identity(name: nil, mobile: text))

                if let error = moduleVM.checkMobileConflicts() {
                    showToast(error.message)
                }
            }
            row.infoModel = model
            return row
        }
        selectionFormer.add(rowFormers: moduleVM.contactRows)
        former.append(sectionFormer: selectionFormer)
    }
    
    override func bottomAction() {
        // 进行页面所有项的校验
        guard moduleVM.validate() else {
            moduleVM.contactRows.forEach { row in
                // relationship
                if row.relacionFieldText == nil {
                    row.relacionStatus = .showRedError(message: "Por favor seleccione la relación con su contacto")
                } else {
                    row.relacionStatus = .normal
                }
                // numero
                if row.numeroFieldText == nil {
                    row.numeroStatus = .showRedError(message: "Por favor ingrese")
                } else {
                    row.numeroStatus = .normal
                }
                // nombresStatus
                if row.nombresFieldText == nil {
                    row.nombresStatus = .showRedError(message: "Por favor ingrese")
                } else {
                    row.nombresStatus = .normal
                }
            }
            tableView.reloadData()
            return
        }
        // submit contact list
        notifyStepFinished()
    }
    
    func handleContactAction() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            openContactPicker()
        case .denied, .restricted:
            showContactPermissionAlert(viewController: self)
            break
        case .authorized, .limited:
            openContactPicker()
        @unknown default:
            break
        }
    }
    
    func openContactPicker() {
        contactStore.requestAccess { result in
            switch result {
            case .success(let isAccess):
                if isAccess {
                    // fetch all contacts
//                    self.contactStore.fetchContacts { result in
//                        switch result {
//                        case .success(let contacts):
//                            print("*** contacts = \(contacts)")
//                            break
//                        case .failure(let failure): break
//                        }
//                    }
                    DispatchQueue.main.async {
                        let contactPicker = CNContactPickerViewController()
                        contactPicker.delegate = self // 设置代理
                        self.present(contactPicker, animated: true, completion: nil)
                    }
                }
            case .failure(_):
                break
            }
        }
    }

}

extension ContactInfoApplyView: MZPickerControllerDelegate, MZPickerControllerDataSource {
    func numberOfComponents(in picker: MZPickerController) -> Int {
        return selectedContactInfo?.options?.count ?? 0 > 0 ? 1 : 0
    }

    func picker(_ picker: MZPickerController, numberOfRowsInComponent component: Int) -> Int  {
        return selectedContactInfo?.options?.count ?? 0
    }
    
    func picker(_ picker: MZPickerController, widthForComponent component: Int) -> CGFloat {
        let width = view.frame.size.width / (1 + 0.2)
        return component == 0 ? width * 1.2 : width
    }
    
    func picker(_ picker: MZPickerController, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
    
    func picker(_ picker: MZPickerController, titleForRow row: Int, forComponent component: Int) -> String
    {
        guard let option = selectedContactInfo?.options?[row] else {
            return ""
        }
        return option.value
    }
    
    func picker(_ picker: MZPickerController, didSelect rows: [Int]) {
        moduleVM.contactRows.enumerated().forEach { (index, row) in
            if row.infoModel?.contactTitle == selectedContactInfo?.contactTitle, let idx = rows.first {
                if let info = row.infoModel, let option = info.options?[idx] {
                    row.relacionFieldText = option.value
                    row.relacionStatus = .normal
                    moduleVM.updateContact(with: info, field: .relation(key: option.key))
                }
            }
        }
        dismiss()
    }
}

extension ContactInfoApplyView: CNContactPickerDelegate
{
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let rawPhoneNumber = contact.phoneNumbers.first { label in
            guard let label = label.label else { return false }
            return label == CNLabelPhoneNumberMobile || label == CNLabelPhoneNumberiPhone
        }?.value.stringValue ?? contact.phoneNumbers.first?.value.stringValue
        // 调用 digitsOnly 剔除所有非数字字符
        let phoneNumberValue = rawPhoneNumber?.digitsOnly
        
        guard let number = phoneNumberValue else { return }
        moduleVM.contactRows.forEach { row in
            guard let info = row.infoModel,
                  info.contactTitle == selectedContactInfo?.contactTitle else { return }
            let name = contact.fullName()
            
            let result = moduleVM.updateContact(with: info, field: .identity(name: name, mobile: number), needToValid: true)// mobile
            
            if result {
                row.nombresFieldText = name
                row.numeroFieldText = number
                row.numeroStatus = .normal
                row.nombresStatus = .normal
            } else {
                showToast(ContactValidationError.duplicateMobile.message)
            }
        }
        
        if let error = moduleVM.checkMobileConflicts() {
            showToast(error.message)
        }
    }
}

extension CNContact {
    func fullName() -> String {
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        
        let rawName = formatter.string(from: self) ?? ""
        // 直接使用抽取好的扩展
        let finalName = rawName.filteringForbiddenChars.trimmed
        return finalName.isEmpty ? "Unknown" : finalName
    }
    
    private static let htmlRegex = try? NSRegularExpression(
        pattern: "&emsp;|&nbsp;|<br>|<br/>|</p>|<p>|<div>|</div>|&lt;|&gt;|&amp;",
        options: []
    )

    private func filterSpecialCharacters(from text: String) -> String {
        guard let regex = Self.htmlRegex else { return text }
        let range = NSRange(location: 0, length: (text as NSString).length)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
    }
}
