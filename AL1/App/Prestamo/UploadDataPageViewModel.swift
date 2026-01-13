//
//  UploadDataPageViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import Foundation

class UploadDataPageViewModel {
    private lazy var repository: BaseRepository = BaseRepository()
    
    func submitCustomerUploaded(onSuccess: @escaping (() -> Void), onFail: @escaping ((String) -> Void)) {
        let infos = DeviceInfoHelper.fetchCurrentDeviceInfo()
        repository.submitCustomerUploaded(with: infos.toDictionary()) { result in
            switch result {
            case .success(_):
                onSuccess()
            case .failure(let failure):
                onFail(failure.message)
            }
        }
    }
    
}
