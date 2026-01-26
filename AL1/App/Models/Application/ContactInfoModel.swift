//
//  ContactInfoModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/24.
//

import Foundation
import SwiftyJSON

struct ContactInfoModel {
    let type: PersonalType
    let contactTitle: String    // UI 标题: "Contacto de emergencia1"
    // 1. 关系字段映射
    let relaction: String = "Relación"
    let relactionType: IdentityFieldType
    let relactionKey: String = BackendUserContactKeys.contactRelationship
    
    // 2. 姓名字段映射
    let name: String = "Nombre y apellido"
    let nameType: IdentityFieldType
    let nameKey: String = BackendUserContactKeys.contactName
    
    // 3. 电话字段映射
    let mobile: String = "Número de teléfono móvil"
    let mobileType: IdentityFieldType
    let mobileKey: String = BackendUserContactKeys.contactPhoneNumber
    
    // 4. 后台逻辑字段
    let idKey: String = BackendUserContactKeys.catactId // 对应 "wGlVByadhXXG4SRrlX"
    let options: [IdentityOption]?
    
}


// MARK: - 联系人列表容器
struct EmergencyContactContainerModel: DecodableData {
    let contactNum: String               // jS3mp: 联系人数量要求或总数
    let contacts: [EmergencyContactModel] // kpYQyyzvbe0Zaq: 联系人数组

    var isUpdate: Int {
        contacts.isEmpty ? 0 : 1
    }
    
    init(json: JSON) {
        // 定位到 data 根节点
        self.contactNum = json["jS3mp"].stringValue
        self.contacts = json["kpYQyyzvbe0Zaq"].arrayValue.map { EmergencyContactModel(json: $0) }
    }
}

// MARK: - 单个联系人模型
struct EmergencyContactModel {
    let id: String                       // wGlVByadhXXG4SRrlX
    let name: String                     // bGuOvX4
    let phoneNumber: String              // p3nOi4vepcURroO
    let relationship: String             // kX_zmVzAOAfx

    init(json: JSON) {
        self.id = json["wGlVByadhXXG4SRrlX"].stringValue
        self.name = json["bGuOvX4"].stringValue
        self.phoneNumber = json["p3nOi4vepcURroO"].stringValue
        self.relationship = json["kX_zmVzAOAfx"].stringValue
    }
}

 
