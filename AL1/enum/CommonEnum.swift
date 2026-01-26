//
//  CommonEnum.swift
//  AL1
//
//  Created by cashlee on 2026/1/5.
//

import Foundation

enum AppEnvironment {
    case dev, test, prod
    
    var baseURL: String {
        switch self {
        case .dev:  return "https://dcvmozkwnr.ruammitpico.com"
        case .test: return "https://al-test-app-manager10.quarksre.com"
        case .prod: return "https://dcvmozkwnr.ruammitpico.com"
        }
    }
    
    // H5 网页域名 (你提供的域名)
    var h5BaseURL: String {
        switch self {
        case .dev:  return "https://eiuhcfgska.ruammitpico.com"
        case .test: return "https://al-test-al10-h5.quarksre.com"
        case .prod: return "https://eiuhcfgska.ruammitpico.com" // 生产环境通常不同
        }
    }
}

struct AppConfig {
    // 建议通过 Compiler Flag 或 xcconfig 动态指定
    #if DEBUG
    static var currentEnv: AppEnvironment = .test
    #else
    static var currentEnv: AppEnvironment = .test
//    static var currentEnv: AppEnvironment = .dev
    #endif
}

enum H5Url {
    case privacyPolicy
    case feedback(token: String)
    
    private var path: String {
        switch self {
        case .privacyPolicy:   return "/Ez7n7QHZ6lIHEE.html"
        case .feedback:        return "/feedback.html"
        }
    }
    
    var urlString: String {
        let base = AppConfig.currentEnv.h5BaseURL
        
        // 使用 URLComponents 安全地处理 Query 注入
        guard var components = URLComponents(string: base + path) else {
            return base + path
        }
        
        switch self {
        case .feedback(let token):
            components.queryItems = [URLQueryItem(name: "token", value: token)]
        default:
            break
        }
        
        return components.url?.absoluteString ?? (base + path)
    }
    
    var url: URL? {
        return URL(string: urlString)
    }
}


enum ContactValidationError: Error {
    case duplicateMobile         // 联系人手机号重复
    case matchesRegisteredMobile // 联系人手机号与注册手机号一致
    
    var message: String {
        switch self {
        case .duplicateMobile: return "El teléfono de contacto no puede ser el mismo"
        case .matchesRegisteredMobile: return "El número de teléfono de contacto no puede ser su número registrado"
        }
    }
}

