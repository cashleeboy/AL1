//
//  FaceRecognitionViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/26.
//

import UIKit
import Combine
import Foundation
import CoreLocation

class FaceRecognitionViewModel: ObservableObject, ApplicationAuthModuleProtocol
{
    typealias DataModel = UserOcrIdentityModel  // fetch
    typealias SubmitDataModel = PlainData
    var isUpdate: Int = 0
    var reviewType: InfoReviewType = .faceRecognition
    var ocrResultModel: CustomerOCRResultModel?
    var uploadingType: FaceAuthStepType?
    
    @Published var isDataComplete: Bool = false
    var isDataCompletePublisher: AnyPublisher<Bool, Never> {
        $isDataComplete.eraseToAnyPublisher()
    }
    static let processId: String = "10"
    
    private lazy var respository = ApplyRepository()
    private lazy var baseRespository = BaseRepository()
    private var coordinate: CLLocationCoordinate2D?
    
    func fetchData(completion: @escaping (Result<UserOcrIdentityModel, RequestError>) -> Void) {
    }
    
    func submitData(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        
    }
    
    // 客户OCR校验
    func customerOCRVerify(with image: UIImage, from source: PhotoSource, progressHandler: ((Double) -> Void)?, completion: @escaping (Result<CustomerOCRResultModel, RequestError>) -> Void) {
        var params: [String: String] = [:]
        params[ApplyObfuscatedKey.Common.isUpdate.rawValue] = "0"
        params[ApplyObfuscatedKey.FaceVerify.processId.rawValue] = FaceRecognitionViewModel.processId
        params[ApplyObfuscatedKey.FaceVerify.step.rawValue] = String(reviewType.rawValue)
        
        if let coor = coordinate {
            params[ApplyObfuscatedKey.FaceVerify.latitude.rawValue] = String(coor.latitude)
            params[ApplyObfuscatedKey.FaceVerify.longitude.rawValue] = String(coor.longitude)
        }
        
        var fixedImage = image
        if source == .camera {
            fixedImage = image.fixImageOrientation()
        }
        if let data = fixedImage.jpegData(compressionQuality: 0.8) {
            do {
                let imgData = try compressForIDCard(rawData: data)
                GIFHUD.runTask { finish in
                    respository.faceRecognition(with: params, data: imgData, progressHandler: { progress in
                        progressHandler?(progress)
                    }) { [weak self] result in
                        finish()
                        guard let self else { return }
                        switch result {
                        case .success(let success):
                            completion(.success(success))
                            // 提交客户上传数据
                            //                        GIFHUD.runTask { finish in
//                            let infos = DeviceInfoHelper.fetchCurrentDeviceInfo()
//                            self.baseRespository.submitCustomerUploaded(with: infos.toDictionary()) { uploadResult in
//                                self.ocrResultModel = success
//                                //                                finish()
//                                switch uploadResult {
//                                case .success(_):
////                                    completion(.success(success))
//                                case .failure(let uploadFailure):
//                                    completion(.failure(uploadFailure))
//                                }
//                            }
                            //                        }
                        case .failure(let failure):
                            completion(.failure(failure))
                        }
                    }
                }
            } catch let error {
                completion(.failure(.other(message: error.localizedDescription)))
            }
        } else {
            completion(.failure(.other(message: "")))
        }
    }
    
    func fetchCurrentLocation() {
        AppLocationProvider.shared.fetchCurrentLocation { [weak self] location, error in
            guard let self else { return }
            if let loc = location {
                coordinate = loc.coordinate
            }
        }
    }
}

extension FaceRecognitionViewModel {    
    private func compressForIDCard(rawData: Data) throws -> Data {
        // 1. 第一步：先将超大图缩小到合理像素（如长边 1280），保证 OCR 识别率
        let resizedData = try ImageCompress.compressImageData(rawData, limitLongWidth: 1280)
        // 2. 第二步：在像素合适的基础上，压缩文件大小到 1MB 以内
        let finalData = try ImageCompress.compressImageData(resizedData, limitDataSize: 1024 * 1024)
        return finalData
    }
    
}
