//
//  AppInitialConfig.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation
import SwiftyJSON

struct AppInitialConfig: DecodableData {
    let channel: String            // kjFgfNwxCJxI2qU (渠道)
    let aesKey: String             // pk9drvJmDwU (加密密钥)
    let filterAppTypes: String     // iCcZSelWxdjgwOQpX (应用过滤类型)
    let filterDuration: String     // qSFu0fgnan (过滤时长)
    let smsFilterKeys: String      // wwen7BHkOxeE8 (短信过滤关键词)
    let extraConfigs: [InitialExtraItem] // w7juYcbSkOwWDt2WaA (额外配置项)

    init(json: JSON) {
        channel = json["acqChannel"].stringValue
        aesKey = json["aesKey"].stringValue
        filterAppTypes = json["filterAppTypes"].stringValue
        filterDuration = json["filterDuration"].stringValue
        smsFilterKeys = json["smsFilterKeys"].stringValue
        extraConfigs = json["sysConfigInfo"].arrayValue.map { InitialExtraItem(json: $0) }
    }
}

struct InitialExtraItem: DecodableData {
    let description: String // cqpa9Mczh2v6Qq3xvs28
    let key: String         // rl6ruFOPiZ_gUHRzC4

    init(json: JSON) {
        description = json["desc"].stringValue
        key = json["key"].stringValue
    }
}


struct AppSysConfigModel: DecodableData {

    let configValue: String     //"iU49mS1Y2": "configValue"
    init(json: JSON) {
        configValue = json["configValue"].stringValue
    }
}
