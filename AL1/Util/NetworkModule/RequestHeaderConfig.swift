//
//  RequestHeaderConfig.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import UIKit
import Foundation

/// 统一管理请求头/固定参数的配置类
struct RequestHeaderConfig
{
    @Storage(key: "app_channel_key", defaultValue: "")
    static var channel: String
    
    @Storage(key: "app_token_id_key", defaultValue: "")
    static var tokenId: String
    
    @Storage(key: "app_client_type_key", defaultValue: "ios")
    static var clienType
    
    @Storage(key: "app_ase_key", defaultValue: "")
    static var aesKey
    
    // Adjust 专属标识符，通常用于归因分析
    @Storage(key: "app_adjust_adid_key", defaultValue: "")
    static var adjustAdid: String
    
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    static var appVersionInt: String {
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        // 移除所有小数点，例如 "1.0.2" -> "102"
        let cleanString = versionString.replacingOccurrences(of: ".", with: "")
        return cleanString
    }
    
    // 保持计算属性，因为它是根据设备实时生成的
    static var deviceUdid: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    static var deviceIdfa: String {
        return AppIDFAProvider.shared.getIDFA()
    }
    
}
