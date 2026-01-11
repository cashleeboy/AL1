//
//  AppIDFAProvider.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation
import AdSupport
import AppTrackingTransparency

class AppIDFAProvider {
    
    static let shared = AppIDFAProvider()
    private init() {}
    
    /// 获取 IDFA 字符串
    /// - Returns: 如果用户授权则返回 IDFA，否则返回全零字符串（或根据业务需求返回空）
    func getIDFA() -> String {
        // 在多线程环境下，ASIdentifierManager 是线程安全的
        // 但为了严谨，如果你有缓存逻辑，建议加锁
        if #available(iOS 14, *) {
            // iOS 14+ 需要检查授权状态
            let status = ATTrackingManager.trackingAuthorizationStatus
            if status == .authorized {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return "0"
            }
        } else {
            // iOS 13 及以下
            // 检查“限制广告追踪”开关
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return "0"
            }
        }
    }
    
    /// 请求追踪授权 (仅限 iOS 14+)
    /// 建议在 App 启动后的第一个页面或初始化配置完成后调用
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 14, *) {
            // 苹果要求：必须在应用处于 Active 状态时请求
            // 如果在启动瞬间调用，可能会因为应用未激活而失败，建议延迟或在 DidBecomeActive 中调用
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    completion?(status == .authorized)
                }
            }
        } else {
            // iOS 13 及以下不需要显式请求，直接回调成功
            completion?(true)
        }
    }
}
