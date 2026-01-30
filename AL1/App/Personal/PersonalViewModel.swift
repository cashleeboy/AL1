//
//  PersonalViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import Combine
import Foundation

class PersonalViewModel {
    // 数据模型，改变时会自动发布通知
    @Published var userProfileModel: UserProfileModel? {
        didSet {
            UserSession.shared.userProfile = userProfileModel
        }
    }
    @Published var isLogout: Bool = false
    
    // 用于处理错误消息的发布（可选）
    let errorMsg = PassthroughSubject<String, Never>()
    
    private lazy var loginRepos = LoginRepository()
    private lazy var baseRepository = BaseRepository()
    lazy var cancellables = Set<AnyCancellable>()

    @Published var feedbackContent: String = ""
    // 是否可以提交 (例如：字数必须大于 10 个字)
    @Published var isSubmitEnabled: Bool = false
    
    var selectedFeedbackType: Int = 2 // 默认 2-意见反馈
    
    init() {
        // 示例：监听 feedbackContent 的变化并自动更新提交按钮状态
        $feedbackContent
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1 }
            .assign(to: \.isSubmitEnabled, on: self)
            .store(in: &cancellables)
    }
    
    func clearCache(with completion: (() -> Void)? = nil) {
        accountCancel {
            completion?()
        }
    }
    
    func userInfo(userCache: Bool = true) {
        loginRepos.userInfo { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self.userProfileModel = model
                }
            case .failure(let error):
                // 发送错误通知
                self.errorMsg.send(error.localizedDescription)
            }
        }
        guard let userProfile = UserSession.shared.userProfile else {
            return
        }
        self.userProfileModel = userProfile
    }
    
    func logout(with completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) { [self] in
            loginRepos.logout { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(_):
                    UserSession.shared.clear()
                    if let completion {
                        completion()
                    } else {
                        self.isLogout = true
                    }
                case .failure(let error):
                    self.errorMsg.send(error.message)
                }
            }
        }
    }
    
    func accountCancel(with completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) { [self] in
            loginRepos.cancelUserAccount { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(_):
                    UserSession.shared.clear()
                    completion?()
                case .failure(let error):
                    self.errorMsg.send(error.message)
                }
            }
        }
    }
    
    func feedbackInfo(onSuccess: @escaping(() -> Void), onFail: @escaping ((String) -> Void)) {
        let params: [String: Any] = [
            "fVGlPR6n": selectedFeedbackType,   // 反馈类型
            "jYNQzldFHW1v": feedbackContent     // 意见内容
        ]
        baseRepository.feedbackInfo(with: params) { result in
            switch result {
            case .success(_):
                onSuccess()
                break
            case .failure(let error):
                onFail(error.message)
            }
        }
    }
}
