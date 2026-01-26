//
//  OrderHistoryResponse.swift
//  AL1
//
//  Created by cashlee on 2025/12/31.
//

import UIKit
import SwiftyJSON

struct OrderHistoryResponse: DecodableData {
    let orderList: [OrderListItem]
    let loanLimitTo: String?

    init(json: JSON) {
        // 映射列表数据: ycXVWRngyL6yKJ -> orderList
        self.orderList = json["ycXVWRngyL6yKJ"].arrayValue.map { OrderListItem(json: $0) }
        self.loanLimitTo = json["sLCTYsDDJLa3"].string
    }
}

struct OrderListItem {
    let appOrderId: String     // 订单id
    let loanAmount: String
    let repayAmount: String?
    let remainingDays: Int?
    let productName: String?
    let productLogo: String?
    let repaidAmount :String?       //ujZR5zdZy1SZefSzXgf
    let repayDate :String?
    let repayDateStr :String?
    let applyDate: String?
    let installments: [InstallmentItem] // 对应 eEhc3g5ke
    // orderStatus 订单状态 20:审核中 22:审核拒绝 3:放款中 4:还款中 5:放款失败未关闭 6:还款完成 结清订单 7-异常关闭
    let status: OrderStatus
    // orderStatusStr 订单状态描述 20:审核中 22:审核拒绝 3:放款中 4:还款中 5:放款失败未关闭 6:还款完成 结清订单 7-异常关闭

    private let rawStatusStr: String
    /// 处理后的状态描述文字
    var statusDisplayStr: String {
        return status.formatStatusStr(rawStatusStr)
    }
    
    init(json: JSON) {
        self.appOrderId = json["poW1L_VZhHh"].stringValue
        self.loanAmount = json["fS2chxKewoa7dtFQSV"].stringValue
        self.repayAmount = json["qmxrJ0hkFPoe62zPS"].string
        self.remainingDays = json["xzR0DojhJyPAdgmp"].int
        self.productName = json["eODIjjJ"].string
        self.productLogo = json["eHxx_I"].string
        self.repaidAmount = json["ujZR5zdZy1SZefSzXgf"].string
        self.repayDate = json["jknobDslqwT"].string
        self.repayDateStr = json["enpJvKYQzP09n"].string
        self.applyDate = json["kL_mQzDHgbfChU"].stringValue
        
        // 映射分期详情
        self.installments = json["eEhc3g5ke"].arrayValue.map { InstallmentItem(json: $0) }
        
        let rawStatus = json["uR3vYcXFj80p"].intValue
        self.status = OrderStatus(rawValue: rawStatus) ?? .unknown
        self.rawStatusStr = json["dNLabJrGIKd"].stringValue
    }
}

struct InstallmentItem {
    let id: String?
    let principal: String?      // 本金
    let interest: String?       // 利息
    let status: Int?            // 状态 0：无效，1：还款中，2：已还完 3：展期 4：豁免，5：坏账
    let repaymentDate: String?  // 还款日期
    let installmentNum: Int?    // 期数
    let serviceFee: String?     // 服务费

    init(json: JSON) {
        self.id = json["wGlVByadhXXG4SRrlX"].string
        self.principal = json["hLLA1leONtnagmEKZ"].string
        self.interest = json["aTGXpg0"].string
        self.status = json["w4HPqvzjBfi6jareGDBM"].int
        self.repaymentDate = json["csNu5Yu3TQn6Th"].string
        self.installmentNum = json["gqiWcyT"].int
        self.serviceFee = json["iMuLp_O74wA2"].string
    }
}
