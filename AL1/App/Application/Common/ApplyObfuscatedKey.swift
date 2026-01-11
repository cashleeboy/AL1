//
//  ObfuscatedKey.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import Foundation

struct ApplyObfuscatedKey {
    // MARK: - 通用字段
    enum Common: String {
        case isUpdate = "bBtGjDe0q125C"
    }

    // MARK: - 业务模块根键
    enum Root: String {
        case personalInfo = "erdFQn7J0XH_"
        case contactList  = "kpYQyyzvbe0Zaq"
        case bankInfo     = "aoAs1UcI"
        case identityInfo = "civiwTyRgTQyL"
        case ocrSubmit = "toa0ZkswvKE"
    }
    
    //
    enum OCRVerify: String {
        case type = "mgkeUyzUHHGmht"
        case multipartFile = "w_6A_2p"
        
        case latitude = "glP3_zIv7G"
        case longitude = "rBvyt"
        case wifi = "f0adQd_jKnDZ"
    }
    //
    enum FaceVerify: String {
        case isUpdate = "bBtGjDe0q125C"
        case processId = "cFRG9wgscv7vM28cYI6"
        case step = "bfWGqB3J8SL"
        
        case latitude = "glP3_zIv7G"
        case longitude = "rBvyt"
    }
}

extension ApplyObfuscatedKey {
    
    // MARK: - 辅助工具方法
    
    /// 构建标准请求参数字典
    /// - Parameters:
    ///   - rootKey: 业务模块对应的混淆根键
    ///   - value: 实际要上传的业务数据 (字典或数组)
    ///   - isUpdate: 是否为更新模式，默认为 0
    static func makeParams(rootKey: Root, value: Any, isUpdate: Int = 0) -> [String: Any] {
        return [
            Common.isUpdate.rawValue: isUpdate,
            rootKey.rawValue: value
        ]
    }
    
}
