//
//  LoginViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import Foundation
import Combine
import SwiftEntryKit
import UIKit

class LoginViewModel {
    var auth: String? = nil
    var phone: String? = nil
    var areaCode: String = "51"
    
    var cancellables = Set<AnyCancellable>()
    // ⭐️ 使用 @Published，外部可以直接订阅
    @Published var authCodeModel: LoginAuthModel? = nil
    @Published var authCodeFailure: RequestError? = nil
    @Published var userLoginInModel: LoginSession? = nil
    @Published var isLoggedIn: Bool = false
    @Published var serviceInquiryItems: [ServiceInquiryItem] = []
    
    lazy var loginRepos = LoginRepository()
    
    func privacyAttributedStrings() -> [NSMutableAttributedString] {
        var attributed: [NSMutableAttributedString] = []
        let thereText = "Hi. there\nIn order to assess your eligibility and facilitate faster loan disbursement, the following permissions are required："
        let thereContent = NSMutableAttributedString.makeStyledText(
            fullText: thereText,
            boldParts: ["Hi. there"], // 指定需要加粗的文字
            font: AppFontProvider.shared.getFont13Regular(),
            boldFont: AppFontProvider.shared.getFont16Bold(), 
            lineSpacing: 6.0,
            alignment: .left
        )
        attributed.append(thereContent)
        
        let storageText = "Storage\nWe need this permission to ensure that user's loan account statements are downloaded and saved safely on user's "
        let storageContent = NSMutableAttributedString.makeStyledText(
            fullText: storageText,
            boldParts: ["Storage"], // 指定需要加粗的文字
            font: AppFontProvider.shared.getFont13Regular(),
            boldFont: AppFontProvider.shared.getFont16Bold(),
            lineSpacing: 6.0,
            alignment: .left
        )
        attributed.append(storageContent)
        return attributed
    }
    
    // 在 VM 内部处理
    func bindLoginStatus(onSuccess: @escaping () -> Void) {
        $isLoggedIn
            .filter { $0 == true }
            .sink { _ in onSuccess() }
            .store(in: &cancellables)
    }
    
    func bindAuthCodeFailure(onCompletion: @escaping (String) -> Void) {
        $authCodeFailure
            .receive(on: RunLoop.main)
            .compactMap { (error: RequestError?) -> RequestError? in
                return error
            }
            .map { (error: RequestError) in
                var errorMsg = "Error desconocido"
                switch error {
                case .other(let message):
                    errorMsg = message
                case .registerFailed(_, let message):
                    errorMsg = message
                default:
                    break
                }
                return errorMsg
            }
            .sink { message in
                onCompletion(message)
            }
            .store(in: &cancellables)
    }
    
    func sendAuthCode() {
        guard let phone else { return }

        let completedPhone = "\(areaCode)|\(phone)"
        self.authCodeFailure = nil
        loginRepos.sendAuthCode(phone: completedPhone) { [weak self] (result :Result<LoginAuthModel, RequestError>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self.authCodeModel = model
                case .failure(let error):
                    self.authCodeFailure = error
                }
            }
        }
    }
    
    func loginRequest() {
        guard let auth else { return }
        guard let phone else { return }
        self.authCodeFailure = nil
        let completedPhone = "\(areaCode)|\(phone)"
        
        GIFHUD.runTask { finish in
            loginRepos.registerAndLogin(with: auth, phone: completedPhone) { [weak self] (result :Result<LoginSession, RequestError>) in
                guard let self else { return }
                switch result {
                case .success(let model):
                    // ✅ 持久化
                    UserSession.shared.session = model
                    
                    loginRepos.userInfo { profileResult in
                        finish()
                        switch profileResult {
                        case .success(let userProfile):
                            UserSession.shared.userProfile = userProfile
                            self.isLoggedIn = true
                        case .failure(let error):
                            self.authCodeFailure = error
                        }
                    }
                case .failure(let error):
                    finish()
                    self.authCodeFailure = error
                }
            }
        }
    }
    
    // 客服信息查询
    func fetchServiceInfo(completion: @escaping (Bool) -> Void) {
        guard serviceInquiryItems.isEmpty else {
            return 
        }
        loginRepos.serviceInfoInquiry { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                self.serviceInquiryItems = model.items
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}

// show dialog
extension LoginViewModel {
    func showPrivacyDialog() {
        let dialog = LongArticleDialog()
        dialog.configure(with: "Acuerdo de Privacidad",
                         articles: privacyAttributedStrings(), primaryAction: {
            SwiftEntryKit.dismiss()
        }) {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    func contactServiceClick(with complention: @escaping (([ServiceInquiryItem]) -> Void)) {
        if serviceInquiryItems.isEmpty {
            GIFHUD.runTask { done in
                fetchServiceInfo { [weak self] success in
                    guard let self else { return }
                    done()
                    if success {
                        complention(serviceInquiryItems)
                    }
                }
            }
        } else {
            complention(serviceInquiryItems)
        }
    }
    
}
