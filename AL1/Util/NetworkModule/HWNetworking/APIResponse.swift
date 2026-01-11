//
//  APIResponse.swift
//  AL1
//
//  Created by Ethan.li on 2024/12/5.
//

import SwiftyJSON

// 基础响应结构体
struct BaseResponse<T: DecodableData>: APIResponse {
    let status: ResponseStatus
    let message: String
    let result: T
    
    init(json: JSON) {
        status = ResponseStatus.from(jsonValue: json["code"])
        message = json["msg"].stringValue
        result = T(json: json["data"])
    }
}

// MARK: - 协议定义

// 通用 API 响应协议
protocol APIResponse {
    associatedtype DataType: DecodableData
    var status: ResponseStatus { get }
    var message: String { get }
    var result: DataType { get }
    init(json: JSON)
}

// 业务数据转换协议
protocol DecodableData {
    init(json: JSON)
}

// MARK: - 包装器与通用结构

// 基础信息模型 (原 NothingData)
struct PlainData: DecodableData {
    let status: ResponseStatus
    let message: String
    
    init(json: JSON) {
        // 将字段名改为更有意义的：状态码与信息
        status = ResponseStatus.from(jsonValue: json["code"])
        message = json["msg"].stringValue
    }
}

// 数组包装器 (用于处理 [T])
struct ListContainer<T: DecodableData>: DecodableData {
    let list: [T]
    
    init(json: JSON) {
        self.list = json.arrayValue.map { T(json: $0) }
    }
}

// 对象包装器 (用于处理 T)
struct ObjectContainer<T: DecodableData>: DecodableData {
    let content: T
    
    init(json: JSON) {
        self.content = T(json: json)
    }
}

extension ObjectContainer {
    var unwrapped: T {
        return content
    }
}
