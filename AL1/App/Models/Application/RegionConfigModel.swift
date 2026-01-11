//
//  RegionConfigModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import Foundation
import SwiftyJSON

class RegionConfigModel: DecodableData {
    let regions: [RegionItem]
    let provinces: [RegionItem]
    
    // 内存索引表：Key 是 parentId, Value 是该父节点下的所有子城市数组
    private var regionIndex: [String: [RegionItem]] = [:]
    
    // 逻辑：如果 regions 不为空则加 1，如果 provinces 不为空则再加 1
    var count: Int {
        var total = 0
        if !regions.isEmpty { total += 1 }
        if !provinces.isEmpty { total += 1 }
        return total
    }

    required init(json: JSON) {
        let regionsData = json["uGzMPtoyALLEZf0L7s"].exists() ? json["uGzMPtoyALLEZf0L7s"] : json["regions"]
        let provincesData = json["mlMEvY0qG_"].exists() ? json["mlMEvY0qG_"] : json["provinces"]
        
        self.regions = regionsData.arrayValue.map { RegionItem(json: $0) }
        self.provinces = provincesData.arrayValue.map { RegionItem(json: $0) }
        buildIndex()
    }
    
    // 转换为持久化所需的字典格式
    func toDictionary() -> [String: Any] {
        return [
            "regions": regions.map { $0.toDictionary() },
            "provinces": provinces.map { $0.toDictionary() }
        ]
    }
    
    /// 高效查询：时间复杂度为 O(1)
    func getRegions(forProvinceId provinceId: String) -> [RegionItem] {
        return regionIndex[provinceId] ?? []
    }
    
    /// 获取指定索引下的具体对象 (方便 CellForRow 使用)
    func item(at section: Int, row: Int) -> RegionItem? {
        if section == 0 {
            return provinces.indices.contains(row) ? provinces[row] : nil
        } else if section == 1 {
            return regions.indices.contains(row) ? regions[row] : nil
        }
        return nil
    }
    
    // 建立索引：只需在初始化时遍历一次
    private func buildIndex() {
        regionIndex = Dictionary(grouping: regions, by: { $0.parentId })
    }
}

extension RegionConfigModel {
    /// 获取指定省份 ID 在 provinces 数组中的索引
    func getProvinceIndex(id: String) -> Int? {
        return provinces.firstIndex(where: { $0.id == id })
    }
    
    /// 获取指定城市 ID 在其所属省份下的 regions 数组中的索引
    /// - Parameters:
    ///   - id: 城市 ID
    ///   - provinceId: 该城市所属的省份 ID
    func getRegionIndex(id: String, provinceId: String) -> Int? {
        // 先获取该省份下所有的子城市
        let subRegions = getRegions(forProvinceId: provinceId)
        // 在子城市数组中查找索引
        return subRegions.firstIndex(where: { $0.id == id })
    }
}

class RegionItem: DecodableData {
    let id: String
    let name: String
    let parentId: String
    
    required init(json: JSON) {
        // 优先读取网络混淆 Key，如果不存在则读取沙盒可读 Key
        self.id = json["wGlVByadhXXG4SRrlX"].exists() ? json["wGlVByadhXXG4SRrlX"].stringValue : json["id"].stringValue
        self.name = json["n9Mrj"].exists() ? json["n9Mrj"].stringValue : json["name"].stringValue
        self.parentId = json["eJxZvploI5uo_JzFlPY_"].exists() ? json["eJxZvploI5uo_JzFlPY_"].stringValue : json["parentId"].stringValue
    }
    
    // 持久化时使用清晰的 Key
    func toDictionary() -> [String: String] {
        return [
            "id": id,
            "name": name,
            "parentId": parentId
        ]
    }
}
