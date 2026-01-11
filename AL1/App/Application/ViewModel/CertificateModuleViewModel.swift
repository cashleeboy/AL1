//
//  CertificateModuleViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import Combine
import Foundation
import UIKit

enum IdentityStauts {
    case unfinish
    case failure
    case success
}

enum IdentityType: String {
    case front = "FRONT"
    case back = "BACK"
}

// 独立的联系人 ViewModel
class CertificateModuleViewModel: ObservableObject, ApplicationAuthModuleProtocol {
    typealias DataModel = UserOcrIdentityModel  // fetch
    typealias SubmitDataModel = PlainData
    
    var reviewType: InfoReviewType = .certificate

    @Published var identityStatus: IdentityStauts = .unfinish
    lazy var cancellables = Set<AnyCancellable>()
    
    // 1. 让 View 层使用的数组
    lazy var certRows: [RowFormer] = []
    
    var isUpdate: Int = 0
    @Published var isDataComplete: Bool = false
    
    // current image
    var currentImage: UIImage?
    var photoSource: PhotoSource = .camera
    var isDataCompletePublisher: AnyPublisher<Bool, Never> {
        $isDataComplete.eraseToAnyPublisher()
    }

    @Published var selectedIdentityMap: [String: String] = [:]
    private var ocrResultModel: CustomerOCRResultModel?
    
    private lazy var respository = ApplyRepository()
    
    // 2. 内部校验时筛选遵循协议的行
    private var validatableRows: [IdentityFormRow] {
        return certRows.compactMap { $0 as? IdentityFormRow }
    }
    var identityInfoRow: FormIdentityInfoRowFormer<FormIdentityInfoCell>?
    
    /// 统一更新证件/OCR 识别出的或手动输入的值
    func updateCertValue(for info: IdentityInfoModel, value: String) {
        info.keys.values.forEach { key in
            selectedIdentityMap[key] = value
        }
        isDataComplete = validate() == nil ? true : false
    }
    //
    func fetchData(completion: @escaping (Result<UserOcrIdentityModel, RequestError>) -> Void) {
        respository.queryOCRInfo { [weak self] result in
            guard let self else { return }
            if case .success(let success) = result {
                syncValuesToFiledValues(from: success)
            }
            completion(result)
        }
    }
    // submit ocr with photosource
    func submitOcrData(completion: @escaping (Result<CustomerOCRResultModel, RequestError>) -> Void) {
//        guard ocrResultModel == nil else {
//            return
//        }
        guard let image = currentImage else {
            return
        }
        customerOCRVerify(with: image, from: photoSource, completion: completion)
    }
    
    func submitData(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        guard isDataComplete else {
            return
        }
        let params = ApplyObfuscatedKey.makeParams(
            rootKey: .identityInfo,
            value: selectedIdentityMap, isUpdate: isUpdate)
        respository.submitOCRInfo(with: params) { result in
            completion(result)
        }
    }
    
    private func syncValuesToFiledValues(from model: UserOcrIdentityModel) {
        isUpdate = model.isUpdate
        selectedIdentityMap[BackendORCKeys.name] = model.firstName
        selectedIdentityMap[BackendORCKeys.middleName] = model.middleName
        selectedIdentityMap[BackendORCKeys.lastName] = model.lastName
        selectedIdentityMap[BackendORCKeys.nuiNumber] = model.idCardNumber
        selectedIdentityMap[BackendORCKeys.birthDay] = model.birthday
        selectedIdentityMap[BackendORCKeys.gender] = model.gender
        selectedIdentityMap[BackendORCKeys.fromUrl] = model.frontUrl

        isDataComplete = validate() == nil ? true : false
    }
}

extension CertificateModuleViewModel
{
    // 客户OCR校验
    func customerOCRVerify(with image: UIImage, from source: PhotoSource, type: IdentityType = .front, completion: @escaping (Result<CustomerOCRResultModel, RequestError>) -> Void) {
        var params: [String: String] = [:]
        params[ApplyObfuscatedKey.OCRVerify.type.rawValue] = type.rawValue
        
        var fixedImage = image
        if source == .camera {
            fixedImage = image.fixImageOrientation()
        }
        if let data = fixedImage.jpegData(compressionQuality: 0.8) {
            do {
                let imgData = try compressForIDCard(rawData: data)
                respository.customerOCRVerify(with: params, data: imgData) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let success):
//                        https://quark-hk-test-file.quarksre.com/s3file/download/6e98815a-32f3-45be-a1f9-ed7198897d09.jpeg
                        if !success.frontUrl.isEmpty {
                            selectedIdentityMap[BackendORCKeys.fromUrl] = success.frontUrl
                        }
                        ocrResultModel = success
                        completion(.success(success))
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            } catch let error {
                completion(.failure(.other(message: error.localizedDescription)))
            }
        } else {
            completion(.failure(.other(message: "")))
        }
    }
    
    private func compressForIDCard(rawData: Data) throws -> Data {
        // 1. 第一步：先将超大图缩小到合理像素（如长边 1280），保证 OCR 识别率
        let resizedData = try ImageCompress.compressImageData(rawData, limitLongWidth: 1280)
        // 2. 第二步：在像素合适的基础上，压缩文件大小到 1MB 以内
        let finalData = try ImageCompress.compressImageData(resizedData, limitDataSize: 1024 * 1024)
        return finalData
    }
    
    /// 校验逻辑
    func validate() -> PersonalType? {
        let rowsToValidate = validatableRows
        let firstInvalidRow = rowsToValidate.first { row in
            guard let info = row.infoModel else {
                return row.currentGener == nil
            }
            let backendKeys = info.keys.values
            switch info.type {
            case .name:
                return !backendKeys.allSatisfy { key in
                    let value = selectedIdentityMap[key] ?? ""
                    return value.isValidName(min: 1, max: 30)   // 假设该行只有一个 key 对应姓名
                }
            case .lastName:
                return !backendKeys.allSatisfy { key in
                    let value = selectedIdentityMap[key] ?? ""
                    return value.isValidName(min: 3, max: 60)   // 校验 Apellidos: 3~60个字符
                }
            default:
                let isAllValuesPresent = backendKeys.allSatisfy { backendKey in
                    if let value = selectedIdentityMap[backendKey], !value.isEmpty {
                        return true
                    }
                    return false
                }
                return !isAllValuesPresent
            }
        }
        let isIdentityInfoValid = identityInfoRow?.isIdentityStatus == .success
        
        if let invalidRow = firstInvalidRow {
            guard let invalidInfo = invalidRow.infoModel else {
                return .genero
            }
            return invalidInfo.type
        } else if !isIdentityInfoValid {
            return .ocr
        }
        return nil
    }
    
    func orcInfoFields() -> [IdentityInfoModel] {
        var list: [IdentityInfoModel] = []
        // name
        list.append(IdentityInfoModel(
            type: .name,
            keys: ["value": BackendORCKeys.name],
            fieldType: .write
        ))
        // last name
        list.append(IdentityInfoModel(
            type: .lastName,
            keys: [
                "value": BackendORCKeys.lastName,
            ],
            fieldType: .write
        ))
        list.append(IdentityInfoModel(
            type: .middleName,
            keys: ["value": BackendORCKeys.middleName],
            fieldType: .write
        ))
        list.append(IdentityInfoModel(
            type: .genero,
            keys: ["value": BackendORCKeys.gender],
            fieldType: .gender
        ))
        list.append(IdentityInfoModel(
            type: .nuiNumber,
            keys: ["value": BackendORCKeys.nuiNumber],
            fieldType: .write
        ))
        list.append(IdentityInfoModel(
            type: .birthday,
            keys: ["value": BackendORCKeys.birthDay],
            fieldType: .birth
        ))
        return list
    }
}
