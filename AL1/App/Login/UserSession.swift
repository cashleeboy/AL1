//
//  UserSession.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import Foundation

final class UserSession {
    static let shared = UserSession()
    private init() {}

    // 使用优化后的包装器
    @Storage(key: "app.login.session", defaultValue: nil)
    var session: LoginSession?
    
    // user profile
    @Storage(key: "app.login.userprofile", defaultValue: nil)
    var userProfile: UserProfileModel?

    var serviceContacts: [ServiceInquiryItem]?
    
    // 1. 快捷获取 Token
    var token: String? {
        return session?.tokenId
    }
    
    var mobile: String? {
        return userProfile?.userName
    }

    // 2. 严谨的登录状态判断
    var isLoggedIn: Bool {
        // 只有 session 不为空且 token 有值才算登录
        guard let session = session else { return false }
        return !session.tokenId.isEmpty
    }
    
    // first fill identiy information
    var firstIdentityInfo: Bool? {
        get {
            UserDefaults.standard.object(forKey: "firstIdentityInfo") as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "firstIdentityInfo")
        }
    }
    
    // 首页审核页面，银行信息
    var bankInfoAuditing: BankModel?
    
    // 3. 退出登录逻辑
    func clear() {
        // 1. 清除 UserSession 持久化数据
        self.session = nil
        // 2. 同步清除 RequestHeaderConfig 中的 Token
        // 必须显式重置，因为 RequestHeaderConfig 独立存储了 tokenId
        RequestHeaderConfig.tokenId = ""
        // 3. 可选：清除与该会话相关的 AES 密钥
        print("⚠️ 用户已下线：UserSession 与 RequestHeaderConfig 已重置")
    }
}
