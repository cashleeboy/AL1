//
//  APIItem.swift
//  AL1
//
//  Created by Ethan.li on 2024/12/5.
//

import Foundation

struct APIItem: HWAPIProtocol {
    let endpoint: String
    var method: HWHTTPMethod
    var additionalParams: [String: Any]?
    var includeFixedParams: Bool
    
    // --- 新增控制开关 ---
    /// 是否将固定参数拼接到 URL 后面 (默认 false，兼容你现有逻辑)
    var appendFixedParamsToUrl: Bool = false

    private enum ParameterKeys {
        static let channel    = "kjFgfNwxCJxI2qU"
        static let appVersion = "wo9u2"
        static let clientType = "v5RfSJfQ03HzZ"
        static let deviceUdid = "m71TMNCxOlsp"
        static let deviceIdfa = "nrkLiqg6urq"
        static let tokenId    = "fq5F4id0"
    }

    // MARK: - 新增：供 Header 使用的字典
    /// 获取固定参数字典，可直接用于请求 Header
    var fixedParameters: [String: String] {
        var params: [String: String] = [
            ParameterKeys.channel: RequestHeaderConfig.channel,
            ParameterKeys.appVersion: RequestHeaderConfig.appVersionInt,
            ParameterKeys.clientType: RequestHeaderConfig.clienType,
//            ParameterKeys.deviceUdid: RequestHeaderConfig.deviceUdid,
            ParameterKeys.deviceUdid: DeviceIDManager.getAdid(),
            ParameterKeys.deviceIdfa: RequestHeaderConfig.deviceIdfa
        ]
        
        if let tokenId = UserSession.shared.token {
            params[ParameterKeys.tokenId] = tokenId
        }
        return params
    }

    init(_ path: String,
         m: HWHTTPMethod = .get,
         includeFixedParams: Bool = true,
         appendFixedParamsToUrl: Bool = false, // 默认不拼接到 URL
         additionalParams: [String: Any]? = nil) {
        self.endpoint = path
        self.method = m
        self.includeFixedParams = includeFixedParams
        self.appendFixedParamsToUrl = appendFixedParamsToUrl
        self.additionalParams = additionalParams
    }

    var url: String {
        return buildUrl(isAbsolute: false)
    }

    var endpointUrl: String {
        return endpoint
    }

    var absoluteUrl: String {
        return buildUrl(isAbsolute: true)
    }

    // MARK: - 私有辅助方法
    private func buildUrl(isAbsolute: Bool) -> String {
        let base = isAbsolute ? "" : AppConfig.currentEnv.baseURL
        let fullPath = base + endpoint
        
        guard var components = URLComponents(string: fullPath) else {
            return fullPath
        }

        var queryItems: [URLQueryItem] = components.queryItems ?? []

        // --- 逻辑调整：根据两个开关决定是否拼接 URL ---
        if includeFixedParams && appendFixedParamsToUrl {
            // 遍历字典，统一添加
            fixedParameters.forEach { (key, value) in
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        if let extras = additionalParams {
            let extraItems = extras.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            queryItems.append(contentsOf: extraItems)
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        let finalString = components.url?.absoluteString ?? fullPath
        print("*** url = \(finalString)")
        return finalString
    }
}
