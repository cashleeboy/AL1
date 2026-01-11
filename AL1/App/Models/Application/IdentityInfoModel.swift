//
//  IdentityInfoModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import Foundation
import SwiftyJSON

enum PersonalType {
    // personal type
    case education
    case address
    case marriage
    case jobType
    case monthlyIncome
    case email
    
    // contactRelation
    case relationship
    
    // cer type
    case ocr
    case name
    case lastName
    case middleName
    case genero
    case nuiNumber
    case birthday
    
    // bank
    case bankName
    case bankAccountType
    case CCI
    case bankNumber
    
    var display: String {
        switch self {
        case .education:
            "Nivel educativo"
        case .address:
            "Dirección de domicilio"
        case .marriage:
            "Estado civil"
        case .jobType:
            "Tipo de empleo"
        case .monthlyIncome:
            "Ingresos mensuales"
        case .name:
            "Nombre"
        case .lastName:
            "apellido paterno"
        case .middleName:
            "apellido materno"
        case .genero:
            "Género"
        case .nuiNumber:
            "NUI Number"
        case .birthday:
            "Fecha de nacimiento"
        case .bankName:
            "Seleccione su banco"
        case .bankAccountType:
            "Tipo de Cuenta Bancaria"
        case .CCI:
            "CCI（código de cuenta interbancaria）"
        case .bankNumber:
            "Número de cuenta bancaria"
        case .email:
            "Correo"
        default:
            ""
        }
    }
    
    /// 根据 Key 查找对应的显示文字
    func getDisplayValue(for keyString: String) -> String? {
        guard let key = Int(keyString) else { return "" }
        switch self {
        case .education:
            return IdentityDataSource.find(key: key, at: \.education)?.value
        case .address:
            return nil
        case .marriage:
            return IdentityDataSource.find(key: key, at: \.maritalStatus)?.value
        case .jobType:
            return IdentityDataSource.find(key: key, at: \.jobType)?.value
        case .monthlyIncome:
            return IdentityDataSource.find(key: key, at: \.income)?.value
        case .bankAccountType:
            return IdentityDataSource.find(key: key, at: \.bankAccountType)?.value
        case .relationship:
            return IdentityDataSource.find(key: key, at: \.contactRelation)?.value
        default:
            return nil
        }
    }
    func getIndexValue(for keyString: String) -> Int? {
        guard let key = Int(keyString) else { return nil }
        switch self {
        case .education:
            return IdentityDataSource.findIndex(key: key, at: \.education)
        case .address:
            return nil
        case .marriage:
            return IdentityDataSource.findIndex(key: key, at: \.maritalStatus)
        case .jobType:
            return IdentityDataSource.findIndex(key: key, at: \.jobType)
        case .monthlyIncome:
            return IdentityDataSource.findIndex(key: key, at: \.income)
        case .bankAccountType:
            return IdentityDataSource.findIndex(key: key, at: \.bankAccountType)
        case .relationship:
            return IdentityDataSource.findIndex(key: key, at: \.contactRelation)
        default:
            return nil
        }
    }
}

extension PersonalType {
    /// 映射 OCR 结果中的属性名
    var ocrKeyPath: KeyPath<OCRDataProtocol, String>? {
        switch self {
        case .education:  return nil
        case .genero:     return \.gender
        case .name:       return \.firstName
        case .lastName:   return \.lastName
        case .middleName: return \.middleName
        case .nuiNumber:  return \.idCardNumber
        case .birthday:   return \.birthday
        default:          return nil
        }
    }
}

struct IdentityInfoModel {
    let type: PersonalType
    let parentKey: String?
    
    let keys: [String: String]
    var fieldType: IdentityFieldType
    let extraString: String?
    
    /// 新增：存储该字段对应的所有下拉选项
    let options: [IdentityOption]
    
    init(type: PersonalType,
        parentKey: String? = nil,
         keys: [String: String],
         fieldType: IdentityFieldType,
         options: [IdentityOption] = [], // 默认空数组
         extraString: String? = nil) {
        
        self.type = type
        self.parentKey = parentKey
        self.keys = keys
        self.fieldType = fieldType
        self.options = options
        self.extraString = extraString
    }
}


/// 单个选项模型（对应 JSON 里的每一项）
struct IdentityOption {
    let key: Int
    let value: String
}

// by api
struct PersonalInformationModel: DecodableData {
    // 对应 erdFQn7J0XH_
    let educationLevel: String       // cflUfqx0Hm5rdCF5t2i: 教育程度
    let marriageStatus: String       // h5ZwoWwxNU3pQhh: 婚姻状况
    let monthlyIncome: String        // bDLSxT_: 月收入
    let jobType: String             // gom2DQegrfwHx: 工作类型
    let emial: String?
    
    // 居住地信息 (对应 t521iItdEA0qUD 层级)
    let homeProvince: String         // t521iItdEA0qUD
    let homeCity: String             // qi4Ljjf3mE4
    var isUpdate: Int = 0
    
    /// 将字段映射为类型字典
    var valuesMap: [PersonalType: String] {
        return [
            .education: educationLevel,
            .marriage: marriageStatus,
            .monthlyIncome: monthlyIncome,
            .jobType: jobType,
            .email: emial ?? "",
        ]
    }
    
    init(json: JSON) {
        // 先定位到数据核心层 erdFQn7J0XH_
        let data = json["erdFQn7J0XH_"]
        isUpdate = data.isEmpty ? 0 : 1
        
        self.educationLevel = data["cflUfqx0Hm5rdCF5t2i"].stringValue
        self.marriageStatus = data["h5ZwoWwxNU3pQhh"].stringValue
        self.monthlyIncome = data["bDLSxT_"].stringValue
        self.jobType = data["gom2DQegrfwHx"].stringValue
        self.emial = data["f_ocsz"].string
        
        // 解析嵌套的地址信息
        let address = data["t521iItdEA0qUD"]
        self.homeProvince = address["t521iItdEA0qUD"].stringValue
        self.homeCity = address["qi4Ljjf3mE4"].stringValue
    }
}
