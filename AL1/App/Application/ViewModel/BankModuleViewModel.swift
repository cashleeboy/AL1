//
//  BankModuleViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import Combine
import Foundation

// 1. 定义一个聚合模型
struct BankInfoFetchResult {
    let bankDetail: BankCardInfoModel    //用户银行信息
    let bankConfigModel: BankConfigModel? // 银行名称
}


class BankModuleViewModel: ObservableObject, ApplicationAuthModuleProtocol {
    var reviewType: InfoReviewType = .bank
    var bankNameList: BankConfigModel?
    // respository
    private lazy var bankRespository = ApplyRepository()
    lazy var cancellables = Set<AnyCancellable>()
    
    // UI 配置行
    lazy var bankRows: [FormSelectionRowFormer<FormSelectionCell>] = []
    
    // 存储给后台的数据：因为 Bank 通常只有一个 parentKey，这里可以用平铺字典
    @Published var bankValues: [String: Any] = [:]
    
    var isUpdate: Int = 0
    @Published var isDataComplete: Bool = false
    
    private static var maxCCIDigitos: Int = 20
    
    private lazy var respository = ApplyRepository()
    var isDataCompletePublisher: AnyPublisher<Bool, Never> {
        $isDataComplete.eraseToAnyPublisher()
    }
    
    func fetchData(completion: @escaping (Result<BankInfoFetchResult, RequestError>) -> Void) {
        // 1. 包装任务
        let items: [TaskItem] = [
            TaskItem(priority: .optional) { done in
                self.fetchBankListQuery { result in
                    if case .success(let success) = result {
                        done(.success(success))
                    } else if case .failure(let failure) = result {
                        done(.failure(failure))
                    }
                }
            },
            TaskItem(priority: .core) { done in
                self.respository.queryBankInfo { [weak self] result in
                    guard let self else { return }
                    if case .success(let success) = result {
                        isUpdate = success.isUpdate
                        syncValuesToFiledValues(from: success)
                    }
                    done(result.map { $0 as Any })
                }
            }
        ]
        TaskAggregator.fetch(items: items) { result in
            switch result {
            case .success(let dataList):
                // 3. 解析结果（顺序与 items 一致）
                let config = dataList[0] as? BankConfigModel
                let authModel = dataList[1] as? BankCardInfoModel
                
                if let model = authModel {
                    self.syncValuesToFiledValues(from: model)
                    let finalResult = BankInfoFetchResult(bankDetail: model, bankConfigModel: config)
                    completion(.success(finalResult))
                }
            case .failure(let error):
                // 这里会收到核心任务抛出的错误
                completion(.failure(error))
            }
        }
    }

    func submitData(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        guard isDataComplete else {
            return
        }
        let params = ApplyObfuscatedKey.makeParams(
            rootKey: .bankInfo,
            value: bankValues, isUpdate: isUpdate)
        respository.submitBankInfo(with: params) { result in
            completion(result)
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
    
}

extension BankModuleViewModel
{
    private func updateUI(for info: IdentityInfoModel, text: String) {
        if let index = bankRows.firstIndex(where: { $0.infoModel?.type == info.type }) {
            bankRows[index].filedText = text
            bankRows[index].fileStatus = .normal
        }
        isDataComplete = validate()
    }
    
    // 查询银行名称列表
    private func fetchBankListQuery(completion: @escaping (Result<BankConfigModel, RequestError>) -> Void) {
        bankRespository.fetchBankListQuery { result in
            completion(result)
        }
    }
}

extension BankModuleViewModel
{
    private func syncValuesToFiledValues(from model: BankCardInfoModel) {
        bankValues[BackendUserBankInfoKeys.bankId] = model.bankId
        bankValues[BackendUserBankInfoKeys.bankName] = model.bankName
        bankValues[BackendUserBankInfoKeys.bankAccountType] = model.bankAccountType
        bankValues[BackendUserBankInfoKeys.bankAccountCCI] = model.bankAccountCCI
        bankValues[BackendUserBankInfoKeys.bankAccountNo] = model.bankAccountNo
        isDataComplete = validate()
    }
    
    /// 校验逻辑
    func validate() -> Bool {
        guard !bankRows.isEmpty else { return false }
        return bankRows.allSatisfy { row in
            guard let info = row.infoModel else { return true }
            
            return info.keys.values.allSatisfy { backendKey in
                if info.fieldType == .enter, let val = bankValues[backendKey] as? String {
                    return val.count >= BankModuleViewModel.maxCCIDigitos
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
            keys: ["value": BackendUserBankInfoKeys.bankAccountType],
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
            keys: ["value": BackendUserBankInfoKeys.bankAccountNo],
            fieldType: .bankNumber
        ))
        return list
    }
}
