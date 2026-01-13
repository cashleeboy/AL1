//
//  AppNotificationManager.swift
//  AL1
//
//  Created by cashlee on 2026/1/13.
//

import Foundation

class AppNotificationManager {
    static let shared = AppNotificationManager()
    private var isHandlingKickout = false // 增加状态锁
    
    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleGlobalKickedOut), name: .sessionKickedOut, object: nil)
    }
    
    @objc private func handleGlobalKickedOut() {
        // 1. 状态锁：如果正在处理中，则直接拦截，防止重复弹窗
        guard !isHandlingKickout else { return }
        isHandlingKickout = true
        
        print("*** 全局处理踢下线 ***")
        UserSession.shared.clear()
        
        // 执行弹窗逻辑（建议使用当前最顶层的 ViewController 弹窗）
        // 这里可以直接调用 Switcher 切换到登录，或者弹出 Dialog
        AppRootSwitcher.switchToLogin()
        
        // 3秒后解锁，或者根据业务在登录成功后重置
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isHandlingKickout = false
        }
    }
}
