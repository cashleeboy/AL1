//
//  BaseRepository.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation
import SwiftyJSON

struct BaseRepository
{
    // 获取项目初始配置
    func obtainInitial(completion: @escaping (Result<Bool, RequestError>) -> Void) {
        // TODO: mock toekn
//        RequestHeaderConfig.tokenId = "eyJhbGciOiJIUzUxMiJ9.eyJhcHBfbG9naW5fdXNlcl90b2tlbl9rZXkiOiJYWkRZVDo1MTkxMTExMTExMToxMjI1YzVlMS0yNTY1LTQ4ZmYtYmFiZi00MGY5YWIwOGZiN2IifQ.pY-lxwWDbDRpGaGN0sUi6B8AJcQfZxkA-jBkMsrtMsZLcScnf6vwJ6ukX5CVXbdOz6Te7cdPdG55u6RUW64r1g"
        let channel = RequestHeaderConfig.channel
        let aesKey = RequestHeaderConfig.aesKey
        
        if !channel.isEmpty && !aesKey.isEmpty {
            print("*** 缓存: channel = \(channel), aesKey = \(aesKey) ---")
            completion(.success(true))
            return
        }

        // 2. 发起请求
        NW.requestGET(API.ProjectConfig.projectConfig, encryption: false) { (result: Result<AppInitialConfig, RequestError>) in
            switch result {
            case .success(let config):
                print("*** 请求成功: channel = \(config.channel), aesKey = \(config.aesKey)")
                
                RequestHeaderConfig.channel = config.channel
                RequestHeaderConfig.aesKey = config.aesKey
                completion(.success(true))
            case .failure(let error):
                print("*** 配置请求失败: \(error.message)")
                completion(.failure(error))
            }
        }
    }
    
    
    // 通用配置查询、获取风控数据过滤规则
    func sysConfig(completion: @escaping (Result<AppSysConfigModel, RequestError>) -> Void) {
        NW.requestGET(API.ProjectConfig.sysConfig) { (result: Result<AppSysConfigModel, RequestError>) in
            completion(result)
        }
    }
    
    // 提交客户上传数据
    func submitCustomerUploaded(with datas: [String: Any], completion: @escaping (Result<AppSysConfigModel, RequestError>) -> Void) {
        NW.requestPOST(API.ProjectConfig.submitCustomerData, parameters: datas) { (result: Result<AppSysConfigModel, RequestError>) in
            completion(result)
        }
    }

    // feedbackInfo
    func feedbackInfo(with data: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.ProjectConfig.feedbackInfo, parameters: data) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
    // 检测数据是否有效
    func fetchDataIsValid(completion: @escaping (Result<UserDataValidModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestGET(API.Apply.dataIsValid) { (result: Result<UserDataValidModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
}
