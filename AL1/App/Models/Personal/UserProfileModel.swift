//
//  PersonalInfoModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

/*
 "v5RfSJfQ03HzZ": "clientType",
 "wGlVByadhXXG4SRrlX": "id",
 "fS2chxKewoa7dtFQSV": "loanAmount",
 "qgD3y7JuYWQ": "nickName",
 "ydt7eKNNixbOCNP": "phone",
 "npvFPI": "rejectDueDate",
 "xzR0DojhJyPAdgmp": "remainingDays",
 "qmxrJ0hkFPoe62zPS": "repayAmount",
 "byM51": "showBankAccountPage",
 "kgFDC6ESAckXgqWj": "showPersonInfoPage",
 "jSdjMo_": false,
 "w4HPqvzjBfi6jareGDBM": "status",
 "zPvZNdGWzE01miT6": "totalOrderNum",
 "izKJk3": "userId",
 "dWTqiw_oZZocz": "userName"
 */
import SwiftyJSON

struct UserProfileModel: DecodableData, Codable {
    let clientType: String          // v5RfSJfQ03HzZ
    let id: String                  // wGlVByadhXXG4SRrlX
    let loanAmount: String          // fS2chxKewoa7dtFQSV
    let nickName: String            // qgD3y7JuYWQ
    let phone: String               // ydt7eKNNixbOCNP
    let rejectDueDate: String       // npvFPI
    let remainingDays: String       // xzR0DojhJyPAdgmp
    let repayAmount: Int         // qmxrJ0hkFPoe62zPS
    let showBankAccountPage: String // byM51
    let showPersonInfoPage: String  // kgFDC6ESAckXgqWj
    let isSomething: Bool           // jSdjMo_ (根据原 JSON 这里的布尔值命名)
    let status: String              // w4HPqvzjBfi6jareGDBM
    let totalOrderNum: Int       // zPvZNdGWzE01miT6
    let userId: String              // izKJk3
    let userName: String            // dWTqiw_oZZocz

    init(json: JSON) {
        self.clientType = json["v5RfSJfQ03HzZ"].stringValue
        self.id = json["wGlVByadhXXG4SRrlX"].stringValue
        self.loanAmount = json["fS2chxKewoa7dtFQSV"].stringValue
        self.nickName = json["qgD3y7JuYWQ"].stringValue
        self.phone = json["ydt7eKNNixbOCNP"].stringValue
        self.rejectDueDate = json["npvFPI"].stringValue
        self.remainingDays = json["xzR0DojhJyPAdgmp"].stringValue
        self.repayAmount = json["qmxrJ0hkFPoe62zPS"].intValue
        self.showBankAccountPage = json["byM51"].stringValue
        self.showPersonInfoPage = json["kgFDC6ESAckXgqWj"].stringValue
        self.isSomething = json["jSdjMo_"].boolValue
        self.status = json["w4HPqvzjBfi6jareGDBM"].stringValue
        self.totalOrderNum = json["zPvZNdGWzE01miT6"].intValue
        self.userId = json["izKJk3"].stringValue
        self.userName = json["dWTqiw_oZZocz"].stringValue
    }
}

extension UserProfileModel {
    /// 是否需要展示银行卡页面
    var needsToSetBank: Bool {
        return showBankAccountPage == "1" || showBankAccountPage == "true"
    }
    
    /// 是否需要展示个人信息页面
    var needsToSetProfile: Bool {
        return showPersonInfoPage == "1" || showPersonInfoPage == "true"
    }
}
