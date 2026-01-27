//
//  LoanApplyModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//

import SwiftyJSON
import Foundation

struct LoanApplyModel: DecodableData {
    // 基础状态标识
    var autoConfirmFlag: String = ""
    var bankId: String = ""
    var submitType: String = ""
    
    // 核心产品列表
    var productList: [LoanProductItem] = []
    
    // 其他配置标识 (示例)
    var someStatus: Bool = false

    init(json: JSON) {
        let data = json//["data"]
        
        // 1. 解析外层状态
        self.someStatus = data["kkW9kv_HN_s_"].boolValue
        
        // 2. 进入嵌套结构 npjSvEKLdonFMH -> st_XPU6fSrDrIyGS6K0
        let configPath = data["npjSvEKLdonFMH"]["st_XPU6fSrDrIyGS6K0"]
        
        self.autoConfirmFlag = configPath["fCu3hqmq"].stringValue
        self.bankId = configPath["hvTDGT8j9GQ8JjT"].stringValue
        self.submitType = configPath["jGKye_1IV"].stringValue
        
        // 3. 解析数组 wSHJYIU1HgMwuLvO
        if let array = configPath["wSHJYIU1HgMwuLvO"].array {
            self.productList = array.map { LoanProductItem(json: $0) }
        }
    }
}

// 产品详情模型
struct LoanProductItem {
    var appOrderId: String = ""
    var loanAmount: String = ""
    var productName: String = ""
    var productLogo: String = ""
    var productCode: String = ""
    var repaymentDate: String = ""
    
    var isSelected: Bool = true
    
    // 利率范围详情
    var rates: LoanRateDetail

    init(json: JSON) {
        self.appOrderId = json["poW1L_VZhHh"].stringValue
        self.loanAmount = json["fS2chxKewoa7dtFQSV"].stringValue
        self.productName = json["eODIjjJ"].stringValue
        self.productLogo = json["eHxx_I"].stringValue
        self.productCode = json["btdxX7JuiyUOwNdk"].stringValue
        self.repaymentDate = json["csNu5Yu3TQn6Th"].stringValue
        
        // 解析嵌套的 yb2Lvrrx 详情
        self.rates = LoanRateDetail(json: json["yb2Lvrrx"])
    }
}

// 利率及天数模型
struct LoanRateDetail {
    var dailyInterestRate: String = ""
    var dueDay: String = ""
    var maxDailyInterestRate: String = ""
    var maxLoanAmount: String = ""
    var maxLoanDay: String = ""
    var minDailyInterestRate: String = ""
    var minLoanAmount: String = ""
    var minLoanDay: String = ""

    init(json: JSON) {
        self.dailyInterestRate = json["rmQh3wb70ZMd5"].stringValue
        self.dueDay = json["xYLwxeRTMP5"].stringValue
        self.maxDailyInterestRate = json["lKRQTAXi"].stringValue
        self.maxLoanAmount = json["whyVezmQpbVGuZrOk"].stringValue
        self.maxLoanDay = json["oLZPFRSKU0TSPH07KcMK"].stringValue
        self.minDailyInterestRate = json["gmoV8HP2uXysP3Q9z"].stringValue
        self.minLoanAmount = json["mhA0JpGf"].stringValue
        self.minLoanDay = json["hZqLFHRY1nLu6"].stringValue
    }
}
