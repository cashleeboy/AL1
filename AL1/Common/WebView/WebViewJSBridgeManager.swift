//
//  WebViewJSBridgeManager.swift
//  AL1
//
//  Created by cashlee on 2026/1/5.
//

import WebKit

class WebViewJSBridgeManager: NSObject, WKScriptMessageHandler {
    
    weak var viewController: UIViewController?
    
    // 支持注册的交互方法名数组
    static let allHandlers: [String] = [
        WebJSAction.closePage.rawValue,
        WebJSAction.share.rawValue,
        WebJSAction.jumpToLoan.rawValue
    ]

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let bridgeMsg = JSBridgeMessage(message: message) else { return }
        handleAction(bridgeMsg)
    }

    private func handleAction(_ message: JSBridgeMessage) {
        print("*** 收到 JS 交互: \(message.name), 参数: \(message.body)")
        
        switch message.name {
        case .closePage:
            viewController?.navigationController?.popViewController(animated: true)
            
        case .share:
            let content = message.body["content"] as? String
            let url = message.body["url"] as? String
            // 调用分享逻辑
            print("执行分享: \(content ?? "")")
            
        case .jumpToLoan:
            let productId = message.body["productId"] as? String
            // 执行内部跳转逻辑
            AppRootSwitcher.switchToMain()
        }
    }
}
