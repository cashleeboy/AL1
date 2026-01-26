//
//  UploadDataPageViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import Foundation

class UploadDataPageViewModel {
    private lazy var repository: BaseRepository = BaseRepository()
    
    // 提交需要添加额外的字典
    func submitCustomerUploaded(extraParams: [String: Any] = [:], onSuccess: @escaping (() -> Void), onFail: @escaping ((String) -> Void)) {
        let infos = DeviceInfoHelper.fetchCurrentDeviceInfo()
        let fullParams = infos.toDictionary(extraParams: extraParams)
        repository.submitCustomerUploaded(with: fullParams) { result in
            switch result {
            case .success(_):
                onSuccess()
            case .failure(let failure):
                onFail(failure.message)
            }
        }
    }
    
}
