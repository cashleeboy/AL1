//
//  PersonalInfoModuleViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import Combine
import Foundation

// 1. 定义一个聚合模型
struct PersonalInfoFetchResult {
    let personalDetail: PersonalInformationModel
    let regionConfig: RegionConfigModel? // 假设你还需要返回这个
}

// 独立的个人信息 ViewModel
class PersonalInfoModuleViewModel: ObservableObject, ApplicationAuthModuleProtocol {
    typealias DataModel = PersonalInfoFetchResult
    typealias SubmitDataModel = PlainData
    
    var reviewType: InfoReviewType = .personal

    @Published var filedValues: [String: Any] = [:]
    
    var filedRows: [FormSelectionRowFormer<FormSelectionCell>] = []
    private lazy var respository = ApplyRepository()
    
    var isUpdate: Int = 0
    @Published var isDataComplete: Bool = false
    var isDataCompletePublisher: AnyPublisher<Bool, Never> {
        $isDataComplete.eraseToAnyPublisher()
    }
    
    func updateValue(for info: IdentityInfoModel, selectedOption: IdentityOption) {
        let backendKeys = info.keys.values
        if let parentKey = info.parentKey {
            var parentDict = filedValues[parentKey] as? [String: Any] ?? [:]
            backendKeys.forEach { key in
                parentDict[key] = selectedOption.key
            }
            filedValues[parentKey] = parentDict
        } else {
            backendKeys.forEach { key in
                filedValues[key] = selectedOption.key
            }
        }
        updateUI(for: info, text: selectedOption.value, keyString: [String(selectedOption.key)])
    }
    
    func updateWithText(for info: IdentityInfoModel, text: String, keyString: String) {
        let backendKeys = info.keys.values
        backendKeys.forEach { key in
            filedValues[key] = text
        }
        updateUI(for: info, text: text, keyString: [keyString])
    }
    
    func removeValue(with keys: [String]) {
        isDataComplete = validate()
        keys.forEach { key in
            filedValues[key] = ""
        }
    }
    
    func updateAddressValue(for info: IdentityInfoModel, provinceId: String, cityId: String, displayText: String) {
        var pairValues: [String: String] = [:]
        
        for (semanticKey, backendKey) in info.keys {
            let lowerKey = semanticKey.lowercased()
            if lowerKey.contains("province") {
                pairValues[backendKey] = provinceId
            } else if lowerKey.contains("city") {
                pairValues[backendKey] = cityId
            }
        }
        if let parentKey = info.parentKey {
            var parentDict = filedValues[parentKey] as? [String: Any] ?? [:]
            pairValues.forEach { (key, value) in
                parentDict[key] = value
            }
            filedValues[parentKey] = parentDict
        } else {
            pairValues.forEach { (key, value) in
                filedValues[key] = value
            }
        }
        var keyString: [String]? = []
        if let map = filedValues[BackendUserPersonalInfoKeys.address] as? [String: String] {
            if let province = map[BackendUserPersonalInfoKeys.homeProvince] {
                keyString?.append(province)
            }
            if let city = map[BackendUserPersonalInfoKeys.homeCity] {
                keyString?.append(city)
            }
        }
        updateUI(for: info, text: displayText, keyString: keyString)
    }
    
    private func updateUI(for info: IdentityInfoModel, text: String, keyString: [String]?) {
        if let index = filedRows.firstIndex(where: { $0.infoModel?.type == info.type }) {
            filedRows[index].filedText = text
            filedRows[index].keyStrings = keyString
            filedRows[index].fileStatus = .normal
        }
        isDataComplete = validate()
    }
    
    func fetchData(completion: @escaping (Result<PersonalInfoFetchResult, RequestError>) -> Void) {
        // 1. 包装任务
        let items: [TaskItem] = [
            TaskItem(priority: .optional) { done in
                self.fetchRegionConfig { result in
                    if case .success(let success) = result {
                        done(.success(success))
                    } else if case .failure(let failure) = result {
                        done(.failure(failure))
                    }
                }
            },
            TaskItem(priority: .core) { done in
                self.respository.queryPersonalInfo { result in
                    // 转换 Result 类型到 Result<Any, RequestError>
                    done(result.map { $0 as Any })
                }
            }
        ]
        TaskAggregator.fetch(items: items) { result in
            switch result {
            case .success(let dataList):
                // 3. 解析结果（顺序与 items 一致）
                let config = dataList[0] as? RegionConfigModel
                let authModel = dataList[1] as? PersonalInformationModel
                
                if let model = authModel {
                    self.syncValuesToFiledValues(from: model)
                    let finalResult = PersonalInfoFetchResult(personalDetail: model, regionConfig: config)
                    completion(.success(finalResult))
                }
            case .failure(let error):
                // 这里会收到核心任务抛出的错误
                completion(.failure(error))
            }
        }
    }
    
    // 调用具体的 API
    func submitData(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        guard isDataComplete else {
            return
        }
        let params = ApplyObfuscatedKey.makeParams(
            rootKey: .personalInfo,
            value: filedValues,
            isUpdate: isUpdate)
        respository.submitPersonalInfo(with: params) { result in
            completion(result)
        }
    }
    
    // 获取行政区域配置
    private func fetchRegionConfig(completion: @escaping (Result<RegionConfigModel, RequestError>) -> Void) {
        let exists = SandboxManager.shared.exists(fileName: "RegionData")
        guard !exists else {
            completion(.failure(RequestError.other(message: "exists")))
            return
        }
        respository.fetchRegionConfig { result in
            completion(result)
        }
    }
}

extension PersonalInfoModuleViewModel
{
    private func syncValuesToFiledValues(from model: PersonalInformationModel) {
        isUpdate = model.isUpdate
        filedValues[BackendUserPersonalInfoKeys.education] = model.educationLevel
        filedValues[BackendUserPersonalInfoKeys.address] = [
            BackendUserPersonalInfoKeys.homeProvince: model.homeProvince,
            BackendUserPersonalInfoKeys.homeCity: model.homeCity,
        ]
        filedValues[BackendUserPersonalInfoKeys.maritalStatus] = model.marriageStatus
        filedValues[BackendUserPersonalInfoKeys.jobType] = model.jobType
        filedValues[BackendUserPersonalInfoKeys.income] = model.monthlyIncome
        filedValues[BackendUserPersonalInfoKeys.email] = model.emial?.removeNull
        isDataComplete = validate()
    }
    
    /// 校验是否所有必填项都已完成
    func validate() -> Bool {
        let jobTypeValue = filedValues[BackendUserPersonalInfoKeys.jobType] as? Int
        let isSpecialJobType = (jobTypeValue == 4)
        
        return filedRows.allSatisfy { row in
            guard let info = row.infoModel else { return true }
            return info.keys.values.allSatisfy { backendKey in
                // ⭐️ 特殊逻辑：如果是 jobType == 4，则跳过对 income 字段的非空验证
                if isSpecialJobType && backendKey == BackendUserPersonalInfoKeys.income {
                    return true
                }
                var value: Any?
                if let parent = info.parentKey {
                    let parentDict = filedValues[parent] as? [String: Any]
                    value = parentDict?[backendKey]
                } else {
                    value = filedValues[backendKey]
                    if row.infoModel?.type == .email, let email = value as? String, !email.isValidEmail() {
                        value = "" 
                    }
                }
                return isNotEmpty(value)
            }
        }
    }
    
    /// 辅助方法：检查 Any 类型是否真正有内容
    private func isNotEmpty(_ value: Any?) -> Bool {
        guard let value = value else { return false }
        
        switch value {
        case let str as String:
            return !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case let collections as any Collection:
            return !collections.isEmpty
        default:
            return true // 其他类型（如 Bool, Int）只要非 nil 即视为有效
        }
    }
    
    // 1. 个人基础信息 (根据表单通用逻辑完善)
    func personalInfoFields() -> [IdentityInfoModel] {
        var list: [IdentityInfoModel] = []
        
        //教育程度
        list.append(IdentityInfoModel(
            type: .education,
            keys: ["value": BackendUserPersonalInfoKeys.education],
            fieldType: .choose,
            options: IdentityDataSource.education
        ))
        // 地区选择
        list.append(IdentityInfoModel(
            type: .address,
            parentKey: BackendUserPersonalInfoKeys.address,
            keys: [
                "province": BackendUserPersonalInfoKeys.homeProvince,
                "city": BackendUserPersonalInfoKeys.homeCity
            ],
            fieldType: .address
        ))
        // 婚姻状况
        list.append(IdentityInfoModel(
            type: .marriage,
            keys: ["value": BackendUserPersonalInfoKeys.maritalStatus],
            fieldType: .choose,
            options: IdentityDataSource.maritalStatus
        ))
        // 3. 工作/职业信息
        list.append(IdentityInfoModel(
            type: .jobType,
            keys: ["value": BackendUserPersonalInfoKeys.jobType],
            fieldType: .choose,
            options: IdentityDataSource.jobType
        ))
        // 月收入范围
        list.append(IdentityInfoModel(
            type: .monthlyIncome,
            keys: ["value": BackendUserPersonalInfoKeys.income],
            fieldType: .choose,
            options: IdentityDataSource.income
        ))
        // f_ocsz    email :zj7xK2z99hDs : f_ocsz: 电子邮箱,示例值(email)
        list.append(IdentityInfoModel(
            type: .email,
            keys: ["value": BackendUserPersonalInfoKeys.email],
            fieldType: .email,
            options: []
        ))
        return list
    }
}
