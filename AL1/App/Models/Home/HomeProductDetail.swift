//
//  HomeProductDetail.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import SwiftyJSON
import Foundation

struct HomeProductDetail: DecodableData {
    
    // MARK: - 易读的业务属性
    
    /// 期限范围 (对应 jky_anE: "91-365")
    let termRange: String
    
    /// 最高额度 (对应 tftbxkABZh: 99999)
    let maxAmount: Int
    
    /// 产品主标题 (示例猜测，对应 m14ZhfFHOTx)
    let mainTitle: String
    
    /// 产品副标题 (示例猜测，对应 vVoUM21hcHeMcm)
    let subTitle: String
    
    /// 状态标识/类型 (对应 yZkvyDY2J: 1)
    let status: Int
    
    /// 是否显示某项开关 (对应 iaM6R8ddKv: 0)
    let isFeatureEnabled: Bool
    
    /// 产品唯一标识符 (对应 ibpvK2PRWyonH)
    let productId: String
    
    /// 额外业务代码 (对应 b7RgdPX)
    let bizCode: String

    // MARK: - 初始化解析
    
    init(json: JSON) {
        // 根据你提供的数据快照进行映射
        self.termRange = json["jky_anE"].stringValue
        self.bizCode = json["b7RgdPX"].stringValue
        self.productId = json["ibpvK2PRWyonH"].stringValue
        
        // 处理 Bool 类型，通常 0/1 映射为 Bool
        self.isFeatureEnabled = json["iaM6R8ddKv"].intValue == 1
        self.status = json["yZkvyDY2J"].intValue
        
        self.mainTitle = json["m14ZhfFHOTx"].stringValue
        self.subTitle = json["vVoUM21hcHeMcm"].stringValue
        
        // 兼容处理数字，有时候金额可能是 String 形式
        let amountStr = json["tftbxkABZh"].description
        self.maxAmount = Int(amountStr) ?? 0
        
        // 其他字段根据需要继续添加...
        // DrR1mBKFeaq -> nUclJhpsO
        // ao89ZjUpqR -> ymMAhtw
        // Kk7ggseE -> KjKyYC
    }
}
