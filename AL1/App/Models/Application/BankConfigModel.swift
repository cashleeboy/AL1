//
//  BankModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import SwiftyJSON

// 查询银行名称列表
struct BankConfigModel: DecodableData {
    let bankList: [BankItem]   // 对应 xGZAOG3o8jrSrX
    let bankType: String       // 对应 aoymw_Oc1g9nxw9PZw

    init(json: JSON) {
        // 解析银行列表数组
        self.bankList = json["xGZAOG3o8jrSrX"].arrayValue.map { BankItem(json: $0) }
        // 解析银行类型
        self.bankType = json["aoymw_Oc1g9nxw9PZw"].stringValue
    }
}

struct BankItem: DecodableData {
    let bankName: String       // 对应 y0_BW
    let cardLength: String     // 对应 sB1Qyodk9cvvFDuv8
    let id: String             // 对应 wGlVByadhXXG4SRrlX
    let isCommonUsed: Int      // 对应 r5ljZzRlghxp (通常 1 表示常用)
    let extraFields: [BankField] // 对应 cMz590Fms7eupD2hlg70
    
    init(json: JSON) {
        self.bankName = json["y0_BW"].stringValue
        self.cardLength = json["sB1Qyodk9cvvFDuv8"].stringValue
        self.id = json["wGlVByadhXXG4SRrlX"].stringValue
        self.isCommonUsed = json["r5ljZzRlghxp"].intValue
        // 解析嵌套的附加字段数组
        self.extraFields = json["cMz590Fms7eupD2hlg70"].arrayValue.map { BankField(json: $0) }
    }
}

struct BankField: DecodableData {
    let key: String            // 对应 rl6ruFOPiZ_gUHRzC4
    let value: String          // 对应 kq8KJJni

    init(json: JSON) {
        self.key = json["rl6ruFOPiZ_gUHRzC4"].stringValue
        self.value = json["kq8KJJni"].stringValue
    }
}

// user bank
struct UserBankCardInfoList: DecodableData {
    let bankCardMaxNum: Int
    let bankCardList: [UserBankCardItem]
    
    init(json: JSON) {
        self.bankCardMaxNum = json["kdX0MA"].intValue
        self.bankCardList = json["s7tBg"].arrayValue.map { UserBankCardItem(json: $0) }
    }
}

protocol SelectableItem {
    var isSelected: Bool { get set }
}

struct UserBankCardItem: DecodableData, SelectableItem {
    let bankAccountCCI: String
    let bankCardNo: String
    let bankName: String
    let bankId: String
    let bankType: String
    let bankTypeDesc: String
    let holderIdCardNumber: String
    let holderName: String
    let id: String
    
    var isSelected: Bool

    // 自动将卡号格式化为 **** **** **** 1222
    var bankNumberMasked: String {
        guard bankCardNo.count >= 4 else { return bankCardNo }
        let lastFour = bankCardNo.suffix(4)
        return "**** **** **** \(lastFour)"
    }

    init(json: JSON) {
        self.bankAccountCCI = json["lVAVr1YrRdMw3DZ"].stringValue
        
        self.bankCardNo = json["s_0ioeu"].stringValue
        self.bankName = json["y0_BW"].stringValue
        
        self.bankId = json["hvTDGT8j9GQ8JjT"].stringValue    //hvTDGT8j9GQ8JjT
        
        self.bankType = json["aoymw_Oc1g9nxw9PZw"].stringValue
        self.bankTypeDesc = json["zfOnwH7sBpYZ2JN"].stringValue
        self.holderIdCardNumber = json["tVvCNvidM0A0Bwh"].stringValue
        self.holderName = json["vq3GkAVo45NG"].stringValue
        self.id = json["wGlVByadhXXG4SRrlX"].stringValue
        self.isSelected = false
    }
    
}

extension UserBankCardItem { 
    /*
     "poW1L_VZhHh": "appOrderId",
     "hvTDGT8j9GQ8JjT": "bankId",
     */
    func toBackendDictionary() -> [String: Any] {
        return [
            BackendUserBankInfoKeys.bankAccountCCI: bankAccountCCI,
//            BackendUserBankInfoKeys.bankAccountCCI: "99999666622221111212",
            
            "fMuuZkDBUJIxAczLcIR": bankId,
            BackendUserBankInfoKeys.bankName: bankName,
            
            AddBankBackendUserKeys.bankCardNo: bankCardNo,
            AddBankBackendUserKeys.bankAccountType: bankType,
            
        ]
    }
}
