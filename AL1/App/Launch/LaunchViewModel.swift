//
//  LaunchViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import UIKit
import Combine
import AdSupport
import AppTrackingTransparency

enum LaunchLoadingState {
    case idle
    case loading
    case success
    case failed(error: String)
}

class LaunchViewModel {
    private lazy var baseRepository = BaseRepository()
    
    // 使用枚举管理状态，比单一的 Bool 更灵活
    @Published private(set) var loadingState: LaunchLoadingState = .idle
    var cancellables = Set<AnyCancellable>()
    
    // IDFA 授权是否完成（可选，如果你需要等待 IDFA 拿到后再进行某些统计）
    @Published private(set) var isIdfaTaskDone: Bool = false
    @Published var isNetworkAvailable: Bool = false
    
    // 获取项目初始配置
    func obtainInitial() {
        loadingState = .loading
        baseRepository.obtainInitial { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadingState = .success
                case .failure(let error):
                    self?.loadingState = .failed(error: error.message)
                }
            }
        }
    }
    
    func fetchIdfa() {
//        guard #available(iOS 14, *) else {
//            print("IDFA: iOS 14 以下系统，自动跳过授权")
//            AppIDFAProvider.shared.requestAuthorization { [weak self] isAuthorized in
//                self?.isIdfaTaskDone = true
//            }
//            return
//        }
//        
//        // 2. 检查状态，只有 .notDetermined 才请求
//        let status = ATTrackingManager.trackingAuthorizationStatus
//        guard status == .notDetermined else {
//            self.isIdfaTaskDone = true
//            return
//        }
//        
        // 3. 明确指定 status 类型以修复编译报错
        AppIDFAProvider.shared.requestAuthorization { [weak self] isAuthorized in
            self?.isIdfaTaskDone = true
        }
    }

    func performNetworkCheck() {
        NWPathMonitorManager.shared.onStatusChanged = { [weak self] isAvailable, isRestricted in
            guard let self = self else { return }
            if isAvailable {
                self.isNetworkAvailable = isAvailable
                // 如果后续不需要再监听，可以关掉
                 NWPathMonitorManager.shared.stopMonitoring()
            }
        }
        // 启动监听
        NWPathMonitorManager.shared.startMonitoring()
    }
    
}
