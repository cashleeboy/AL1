//
//  AuthStatusModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/23.
//

import Foundation
import SwiftyJSON

enum AuthStepType: Int, CaseIterable {
    case personalInfo = 1    // 个人信息
    case contactInfo = 2     // 联系人信息
    case bankCardInfo = 3    // 银行卡信息
    case identityInfo = 4    // 身份认证信息
    case faceRecognieInfo = 5
    case isDataValid
    case unknown = 0

    var title: String {
        switch self {
        case .personalInfo: return "Información Personal"
        case .contactInfo:  return "Contactos de Emergencia"
        case .bankCardInfo: return "Tarjeta Bancaria"
        case .identityInfo: return "Verificación de Identidad"
        case .faceRecognieInfo: return "Reconocimiento facial"
        case .isDataValid: return "Completa la información"
        case .unknown:      return ""
        }
    }
    
    // 也可以根据接口返回的 pageType 字符串进行映射
    init(pageType: String) {
        switch pageType {
        case "personal": self = .personalInfo
        case "contact":  self = .contactInfo
        case "bank":     self = .bankCardInfo
        case "identity": self = .identityInfo
        case "face":     self = .faceRecognieInfo
        case "dataValid":self = .isDataValid
        default:         self = .unknown
        }
    }
}

// MARK: - 认证总状态模型
struct AuthStatusModel: DecodableData {
    // 已填步骤 步骤的值是从1开始的 0一步都没填 1即第一步已填 2即第二步已填
    let filledStep: Int             // zWJQ6: 已完成步数
    let totalStep: Int              // lvLz9eI: 总步数
    let pages: [AuthPageModel]      // vsNJAJ7Q9: 页面列表
    
    /// 获取当前正在进行的步骤类型
    var currentStepType: AuthStepType {
        // 通常当前步数是已完成步数 + 1
        return AuthStepType(rawValue: filledStep + 1) ?? .unknown
    }
    
    /// 检查所有步骤是否已完成
    var isAllStepsFinished: Bool {
        return filledStep >= totalStep
    }
    
    init(json: JSON) {
        self.filledStep = json["zWJQ6"].intValue
        self.totalStep = json["lvLz9eI"].intValue
        self.pages = json["vsNJAJ7Q9"].arrayValue.map { AuthPageModel(json: $0) }
    }
}

// MARK: - 页面模型
struct AuthPageModel {
    let pageTitle: String           // wASNcKIWiyn_A: 页面标题
    let pageType: String            // lt8VbbFGwmzFt: 页面类型 (如: personal, work等)
    let step: Int                   // bfWGqB3J8SL: 当前步数索引
    let fields: [AuthFieldModel]    // ojxyvic_PoU: 该页面下的输入项字段

    var stepType: AuthStepType {
        return AuthStepType(rawValue: step) ?? .unknown
    }
    
    init(json: JSON) {
        self.pageTitle = json["wASNcKIWiyn_A"].stringValue
        self.pageType = json["lt8VbbFGwmzFt"].stringValue
        self.step = json["bfWGqB3J8SL"].intValue
        self.fields = json["ojxyvic_PoU"].arrayValue.map { AuthFieldModel(json: $0) }
    }
}

// MARK: - 表单字段模型
struct AuthFieldModel {
    let code: String                // yZkvyDY2J: 字段编号
    let defaultText: String         // vsENCVxW8: 默认显示文本
    let key: String                 // rl6ruFOPiZ_gUHRzC4: 提交时的字段名
    let isMust: Bool                // woZte57Hn_QlKjVBp: 是否必填
    let order: Int                  // puIAQ: 排序
    let regex: String               // e4bGqqz4: 正则表达式校验规则
    let showContent: String         // pQHwN9uR0nOEqyXpwb: 显示内容
    let submitValue: String         // c0XfNgY8d: 提交值
    let type: String                // mgkeUyzUHHGmht: 输入类型 (如: text, select, date等)
    let options: [AuthOptionModel]  // pL38YPT5tmV_gQr1: 下拉选项列表

    init(json: JSON) {
        self.code = json["yZkvyDY2J"].stringValue
        self.defaultText = json["vsENCVxW8"].stringValue
        self.key = json["rl6ruFOPiZ_gUHRzC4"].stringValue
        self.isMust = json["woZte57Hn_QlKjVBp"].boolValue
        self.order = json["puIAQ"].intValue
        self.regex = json["e4bGqqz4"].stringValue
        self.showContent = json["pQHwN9uR0nOEqyXpwb"].stringValue
        self.submitValue = json["c0XfNgY8d"].stringValue
        self.type = json["mgkeUyzUHHGmht"].stringValue
        self.options = json["pL38YPT5tmV_gQr1"].arrayValue.map { AuthOptionModel(json: $0) }
    }
}

// MARK: - 下拉选项模型
struct AuthOptionModel {
    let key: String                 // rl6ruFOPiZ_gUHRzC4
    let value: String               // kq8KJJni

    init(json: JSON) {
        self.key = json["rl6ruFOPiZ_gUHRzC4"].stringValue
        self.value = json["kq8KJJni"].stringValue
    }
}

/*
 检测数据是否有效
 {
         "rfgZk_CKTT3mzI4t": "isValid"
     },
 **/

struct UserDataValidModel: DecodableData {
    /// 数据是否有效
    let isValid: Bool
    
    init(json: JSON) {
        // 使用提供的混淆键进行解析
        // 根据业务习惯，如果字段不存在，默认设为 false 以保证安全
        self.isValid = json["rfgZk_CKTT3mzI4t"].boolValue
    }
}
