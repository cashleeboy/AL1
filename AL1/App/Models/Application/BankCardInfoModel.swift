//
//  BankCardInfoModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/24.
//

import SwiftyJSON


// 建议的数据模型
// for BankTableSheet，UserSession
struct BankModel {
    let id: String
    let name: String
    var bankCardNo: String?
    var isSelected: Bool = false
}


struct BankCardInfoModel: DecodableData {
    // 对应数据层级 aoAs1UcI
    let bankAccountCCI: String       // lVAVr1YrRdMw3DZ: 银行账户CCI码（秘鲁等地区常用）
    let bankAccountNo: String        // gpNuFV3nMla: 银行卡号/账号
    let bankAccountType: String      // sB29fpnkHEfSxCczPUu: 账户类型（如：储蓄、支票）
    let bankId: String               // hvTDGT8j9GQ8JjT: 银行内部编号
    let bankName: String             // y0_BW: 银行名称
    let isUpdate: Int
    
    /// 将字段映射为类型字典
    var valuesMap: [PersonalType: String] {
        return [
            .bankAccountType: bankAccountType,
        ]
    }
    
    init(json: JSON) {
        // 定位到 aoAs1UcI 节点
        let data = json["aoAs1UcI"]
        isUpdate = data.isEmpty ? 0 : 1
        
        self.bankAccountCCI = data["lVAVr1YrRdMw3DZ"].stringValue
        self.bankAccountNo = data["gpNuFV3nMla"].stringValue
        self.bankAccountType = data["sB29fpnkHEfSxCczPUu"].stringValue
        self.bankId = data["hvTDGT8j9GQ8JjT"].stringValue
        self.bankName = data["y0_BW"].stringValue
    }
}
