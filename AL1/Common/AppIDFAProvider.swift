//
//  AppIDFAProvider.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import AdSupport
import AppTrackingTransparency

class AppIDFAProvider {
    
    static let shared = AppIDFAProvider()
    private init() {}
    
    /// 标准的 IDFA 全零占位符
    private let zeroIdentifier = "00000000-0000-0000-0000-000000000000"
    
    /// 获取 IDFA 字符串
    /// - Returns: 授权则返回真实 IDFA，否则返回全零字符串 "00000000-..."
    func getIDFA() -> String {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            // 只有在 .authorized 状态下才能获取真实的 IDFA
            if status == .authorized {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }
        } else {
            // iOS 13 及以下：检查系统级的“限制广告追踪”开关
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }
        }
        
        // 未获授权或系统受限时，返回全零字符串
        return zeroIdentifier
    }
    
    /// 请求追踪授权
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 14, *) {
            // 优化：如果用户还没选过，才弹出申请
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                // 确保在主线程或者应用处于 Active 状态调用
                // 注意：由于此方法是异步的，系统会自动处理弹窗时机
                ATTrackingManager.requestTrackingAuthorization { status in
//                    DispatchQueue.main.async {
                        completion?(status == .authorized)
//                    }
                }
            } else {
                // 如果已经授权或拒绝过，直接返回当前结果
                completion?(ATTrackingManager.trackingAuthorizationStatus == .authorized)
            }
        } else {
            completion?(true)
        }
    }
}
