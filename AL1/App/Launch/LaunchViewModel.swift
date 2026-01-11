//
//  LaunchViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import Combine
import Foundation

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
    
    init() {
        performNetworkCheck()
    }
    
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
    
    
    /// 异步获取 IDFA 授权
    /// 该逻辑独立运行，结果仅用于后续业务（如埋点或风控），不阻塞页面跳转
    func fetchIdfa() {
        // 苹果建议：在应用处于 Active 状态时请求
        // 如果在 ViewDidLoad 立即调用，建议稍微延迟以确保弹窗能正常弹出
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AppIDFAProvider.shared.requestAuthorization { isAuthorized in
                let idfa = AppIDFAProvider.shared.getIDFA()
                print("*** IDFA 授权结果: \(isAuthorized), IDFA 值: \(idfa) ***")
                
                // 这里可以将获取到的 IDFA 存储到 UserDefault 或全局配置中
                // 例如：AppConfig.shared.idfa = idfa
            }
        }
    }
}

extension LaunchViewModel
{
    private func performNetworkCheck() {
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
