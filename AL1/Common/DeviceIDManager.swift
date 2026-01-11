//
//  DeviceIDManager.swift
//  AL1
//
//  Created by cashlee on 2026/1/8.
//

import UIKit
import Foundation

struct DeviceIDManager {
    
    private static let deviceIdKey = "com.yourapp.bundle.uniqueDeviceId"
    
    static func getDeviceId() -> String {
        // 1. 尝试从 Keychain 读取
        if let savedId = KeychainStorage.load(key: deviceIdKey), !savedId.isEmpty {
            return savedId
        }
        
        // 2. 如果没有，则获取 identifierForVendor
        let newId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        // 3. 存入 Keychain 备用
        KeychainStorage.save(key: deviceIdKey, data: newId)
        
        return newId
    }
}
