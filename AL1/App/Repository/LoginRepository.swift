//
//  LoginRepository.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation

class LoginRepository {
    
    /* 发送验证码
     秘鲁是9位数 51|{9位数手机号} 51|912344567
     type :mrpZzFdnAkFAAX7ZrZF : mgkeUyzUHHGmht: 验证码使用类型 phone 表示手机短信，phoneSounds 表示手机语音,示例值(type)
     */
    func sendAuthCode(with type: String = "phone", phone: String, completion: @escaping (Result<LoginAuthModel, RequestError>) -> Void) {
        let params: [String: String] = [
            "mgkeUyzUHHGmht": type,
            "ydt7eKNNixbOCNP": phone,
        ]
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Login.sendAuth, parameters: params) { (result: Result<LoginAuthModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
    // 注册和登录
    func registerAndLogin(with authCode: String, phone: String, completion: @escaping (Result<LoginSession, RequestError>) -> Void) {
        let params: [String: String] = [
            "yiGmwgaHbB1vDMbD": authCode,
            "ydt7eKNNixbOCNP": phone
        ]
        NW.requestPOST(API.Login.login, parameters: params) { (result: Result<LoginSession, RequestError>) in
            completion(result)
        }
    }
    
    // 退出登录
    func logout(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Login.logout) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    // 注销用户账号
    func cancelUserAccount(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Login.cancelUserAccount) { (result: Result<PlainData, RequestError>) in
                finish()
                if case .success(let data) = result {
                    print("*** data = \(data)")
                }
                completion(result)
            }
        }
    }

    // 获取用户信息
    func userInfo(completion: @escaping (Result<UserProfileModel, RequestError>) -> Void) {
        NW.requestGET(API.Login.userInfo) { (result: Result<UserProfileModel, RequestError>) in
            completion(result)
        }
    }
    
    // 客服信息查询
    func serviceInfoInquiry(completion: @escaping (Result<ServiceInquiryModel, RequestError>) -> Void) {
        NW.requestGET(API.Login.serviceInfoInquiry) { (result: Result<ServiceInquiryModel, RequestError>) in
            if case .success(let data) = result {
                print("*** data = \(data)")
            }
            completion(result)
        }
    }
}
