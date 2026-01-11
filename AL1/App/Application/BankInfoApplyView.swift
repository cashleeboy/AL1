//
//  BankInfoApplyView.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class BankInfoApplyView: BaseApplyViewController<BankModuleViewModel>
{
    private var selectedIdentityInfo: IdentityInfoModel?
    private var bankConfigModel: BankConfigModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moduleVM.isDataCompletePublisher
            .compactMap { $0 }
            .sink { [weak self] isDone in
                guard let self else { return }
                self.bottomContainer.setPrimaryState(isEnable: isDone)
            }
            .store(in: &self.moduleVM.cancellables)
        
        moduleVM.fetchData { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                bankConfigModel = data.bankConfigModel
                
                moduleVM.bankRows.forEach { row in
                    guard let type = row.infoModel?.type else { return }
                    switch type {
//                    case .bankName:
//                        if let bankItem = data.bankConfigModel?.bankList.first(where: { item in
//                            item.id == data.bankDetail.bankId
//                        }) {
//                            row.filedText = bankItem.bankName
//                        }
                    case .bankAccountType:
                        if let keyString = data.bankDetail.valuesMap[type] {
                            row.keyStrings = [keyString]
                            row.filedText = type.getDisplayValue(for: keyString)
                        }
                    case .CCI:
                        row.filedText = data.bankDetail.bankAccountCCI
                    case .bankNumber:
                        row.filedText = data.bankDetail.bankAccountNo
                    default: break
                    }
                }
                break
            case .failure(let error):
                showToast(error.message)
            }
        }
    }
    
    override func loadFormer() {
        super.loadFormer()
        
        // bank banner
        let bannerRow = FormSelectionTitleRowFormer<FormBankBannerCell>(instantiateType: .Class) { cell in
        }.configure { cell in
            cell.rowHeight = UITableView.automaticDimension
        }
        bannerRow.attributedTitle = "Use la cuenta bancaria vinculada a su tarjeta de identidad y no use las cuentas bancarias de otras personas para evitar la falla del préstamo."
        selectionFormer.add(rowFormers: [bannerRow])
        
        let list = moduleVM.bankInfoFields()
        moduleVM.bankRows = list.map { model in
            let row = FormSelectionRowFormer<FormSelectionCell>(instantiateType: .Class) { cell in
            }.configure { cell in
                cell.rowHeight = UITableView.automaticDimension
            }.selectionFieldHandler { [weak self] currentRow in
                guard let self else { return }
                switch model.fieldType {
                case .choose:
                    selectedIdentityInfo = model
                    // TODO: selectRows
                    let selectRows: [Int] = []
                    
                    showPickerSheet(delegate: self, dataSource: self, nameTitle: model.type.display, confirmTitle: "Confirmar", selectedRows: selectRows)
                case .bankName:
                    guard let bankConfigModel else {
                        return
                    }
                    showBankSheet(wiht: bankConfigModel.bankList) { selectItem in
                        self.moduleVM.updateBankValue(for: model, value: nil, map: [
                            BackendUserBankInfoKeys.bankName: selectItem.name,
                            BackendUserBankInfoKeys.bankId: selectItem.id
                        ], displayText: selectItem.name)
                    }
                default:
                    break
                }
            }.highLightHandler { [weak self] in
                guard let self else { return }
                // cci
                showCCIDialog()
            }.textFieldTextHandler { [weak self] currentRow, text in
                guard let self, let text else { return }
                moduleVM.updateBankValue(for: model, value: text, map: nil, displayText: text)
            }
            row.infoModel = model
            return row
        }
        selectionFormer.add(rowFormers: moduleVM.bankRows)
        former.append(sectionFormer: selectionFormer)
    }
    
    // next page to certificate
    override func bottomAction() {
        let nameRow = moduleVM.bankRows.first { row in row.infoModel?.type == .bankName }
        let displayBankName = nameRow?.filedText ?? ""

        let numberRow = moduleVM.bankRows.first { row in row.infoModel?.type == .bankNumber }
        let displayBankNumber = numberRow?.filedText ?? ""
        let items = [
            ConfirmItem(title: "Banco：", content: displayBankName),
            ConfirmItem(title: "Número de tarjeta bancaria：", content: displayBankNumber)
        ]
        showInformation(with: "Verifique su información bancaria", items: items) { [weak self] in
            guard let self else { return }
            notifyStepFinished()
        }
    }
}


extension BankInfoApplyView: MZPickerControllerDelegate, MZPickerControllerDataSource {
    func numberOfComponents(in picker: MZPickerController) -> Int {
        guard selectedIdentityInfo?.fieldType == .bankName else {
            return selectedIdentityInfo?.options.count ?? 0 > 0 ? 1 : 0
        }
        return bankConfigModel?.bankList.count ?? 0 > 0 ? 1 : 0
    }
    
    func picker(_ picker: MZPickerController, numberOfRowsInComponent component: Int) -> Int  {
        guard selectedIdentityInfo?.fieldType == .bankName else {
            return selectedIdentityInfo?.options.count ?? 0
        }
        return bankConfigModel?.bankList.count ?? 0
    }
    
    func picker(_ picker: MZPickerController, titleForRow row: Int, forComponent component: Int) -> String {
        if selectedIdentityInfo?.fieldType == .bankName {
            guard let list = bankConfigModel?.bankList, list.indices.contains(row) else {
                return ""
            }
            return list[row].bankName
        }
        if let options = selectedIdentityInfo?.options, options.indices.contains(row) {
            return options[row].value
        }
        return ""
    }
    
    func picker(_ picker: MZPickerController, didSelect rows: [Int]) {
        dismiss()
        guard let selectedIdx = rows.first, let currentInfo = selectedIdentityInfo else { return }
        
        guard currentInfo.options.indices.contains(selectedIdx) else { return }
        let option = currentInfo.options[selectedIdx]
        // 更新数据: 这里传option.key
        moduleVM.updateBankValue(for: currentInfo, value: String(option.key), map: nil, displayText: option.value)
    }
    
    func picker(_ picker: MZPickerController, widthForComponent component: Int) -> CGFloat {
        let screenWidth = view.frame.size.width
        return screenWidth
    }
    
    func picker(_ picker: MZPickerController, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
}
