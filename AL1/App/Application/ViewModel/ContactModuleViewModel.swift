//
//  ContactModuleViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import Combine
import Foundation

enum ContactField {
    case relation(key: Int)
    case identity(name: String?, mobile: String?)
}

// 独立的联系人 ViewModel
class ContactModuleViewModel: ObservableObject, ApplicationAuthModuleProtocol {
    var reviewType: InfoReviewType = .contact

    @Published var selectedContactMap: [String: [String: String]] = [:]
    lazy var cancellables = Set<AnyCancellable>()
    
    internal var isUpdate: Int = 0
    @Published var isDataComplete: Bool = false
    
    var contactRows: [FormContactRowFormer<FormContactCell>] = []
    private lazy var respository = ApplyRepository()
    var isDataCompletePublisher: AnyPublisher<Bool, Never> {
        $isDataComplete.eraseToAnyPublisher()
    }
    private static var areaCode: String = "51"
    // 假设这是从 UserSession 或其他地方获取的注册手机号
    var userRegisteredMobile: String {
        let fullMobile = UserSession.shared.mobile ?? ""
        if fullMobile.hasPrefix(Self.areaCode) {
            return String(fullMobile.dropFirst(Self.areaCode.count))
        }
        return fullMobile
    }
    
    @discardableResult
    func updateContact(with info: ContactInfoModel, field: ContactField, needToValid: Bool = false) -> Bool {
        var currentDict = selectedContactMap[info.contactTitle] ?? [:]
        
        switch field {
        case .relation(let key):
            currentDict[info.relactionKey] = String(key)
        case .identity(let name, let mobile):
            // 需要检查，如果mobile重复了，就不能赋值，直接return false
            let cleanMobile = normalizePhoneNumber(mobile ?? "").trimmed.filter { $0.isNumber }
            if needToValid {
                let isDuplicate = selectedContactMap.contains { (title, dict) in
                    // 排除当前正在编辑的这个联系人（按 title 区分）
                    guard title != info.contactTitle else { return false }
                    return dict[info.mobileKey] == cleanMobile
                }
                if isDuplicate {
                    return false // 仅在需要验证且发现重复时返回 false
                }
            }
            currentDict[info.mobileKey] = cleanMobile
            if let name {
                currentDict[info.nameKey] = name.trimmed
            }
        }
        
        selectedContactMap[info.contactTitle] = currentDict
        isDataComplete = validate()
        return true
    }
    
    func updateContactValue(at key: String, with contact: EmergencyContactModel) {
        var currentDict = selectedContactMap[key] ?? [:]
        currentDict[BackendUserContactKeys.contactRelationship] = contact.relationship
        currentDict[BackendUserContactKeys.contactName] = contact.name
        currentDict[BackendUserContactKeys.contactPhoneNumber] = contact.phoneNumber
        currentDict[BackendUserContactKeys.catactId] = contact.id
        selectedContactMap[key] = currentDict
        isDataComplete = validate()
    }
    
    func fetchData(completion: @escaping (Result<EmergencyContactContainerModel, RequestError>) -> Void) {
        respository.queryContacts { [weak self] result in
            guard let self else { return }
            if case .success(let success) = result {
                isUpdate = success.isUpdate
            }
            completion(result)
        }
    }
    
    func submitData(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        guard isDataComplete else {
            return
        }
        
        if let error = checkMobileConflicts() {
            completion(.failure(.registerFailed(code: -1, message: error.message)))
            return
        }
        
        let contactValues = Array(selectedContactMap.values)
        let params = ApplyObfuscatedKey.makeParams(
            rootKey: .contactList,
            value: contactValues, isUpdate: isUpdate)
        respository.submitContacts(with: params) { result in
            completion(result)
        }
    }
    
    // 手机号码判断逻辑
    func checkMobileConflicts() -> ContactValidationError? {
        let mobiles = selectedContactMap.values.compactMap { dict -> String? in
            guard let phone = dict[BackendUserContactKeys.contactPhoneNumber] else { return nil }
            return normalizePhoneNumber(phone)
        }
        
        let uniqueMobiles = Set(mobiles)
        if uniqueMobiles.count < mobiles.count {
            return .duplicateMobile
        }
        let normalizedUserMobile = normalizePhoneNumber(userRegisteredMobile)
        if mobiles.contains(normalizedUserMobile) {
            return .matchesRegisteredMobile
        }
        return nil
    }
    
    /// 辅助方法：归一化手机号，移除前缀 areaCode
    private func normalizePhoneNumber(_ phone: String) -> String {
        let prefix = Self.areaCode
        if phone.hasPrefix(prefix) {
            return String(phone.dropFirst(prefix.count))
        }
        return phone
    }
}

extension ContactModuleViewModel {
    func validate() -> Bool {
        // 假设业务要求必须填写 2 位联系人（根据实际情况修改）
        guard selectedContactMap.count >= 2 else { return false }
        
        // 2. 完整性校验：确保每一行的数据都已填满
        let isAllFilled = contactRows.allSatisfy { row in
            guard let info = row.infoModel,
                  let data = selectedContactMap[info.contactTitle] else { return false }
            
            return [info.nameKey, info.mobileKey, info.relactionKey].allSatisfy { key in
                !(data[key]?.isEmpty ?? true)
            }
        }
        
        guard isAllFilled else { return false }
        
        // 3. 手机号重复校验：提取所有手机号并去重
        let allMobiles = contactRows.compactMap { row -> String? in
            guard let info = row.infoModel,
                  let data = selectedContactMap[info.contactTitle],
                  let mobile = data[info.mobileKey] else { return nil }
            return normalizePhoneNumber(mobile)
        }
        
        // 使用 Set 去重后，如果数量减少，说明存在重复手机号
        let uniqueMobiles = Set(allMobiles)
        return uniqueMobiles.count == allMobiles.count
    }
    
    func contactInfoFields() -> [ContactInfoModel] {
        var list: [ContactInfoModel] = []
        
        // 紧急联系人 1
        let emergencia1 = ContactInfoModel(
            type: .relationship,
            contactTitle: "Contacto de emergencia1",
            relactionType: .choose,
            nameType: .choose,
            mobileType: .contact,
            options: IdentityDataSource.contactRelation
        )
        
        // 紧急联系人 2
        let emergencia2 = ContactInfoModel(
            type: .relationship,
            contactTitle: "Contacto de emergencia2",
            relactionType: .choose,
            nameType: .choose,
            mobileType: .contact,
            options: IdentityDataSource.contactRelation
        )
        list.append(emergencia1)
        list.append(emergencia2)
        return list
    }
}
