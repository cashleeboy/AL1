//
//  NetworkWrapper.swift
//  AL1
//
//  Created by Ethan.li on 2024/12/11.
//

import Alamofire
import Foundation
import SwiftyJSON

let NW = NetworkWrapper.shared

class NetworkWrapper {
    public static let shared = NetworkWrapper()
    private var isHandlingAuthError = false
    
    // MARK: - 白名单配置
    private var authReminderWhitelist: Set<String> {
        return [
            APIConfig.Path.Auth.login,
            APIConfig.Path.Auth.sendAuthCode,
            APIConfig.Path.Apply.getAuthStatus,
//            APIConfig.Path.Project.initialConfig,
            // 只有这些核心路径在 401 时才触发登录提醒
            // 其他后台静默请求（如埋点、配置拉取）即使 401 也不打扰用户
        ]
    }
}

// MARK: GET
extension NetworkWrapper
{
    @discardableResult
    func GET(with api: APIItem,
             parameters: [String: Any]? = nil,
             headers: [String: String]? = nil,
             encryption: Bool = true,
             completion: @escaping (Result<JSON, RequestError>) -> Void) -> HWNetworkRequest {
        
        return HN.GET(url: api.url, parameters: parameters, headers: headers)
            .success { response in
                self.handleRawResponse(response, for: api.url, encryption: encryption, completion: completion)
            }
            .failed { _ in
                completion(.failure(.notFound))
            }
    }
    
    /// 泛型 GET
    func requestGET<T: DecodableData>(_ api: APIItem, encryption: Bool = true, completion: @escaping (Result<T, RequestError>) -> Void) {
        self.GET(with: api, headers: api.fixedParameters, encryption: encryption) { result in
            self.parseGenericResult(result, completion: completion)
        }
    }
}

// MARK: - POST
extension NetworkWrapper {
    @discardableResult
    func POST(with api: APIItem,
              parameters: [String: Any]? = nil,
              headers: [String: String]? = nil,
              encryption: Bool = true,
              completion: @escaping (Result<JSON, RequestError>) -> Void) -> HWNetworkRequest {
        
        guard let url = URL(string: api.url) else { return HWNetworkRequest() }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        // 处理参数：加密或转 Raw JSON
        if let params = parameters {
            let jsonString = JSON(params).rawString() ?? ""
            print("*** request json string = \(jsonString)")
            if encryption {
                let key = RequestHeaderConfig.aesKey
                if let encrypted = EncryptionProvider.encrypt(plainText: jsonString, key: key) {
                    urlRequest.httpBody = encrypted.data(using: .utf8)
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // Raw 通常用 text/plain
                }
            } else {
                urlRequest.httpBody = jsonString.data(using: .utf8)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        let hwRequest = HWNetworkRequest()
        hwRequest.request = AF.request(urlRequest).responseJSON { response in
            hwRequest.handleResponse(response: response)
        }
        
        return hwRequest.success { response in
            self.handleRawResponse(response, for: api.url, encryption: encryption, completion: completion)
        }.failed { _ in
            completion(.failure(.notFound))
        }
    }

    /// 泛型 POST
    func requestPOST<T: DecodableData>(_ api: APIItem, parameters: [String: Any]? = nil, encryption: Bool = true, completion: @escaping (Result<T, RequestError>) -> Void) {
        self.POST(with: api, parameters: parameters, headers: api.fixedParameters, encryption: encryption) { result in
            self.parseGenericResult(result, completion: completion)
        }
    }
}

// MARK: UPLOAD
extension NetworkWrapper {

    @discardableResult
    func UPLOAD<T: DecodableData>(
        with api: APIItem,
        parameters: [String: Any]? = nil,
        datas: [HWMultipartData]? = nil,
        encryption: Bool = true,
        progressHandler: ((Double) -> Void)?,
        completion: @escaping (Result<T, RequestError>) -> Void
    ) -> HWNetworkRequest {
        guard let url = URL(string: api.url) else {
            completion(.failure(.notFound))
            return HWNetworkRequest()
        }
        var headers = HTTPHeaders()
        api.fixedParameters.forEach { headers.add(name: $0, value: $1) }
        
        let hwRequest = HWNetworkRequest()
        hwRequest.request = AF.upload(multipartFormData: { multipartForm in
            parameters?.forEach { (key, value) in
                if let valueData = "\(value)".data(using: .utf8) {
                    multipartForm.append(valueData, withName: key)
                }
            }
            
            datas?.forEach { dataItem in
                multipartForm.append(
                    dataItem.data,
                    withName: dataItem.name,
                    fileName: dataItem.fileName,
                    mimeType: dataItem.mimeType
                )
            }
        }, to: url, method: .post, headers: headers)
        .uploadProgress { progress in
            progressHandler?(progress.fractionCompleted)
        }
        .responseJSON { response in
            hwRequest.handleResponse(response: response)
        }

        // 3. 复用 POST 的 handleRawResponse 逻辑进行统一解密和解析
        return hwRequest.success { response in
            self.handleRawResponse(response, for: api.url, encryption: encryption) { (result: Result<JSON, RequestError>) in
                // 统一泛型解析
                self.parseGenericResult(result, completion: completion)
            }
        }.failed { error in
            completion(.failure(.other(message: error.localizedDescription)))
        }
    }
}

// MARK: - Private Helper
extension NetworkWrapper
{
    private func handleRawResponse(
        _ response: Any,
        for url: String,
        encryption: Bool,
        completion: @escaping (Result<JSON, RequestError>) -> Void
    ) {
        var finalJson: JSON
        
        // 1. 解密处理
        if let dict = response as? [String: Any] {
//            print("*** response = \(response)")
            finalJson = JSON(dict)
        } else if encryption, let cipherString = response as? String {
            let key = RequestHeaderConfig.aesKey
            guard let decrypted = EncryptionProvider.decrypt(cipherText: cipherString, key: key) else {
                completion(.failure(.decryptionFailed)); return
            }
            print("*** decrypted = \(decrypted)")
            finalJson = JSON(parseJSON: decrypted)
        } else {
            finalJson = JSON(response)
        }
        
        // 2. 业务状态码校验 (使用你之前的 BaseResponse)
        let resp = BaseResponse<PlainData>(json: finalJson)
        if resp.status == .success {
            completion(.success(finalJson))
        } else {
            if resp.status == .expired {
                // 401 需要白名单校验，防止在后台静默请求时弹出登录框
                handleUnauthorizedAccess(for: url)
            } else if resp.status == .kickOut {
                // 402 异地登录：通常不走白名单，必须强制处理
                handleKickedOut(for: url)
            }
            
            print("*** fail with code = \(resp.status.rawValue), message = \(resp.message)")
            completion(.failure(.registerFailed(code: resp.status.rawValue, message: resp.message)))
        }
    }
    /// 修改后的处理方法，增加 urlPath 参数
    private func handleUnauthorizedAccess(for urlPath: String?) {
        guard let path = urlPath else { return }
        guard authReminderWhitelist.contains(where: { path.contains($0) }) else {
            return
        }
        guard !isHandlingAuthError else { return }
        isHandlingAuthError = true
        
        NotificationCenter.default.post(name: .unauthorizedAccess, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isHandlingAuthError = false
        }
    }
    
    /// 处理 402 异地登录
    private func handleKickedOut(for urlPath: String?) {
        guard !isHandlingAuthError else { return }
        isHandlingAuthError = true

        NotificationCenter.default.post(name: .sessionKickedOut, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isHandlingAuthError = false
        }
    }
}

extension NetworkWrapper {
    private func parseGenericResult<T: DecodableData>(
        _ result: Result<JSON, RequestError>,
        completion: @escaping (Result<T, RequestError>) -> Void
    ) {
        switch result {
        case .success(let json):
            let response = BaseResponse<T>(json: json)
            
            completion(.success(response.result))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

extension Notification.Name {
    static let unauthorizedAccess = Notification.Name("AppSessionExpiredNotification")
    static let sessionKickedOut = Notification.Name("AppSessionKickedOutNotification")
    static let jumpToTabbarController = Notification.Name("AppJumpToTabbarController")
}
