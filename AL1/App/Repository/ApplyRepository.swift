//
//  ApplyRepository.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import Foundation

class ApplyRepository {
    
    // 获取认证进度
    func fetchAuthStatus(completion: @escaping (Result<AuthStatusModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestGET(API.Apply.getAuthStatus) { (result: Result<AuthStatusModel, RequestError>) in
                finish()
                // 确保在主线程处理结果
                switch result {
                case .success(let data):
                    print("*** 已完成步数: \(data.filledStep), 总步数: \(data.totalStep)")
                    completion(.success(data))
                case .failure(let error):
//                        print("--- 认证进度获取失败: \(error.message ?? "未知错误") ---")
                    completion(.failure(error))
                }
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
    
    // 个人信息项 (Personal Info)
    func submitPersonalInfo(with params: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Apply.submitPersonalInfo, parameters: params) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    func queryPersonalInfo(completion: @escaping (Result<PersonalInformationModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            
            NW.requestGET(API.Apply.queryPersonalInfo) { (result: Result<PersonalInformationModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    // 联系人 (Contacts)
    func submitContacts(with params: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Apply.submitContacts, parameters: params) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    func queryContacts(completion: @escaping (Result<EmergencyContactContainerModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestGET(API.Apply.queryContacts) { (result: Result<EmergencyContactContainerModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    // 银行卡 (Bank Card)
    func submitBankInfo(with params: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Apply.submitBankInfo, parameters: params) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    func queryBankInfo(completion: @escaping (Result<BankCardInfoModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestGET(API.Apply.queryBankInfo) { (result: Result<BankCardInfoModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    // OCR 进件信息 (OCR Form Data)
    func submitOCRInfo(with params: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Apply.submitOCRInfo, parameters: params) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    func queryOCRInfo(completion: @escaping (Result<UserOcrIdentityModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestGET(API.Apply.queryOCRInfo) { (result: Result<UserOcrIdentityModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
    // 人脸与 OCR 校验 (Verification)
    func faceRecognition(with params: [String: String], data: Data, progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<CustomerOCRResultModel, RequestError>) -> Void) {
            let name = ApplyObfuscatedKey.OCRVerify.multipartFile.rawValue
            let fileName = String.fileNameGenerate(with: "jpeg")
            let multipartData = HWMultipartData(data: data, name: name, fileName: fileName, mimeType: HWDataMimeType.JPEG.rawValue)
        
        print("*** params = \(params)")
        print("*** multipartData = \(multipartData)")
        NW.UPLOAD(with: API.Apply.faceRecognition, parameters: params, datas: [multipartData], progressHandler: progressHandler) { (result: Result<CustomerOCRResultModel, RequestError>) in
            
            completion(result)
        }
    }
    // 客户OCR校验
    func customerOCRVerify(with params: [String: String], data: Data, completion: @escaping (Result<CustomerOCRResultModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            let name = ApplyObfuscatedKey.OCRVerify.multipartFile.rawValue
            let fileName = String.fileNameGenerate(with: "jpeg")
            let multipartData = HWMultipartData(data: data, name: name, fileName: fileName, mimeType: HWDataMimeType.JPEG.rawValue)
            
            NW.UPLOAD(with: API.Apply.customerOCRVerify, parameters: params, datas: [multipartData], progressHandler: nil) { (result: Result<CustomerOCRResultModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
    // 行政区域配置查询
    func fetchRegionConfig(completion: @escaping (Result<RegionConfigModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestGET(API.Apply.regionConfigQuery) { (result: Result<RegionConfigModel, RequestError>) in
                finish()
                if case .success(let model) = result {
                    let dict = model.toDictionary()
                    // 存入 Documents 目录，自定义文件名为 "RegionData"
                    SandboxManager.shared.save(data: dict, to: "RegionData")
                }
                completion(result)
            }
        }
    }
    
    // 获取用户银行卡列表
    func fetchUserBankList(completion: @escaping (Result<UserBankCardInfoList, RequestError>) -> Void) {
        NW.requestGET(API.BankApi.userBankList) { (result: Result<UserBankCardInfoList, RequestError>) in
            completion(result)
        }
    }
    
    
    // 查询银行名称列表
    func fetchBankListQuery(completion: @escaping (Result<BankConfigModel, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestGET(API.BankApi.bankListQuery) { (result: Result<BankConfigModel, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
    // 提交银行卡信息-个人银行卡页面
    func submitBankApi(with params: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.BankApi.submitBankInfo, parameters: params) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
    // 修改银行卡
    func queryBankCard(with params: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.BankApi.queryBankCard, parameters: params) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
    
    // 删除银行卡信息
    func deleteBankInfo(with id: String, completion: @escaping (Result<BankConfigModel, RequestError>) -> Void) {
        let param: [String: String] = [
            "wGlVByadhXXG4SRrlX": id
        ]
        GIFHUD.runTask { finish in
            NW.requestPOST(API.BankApi.deleteBankInfo, parameters: param) { (result: Result<BankConfigModel, RequestError>) in
                finish()
                if case .success(let data) = result {
                    print("*** data = \(data)")
                }
                completion(result)
            }
        }
    }
    
}
