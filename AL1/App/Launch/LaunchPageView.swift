//
//  LaunchPageView.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import UIKit
import Combine

class LaunchPageView: UIViewController {
    
    private lazy var launchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreen_BG")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // 如果有 Logo 可以在此添加
    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "app_logo"))
        return iv
    }()
    
    private let viewModel = LaunchViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        viewModel.performNetworkCheck()
    }
    
//    @objc private func handleAppDidBecomeActive() {
//        // 延迟一秒给系统留出渲染时间，提高弹窗成功率
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            self?.viewModel.fetchIdfa()
//        }
//
//        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
}

extension LaunchPageView {
    
    private func setupUI() {
        view.addSubview(launchImageView)

        launchImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        // 1. 核心跳转逻辑：使用 CombineLatest 组合两个状态
//        Publishers.CombineLatest(viewModel.$isIdfaTaskDone, viewModel.$loadingState)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] (isIdfaDone, loadingState) in
//                guard let self = self else { return }
//                
//                // 只有两个条件同时满足才执行跳转
//                if isIdfaDone, case .success = loadingState {
//                    // 延迟一小段时间进入，避免闪现，体验更好
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        AppRootSwitcher.switchToMain()
//                    }
//                }
//                
//                // 错误处理逻辑（单独处理 loadingState 的失败情况）
//                if case .failed(let message) = loadingState {
//                    self.showErrorRetry(message: message)
//                }
//            }
//            .store(in: &cancellables)
        
        viewModel.$loadingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .success:
                    // 延迟一小段时间进入，避免闪现，体验更好
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AppRootSwitcher.switchToMain()
                    }
                case .failed(let message):
                    self.showErrorRetry(message: message)
                case .loading, .idle:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isNetworkAvailable
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                guard let self else { return }
                if isAvailable {
                    viewModel.obtainInitial()
                }
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func showErrorRetry(message: String) {
        // 展示错误弹窗或重试按钮
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.obtainInitial()
        })
        self.present(alert, animated: true)
    }
}
