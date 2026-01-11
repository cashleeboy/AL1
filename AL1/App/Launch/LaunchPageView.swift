//
//  LaunchPageView.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import UIKit
import SnapKit
import Combine

class LaunchPageView: UIViewController {
    
    private lazy var launchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreen_BG")
        imageView.contentMode = .scaleAspectFill
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
        // 1. 获取 IDFA（独立线程/逻辑，不阻塞跳转）
        viewModel.fetchIdfa()
    }
    
    private func setupUI() {
        view.addSubview(launchImageView)

        launchImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
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
