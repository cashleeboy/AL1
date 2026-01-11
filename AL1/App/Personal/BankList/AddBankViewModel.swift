//
//  AddBankViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import UIKit
import Combine

class AddBankViewModel {
    var cancellables = Set<AnyCancellable>()
    @Published var bankConfigModel: BankConfigModel?
    @Published var errorMassage: String?
    @Published var isSubmitSuccess: Bool?
    
    // UI 配置行
    lazy var bankRows: [FormSelectionRowFormer<FormSelectionCell>] = []
    
    // 存储给后台的数据：因为 Bank 通常只有一个 parentKey，这里可以用平铺字典
    @Published var bankValues: [String: Any] = [:]
    static var maxCCIDigitos: Int = 20
    @Published var isDataComplete: Bool = false
    
    private lazy var applyRepos = ApplyRepository()

    init() {
        isDataComplete = validate()
    }
    
    // 查询银行名称列表
    func fetchBankListQuery() {
        applyRepos.fetchBankListQuery { [weak self] result in
            guard let self else { return }
            if case .success(let success) = result {
                bankConfigModel = success
            } else if case .failure(let failure) = result {
                errorMassage = failure.message
            }
        }
    }
    
    func submitBankInfo() {
        applyRepos.submitBankApi(with: bankValues) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                isSubmitSuccess = true
            case .failure(let failure):
                errorMassage = failure.message
            }
        }
    }
    
    /// 更新银行信息值
    func updateBankValue(for info: IdentityInfoModel, value: String?, map: [String: String]?, displayText: String) {
        if let dataMap = map {
            bankValues.merge(dataMap) { _, new in new }
        } else if let singleValue = value {
            info.keys.values.forEach {
                bankValues[$0] = singleValue
            }
        }
        updateUI(for: info, text: displayText)
        isDataComplete = validate()
    }
    
    func bankInfoFields() -> [IdentityInfoModel] {
        var list: [IdentityInfoModel] = []
        // Select your bank 选择您的银行,银行id,示例值(bankId)
        list.append(IdentityInfoModel(
            type: .bankName,
            keys: [
                "bankId": BackendUserBankInfoKeys.bankId,
                "bankName": BackendUserBankInfoKeys.bankName
            ],
            fieldType: .bankName
        ))
        // Bank Account Type
        list.append(IdentityInfoModel(
            type: .bankAccountType,
            keys: ["value": AddBankBackendUserKeys.bankAccountType],
            fieldType: .choose,
            options: IdentityDataSource.bankAccountType
        ))
        // CCI (Interbank Account Code)
        list.append(IdentityInfoModel(
            type: .CCI,
            parentKey: BackendUserBankInfoKeys.bankInfoNode,
            keys: ["value": BackendUserBankInfoKeys.bankAccountCCI],
            fieldType: .enter,
            extraString: "¿Cómo obtener mi CCI?"
        ))
        // Número de cuenta bancaria 银行账号
        list.append(IdentityInfoModel(
            type: .bankNumber,
            keys: ["value": AddBankBackendUserKeys.bankCardNo],
            fieldType: .bankNumber
        ))
        return list
    }
    
}

extension AddBankViewModel
{
    private func updateUI(for info: IdentityInfoModel, text: String) {
        if let index = bankRows.firstIndex(where: { $0.infoModel?.type == info.type }) {
            bankRows[index].filedText = text
        }
        isDataComplete = validate()
    }
    
    /// 校验逻辑
    private func validate() -> Bool {
        guard !bankRows.isEmpty else { return false }
        return bankRows.allSatisfy { row in
            guard let info = row.infoModel else { return true }
            
            return info.keys.values.allSatisfy { backendKey in
                if info.fieldType == .enter, let val = bankValues[backendKey] as? String {
                    return val.count >= AddBankViewModel.maxCCIDigitos
                } else {
                    if let parent = info.parentKey {
                        let parentDict = bankValues[parent] as? [String: Any]
                        let val = parentDict?[backendKey] as? String
                        return val != nil && !val!.isEmpty
                    } else {
                        let val = bankValues[backendKey] as? String
                        return val != nil && !val!.isEmpty
                    }
                }
            }
        }
    }
    
}
