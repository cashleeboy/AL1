//
//  KeychainStorage.swift
//  AL1
//
//  Created by cashlee on 2026/1/8.
//

import Foundation
import Security

class KeychainStorage {
    
    /// 保存数据到 Keychain
    static func save(key: String, data: String) {
        guard let dataFromString = data.data(using: .utf8) else { return }
        
        // 构建查询字典
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: dataFromString
        ]
        
        // 先尝试删除旧数据，确保新数据能存入
        SecItemDelete(query as CFDictionary)
        
        // 插入新数据
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// 从 Keychain 读取数据
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    /// 从 Keychain 删除数据
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
