//
//  SandboxManager.swift
//  AL1
//
//  Created by cashlee on 2025/12/25.
//

import Foundation
import SwiftyJSON

class SandboxManager {
    static let shared = SandboxManager()
    private init() {}
    
    // 默认文件名常量
    private let defaultFileName = "AppDefaultData.plist"
    
    // MARK: - 路径获取
    /// 获取沙盒指定目录的 URL
    private func getDirectoryPath(for directory: FileManager.SearchPathDirectory = .documentDirectory) -> URL {
        if let url = FileManager.default.urls(for: directory, in: .userDomainMask).first {
            return url
        }
        return FileManager.default.temporaryDirectory
    }
    
    /// 构建完整的文件路径
    private func getFilePath(fileName: String?, directory: FileManager.SearchPathDirectory) -> URL {
        let name = fileName ?? defaultFileName
        // 确保文件名有 .plist 后缀
        let finalName = name.lowercased().hasSuffix(".plist") ? name : "\(name).plist"
        return getDirectoryPath(for: directory).appendingPathComponent(finalName)
    }

    // MARK: - 存储功能 (Save)
    
    /// 存储字典数据
    /// - Parameters:
    ///   - data: 要存储的内容
    ///   - fileName: 自定义文件名，传 nil 则使用默认值
    ///   - directory: 存储目录，默认为 .documentDirectory
    @discardableResult
    func save(data: [String: Any], to fileName: String? = nil, in directory: FileManager.SearchPathDirectory = .documentDirectory) -> Bool {
        let path = getFilePath(fileName: fileName, directory: directory)
        let nsDictionary = data as NSDictionary
        
        do {
            // 在 iOS 11+ 推荐使用 write(to:) throws
            try nsDictionary.write(to: path)
            print("✅ [Sandbox] Saved successfully to: \(path.lastPathComponent)")
            return true
        } catch {
            print("❌ [Sandbox] Save failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - 读取功能 (Load)
    
    /// 读取字典数据
    func load(from fileName: String? = nil, in directory: FileManager.SearchPathDirectory = .documentDirectory) -> [String: Any]? {
        let path = getFilePath(fileName: fileName, directory: directory)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        return NSDictionary(contentsOf: path) as? [String: Any]
    }

    // MARK: - 文件管理 (Manage)
    
    /// 删除指定文件
    func remove(fileName: String, in directory: FileManager.SearchPathDirectory = .documentDirectory) {
        let path = getFilePath(fileName: fileName, directory: directory)
        try? FileManager.default.removeItem(at: path)
    }
    
    /// 检查文件是否存在
    func exists(fileName: String, in directory: FileManager.SearchPathDirectory = .documentDirectory) -> Bool {
        let path = getFilePath(fileName: fileName, directory: directory)
        return FileManager.default.fileExists(atPath: path.path)
    }
    
    /// 获取文件修改时间 (用于判断数据是否过期)
    func getModificationDate(for fileName: String, in directory: FileManager.SearchPathDirectory = .documentDirectory) -> Date? {
        let path = getFilePath(fileName: fileName, directory: directory)
        let attributes = try? FileManager.default.attributesOfItem(atPath: path.path)
        return attributes?[.modificationDate] as? Date
    }
}

extension SandboxManager {
    /// 异步读取并解析行政区域数据
    func loadRegionConfigAsync(fileName: String? = "RegionData", completion: @escaping (RegionConfigModel?) -> Void) {
        // 切换到后台线程读取文件和解析
        DispatchQueue.global(qos: .userInitiated).async {
            if let dict = self.load(from: fileName),
               let jsonData = try? JSONSerialization.data(withJSONObject: dict) {
                let json = JSON(jsonData)
                let model = RegionConfigModel(json: json)
                
                // 回到主线程返回结果
                DispatchQueue.main.async {
                    completion(model)
                }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
