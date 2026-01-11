//
//  JSBridgeMessage.swift
//  AL1
//
//  Created by cashlee on 2026/1/5.
//

import UIKit
import WebKit

/// JS 交互动作枚举
enum WebJSAction: String {
    case closePage = "onPageFinished" // 关闭页面
    case share = "onShare"             // 分享
    case jumpToLoan = "jumpToLoan"     // 跳转到借款列表
}

/// JS 传参容器
struct JSBridgeMessage {
    let name: WebJSAction
    let body: [String: Any]
    
    init?(message: WKScriptMessage) {
        guard let action = WebJSAction(rawValue: message.name) else { return nil }
        self.name = action
        self.body = message.body as? [String: Any] ?? [:]
    }
}
