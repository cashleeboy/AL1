//
//  EncryptionProvider.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation
import CommonCrypto

struct EncryptionProvider {
    
    // MARK: - 加密方法 (AES-128-ECB)
    
    /// 将明文字符串加密为 Base64 字符串
    /// - Parameters:
    ///   - plainText: 需要加密的原文 (JSON 字符串等)
    ///   - key: 16 位的 AES 密钥 (例如: "qG3zS3tD9rJ8mP8z")
    /// - Returns: 加密后的 Base64 编码字符串
    static func encrypt(plainText: String, key: String) -> String? {
        guard let data = plainText.data(using: .utf8),
              let keyData = key.data(using: .utf8) else { return nil }
        
        let dataSize = data.count
        let bufferSize = dataSize + kCCBlockSizeAES128
        var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        var bytesEncrypted = 0
        
        // ⭐️ 关键配置：kCCOptionPKCS7Padding | kCCOptionECBMode
        // 必须与解密端（后端）的模式完全一致
        let options = CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode)
        
        let status = keyData.withUnsafeBytes { keyBytes in
            data.withUnsafeBytes { dataBytes in
                CCCrypt(CCOperation(kCCEncrypt),      // 执行加密操作
                        CCAlgorithm(kCCAlgorithmAES),
                        options,
                        keyBytes.baseAddress, kCCKeySizeAES128,
                        nil,                          // ECB模式不需要IV
                        dataBytes.baseAddress, dataSize,
                        buffer, bufferSize,
                        &bytesEncrypted)
            }
        }
        
        if status == kCCSuccess {
            let encryptedData = Data(bytes: buffer, count: bytesEncrypted)
            return encryptedData.base64EncodedString()
        } else {
            print("AES加密失败，错误码: \(status)")
            return nil
        }
    }
    
    static func decrypt(cipherText: String, key: String) -> String? {
        // 1. Base64 解码
        guard let data = Data(base64Encoded: cipherText),
              let keyData = key.data(using: .utf8) else { return nil }
        
        let dataSize = data.count
        let bufferSize = dataSize + kCCBlockSizeAES128
        var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        var bytesDecrypted = 0
        
        // 2. 关键配置：kCCOptionPKCS7Padding | kCCOptionECBMode
        // 很多后端接口默认使用 ECB 模式以减少 IV 传输
        let options = CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode)
        
        let status = keyData.withUnsafeBytes { keyBytes in
            data.withUnsafeBytes { dataBytes in
                CCCrypt(CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        options,
                        keyBytes.baseAddress, kCCKeySizeAES128,
                        nil, // ECB 模式下 IV 传 nil
                        dataBytes.baseAddress, dataSize,
                        buffer, bufferSize,
                        &bytesDecrypted)
            }
        }
        
        if status == kCCSuccess {
            let decryptedData = Data(bytes: buffer, count: bytesDecrypted)
            return String(data: decryptedData, encoding: .utf8)
        } else {
            print("AES解密失败，错误码: \(status)")
            return nil
        }
    }
}

extension EncryptionProvider {
    
    /// 将字典转换为加密后的 Base64 字符串
    /// - Parameters:
    ///   - params: 请求参数字典
    ///   - key: AES 密钥
    /// - Returns: 加密后的字符串（用于 Body 传输）
    static func encryptParameters(_ params: [String: Any], key: String) -> String? {
        // 1. 字典转 Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            print("❌ 字典转换为 Data 失败")
            return nil
        }
        
        // 2. Data 转 JSON 字符串
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Data 转换为 String 失败")
            return nil
        }
        
        // 3. 调用之前的 AES 加密方法
        return encrypt(plainText: jsonString, key: key)
    }
}
