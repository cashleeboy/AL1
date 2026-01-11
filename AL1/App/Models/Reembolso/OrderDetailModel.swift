//
//  OrderDetailModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/9.
//

import SwiftyJSON


//
struct OrderDetailModel: DecodableData {
    let loanOrderDetails: [LoanOrderDetailModel]
    
    init(json: JSON) {
        self.loanOrderDetails = json["kha7A5RS_pnQePes4cl"].arrayValue.map { LoanOrderDetailModel(json: $0) }
    }
}

struct LoanOrderDetailModel: DecodableData {
    // 基础信息
    let orderId: String
    let applyDate: String
    let loanAmount: String
    let receiptAmount: String     // 到账金额
    let totalRepayAmount: String  // 总还款金额
    
    // 状态相关
    let status: OrderStatus
    private let rawStatusDesc: String
    var statusDisplayStr: String {
        return status.formatStatusStr(rawStatusDesc)
    }
    
    // 费用与分期
    let term: Int                 // 期数
    let totalTerms: Int           // 总期数
    let interest: String          // 利息
    let serviceFee: String        // 服务费
    let feeDetail: OrderFeeDetail // 嵌套的费用详情
    
    // 银行信息
    let bankName: String
    let bankCardNo: String
    
    // 辅助字段
    let remainingDays: String
    let isCheck: Bool             // 是否已查阅/对账
    
    let loanDate: String?        // 放款日期

    init(json: JSON) {
        // 映射核心 ID 与日期
        self.orderId = json["poW1L_VZhHh"].stringValue
        self.applyDate = json["kL_mQzDHgbfChU"].stringValue
        
        // 金额映射
        self.loanAmount = json["fS2chxKewoa7dtFQSV"].stringValue
        self.receiptAmount = json["orkhVnsORxaaV4WEBu"].stringValue
        self.totalRepayAmount = json["yWqZ4vDeMSGVJ"].stringValue
        
        // 状态映射
        let statusCode = json["uR3vYcXFj80p"].intValue
        self.status = OrderStatus(rawValue: statusCode) ?? .unknown
        self.rawStatusDesc = json["v1oplG"].stringValue
        
        // 周期与期数
        self.term = json["rhG4oMUGgnfR"].intValue
        self.totalTerms = json["gqiWcyT"].intValue
        self.remainingDays = json["aotmYIWr"].stringValue
        
        // 费用汇总
        self.interest = json["aTGXpg0"].stringValue
        self.serviceFee = json["iMuLp_O74wA2"].stringValue
        
        // 银行信息
        self.bankName = json["y0_BW"].stringValue
        self.bankCardNo = json["s_0ioeu"].stringValue
        
        // 布尔值与嵌套对象
        self.isCheck = json["mkEfI7jNRkCs8gO"].boolValue
        self.feeDetail = OrderFeeDetail(json: json["eHp5mtR601Vd"])
        
        self.loanDate = json["adHQwKXVNyOmAAS"].string
    }
}

/// 嵌套的费用详情模型 (eHp5mtR601Vd)
struct OrderFeeDetail {
    let creditServiceFee: String // 信用服务费
    let interest: String
    let payChannelFee: String    // 支付通道费
    let serviceFee: String
    let taxation: String         // 税费

    init(json: JSON) {
        self.creditServiceFee = json["g80pYruWY"].stringValue
        self.interest = json["aTGXpg0"].stringValue
        self.payChannelFee = json["dNuTf"].stringValue
        self.serviceFee = json["iMuLp_O74wA2"].stringValue
        self.taxation = json["i7zlLwtp8i6sf1"].stringValue
    }
}
