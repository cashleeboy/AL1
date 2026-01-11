//
//  ServiceInquiryModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import Foundation
import SwiftyJSON

// 1.电话 2.whatsapp 3.邮箱
enum ServiceInquiryType: Int {
    case phone = 1
    case whatsapp
    case email
    
    var displayName: String {
        switch self {
        case .phone:
            "línea directa al consumidor"
        case .whatsapp:
            "WhatsApp"
        case .email:
            "Correo electrónico"
        }
    }
    var functionTitle: String {
        switch self {
        case .phone:
            "Llamar"
        case .whatsapp:
            "Contactar"
        case .email:
            "Copiar"
        }
    }
    
    static func getCaseType(for tag: Int) -> ServiceInquiryType? {
        switch tag {
        case 1: return .phone
        case 2: return .whatsapp
        case 3: return .email
        default: return nil
        }
    }
}

struct ServiceInquiryModel: DecodableData {
    let items: [ServiceInquiryItem]
    init(json: SwiftyJSON.JSON) {
        self.items = json["jugl8T3fDby0yVZx0v2N"].arrayValue.map {
            ServiceInquiryItem(json: $0)
        }
    }
}

struct ServiceInquiryItem: DecodableData, Codable {
    let content: String  // 对应 julu74JUb (手机号/链接/邮箱)
    let types: [Int]     // 对应 mgkeUyzUHHGmht
    // 核心优化：将 Int 映射为枚举
    var inquiryTypes: [ServiceInquiryType] {
        return types.compactMap { ServiceInquiryType(rawValue: $0) }
    }
    init(json: JSON) {
        self.content = json["julu74JUb"].stringValue
        self.types = json["mgkeUyzUHHGmht"].arrayValue.compactMap { $0.int }
    }
}
