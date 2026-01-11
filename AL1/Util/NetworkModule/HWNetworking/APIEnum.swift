//
//  APIEnum.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation
import SwiftyJSON

enum RequestError: Error {
    case unlogin
    case notFound
    case decryptionFailed
    case other(message: String)
    case registerFailed(code: Int, message: String)
    
    /// 统一对外暴露的错误消息，优先使用接口返回的 message
    var message: String {
        switch self {
        case .unlogin:
            return "Sesión expirada, por favor inicie sesión nuevamente." // 登录失效，请重新登录
        case .notFound:
            return "El recurso no fue encontrado (404)." // 资源未找到
        case .decryptionFailed:
            return "Error al procesar los datos del servidor." // 数据解析/解密失败
        case .other(let msg):
            return msg.isEmpty ? "Error desconocido" : msg // 其他错误
        case .registerFailed(_, let msg):
            return msg.isEmpty ? "Error al registrarse" : msg // 注册失败
        }
    }
    
}

struct ResponseStatus: Equatable {
    let rawValue: Int

    // 静态常量模拟枚举成员
    static let failure   = ResponseStatus(rawValue: -1)
    static let success   = ResponseStatus(rawValue: 200)
    static let expired   = ResponseStatus(rawValue: 401) // 通常指 Token 过期
    static let kickOut   = ResponseStatus(rawValue: 402) // 异地登陆/踢出
    static let forbidden = ResponseStatus(rawValue: 403)
    static let notFound  = ResponseStatus(rawValue: 404)

    // 业务逻辑判断属性
    var isSuccess: Bool {
        return rawValue == 200
    }

    var isTokenExpired: Bool {
        return rawValue == 401
    }

    // 解析逻辑
    static func from(jsonValue: JSON) -> ResponseStatus {
        // 尝试从 Int 解析
        if let codeInt = jsonValue.error == nil ? jsonValue.int : nil {
            return ResponseStatus(rawValue: codeInt)
        }
        // 尝试从 String 解析
        if let codeString = jsonValue.string, let codeInt = Int(codeString) {
            return ResponseStatus(rawValue: codeInt)
        }
        return .failure
    }
}
