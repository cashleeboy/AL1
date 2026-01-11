//
//  LoginAuthModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import SwiftyJSON
import Foundation

/*
 "yfKu6ZIHqmkqUQ1nBJ": false,
 "yHMDEtusyy": "expireTime",
 "y1v6Fjs91dqUvRx": "msg",
 "aifb2zLFGr_je57": false
 */
struct LoginAuthModel: DecodableData {
    let auditAccount: Bool
    let expireTime: String
    let message: String
    let sendResult: Bool
    
    init(json: JSON) {
        self.auditAccount = json["yfKu6ZIHqmkqUQ1nBJ"].boolValue
        self.expireTime = json["yHMDEtusyy"].stringValue
        self.message = json["y1v6Fjs91dqUvRx"].stringValue
        self.sendResult = json["aifb2zLFGr_je57"].boolValue
        
    }
}

struct LoginSession: DecodableData, Codable {
    // 是否审核账号 0：不是 1：是
    let isAuditAccount: Bool
    // 是否注册 0：不是 1：是
    let isFirstRegister: Bool
    let tokenId: String
    
    init(json: JSON) {
        self.isAuditAccount = json["jZvoVw0"].boolValue
        self.isFirstRegister = json["pAc0KGEwRuIczsExn"].boolValue
        self.tokenId = json["fq5F4id0"].stringValue
    }
    
    // MARK: - Mock 逻辑
    
    /// 提供一个静态 mock 对象，方便直接使用：UserSession.shared.session = .mock
    static var mock: LoginSession {
        let mockDict: [String: Any] = [
            "jZvoVw0": true,                         // 审核状态
            "pAc0KGEwRuIczsExn": false,               // 是否首次注册
            "fq5F4id0": "eyJhbGciOiJIUzUxMiJ9.eyJhcHBfbG9naW5fdXNlcl90b2tlbl9rZXkiOiJYWkRZVDo1MTkxMTExMTExMToxMjI1YzVlMS0yNTY1LTQ4ZmYtYmFiZi00MGY5YWIwOGZiN2IifQ.pY-lxwWDbDRpGaGN0sUi6B8AJcQfZxkA-jBkMsrtMsZLcScnf6vwJ6ukX5CVXbdOz6Te7cdPdG55u6RUW64r1g"    // 模拟 Token
        ]
        return LoginSession(json: JSON(mockDict))
    }
    
    /// 或者支持自定义参数的 mock 方法
    static func createMock(isAudit: Bool = false, isFirst: Bool = false) -> LoginSession {
        let mockDict: [String: Any] = [
            "jZvoVw0": isAudit,
            "pAc0KGEwRuIczsExn": isFirst,
            "fq5F4id0": "eyJhbGciOiJIUzUxMiJ9.eyJhcHBfbG9naW5fdXNlcl90b2tlbl9rZXkiOiJYWkRZVDo1MTkxMTExMTExMToxMjI1YzVlMS0yNTY1LTQ4ZmYtYmFiZi00MGY5YWIwOGZiN2IifQ.pY-lxwWDbDRpGaGN0sUi6B8AJcQfZxkA-jBkMsrtMsZLcScnf6vwJ6ukX5CVXbdOz6Te7cdPdG55u6RUW64r1g"
        ]
        return LoginSession(json: JSON(mockDict))
    }
}
