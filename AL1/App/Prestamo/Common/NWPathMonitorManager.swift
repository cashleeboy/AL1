//
//  NetworkReachabilityManager.swift
//  AL1
//
//  Created by cashlee on 2025/12/27.
//

import Network
import UIKit

class NWPathMonitorManager {
    
    static let shared = NWPathMonitorManager()
    
    private let queue = DispatchQueue(label: "com.app.NetworkManager")
    private var monitor: NWPathMonitor?
    
    // 外部可以订阅此回调，监听权限从“受限”转为“可用”
    var onStatusChanged: ((Bool, Bool) -> Void)?
    
    private init() {}

    /// 开始持续监听（适用于 App 启动阶段）
    func startMonitoring() {
        // 防止重复启动
        guard monitor == nil else { return }
        
        let newMonitor = NWPathMonitor()
        newMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let isAvailable = (path.status == .satisfied)
            let isRestricted = (path.status == .requiresConnection)
            
            print("*** 网络状态变化: status=\(path.status), isAvailable=\(isAvailable)")
            
            DispatchQueue.main.async {
                self.onStatusChanged?(isAvailable, isRestricted)
                
                // 如果你希望一旦联网就自动停止监听以省电，可以加这一行：
                // if isAvailable { self.stopMonitoring() }
            }
        }
        
        self.monitor = newMonitor
        newMonitor.start(queue: queue)
    }

    /// 停止监听
    func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}
