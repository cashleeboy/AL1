//
//  BaseTableViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import UIKit
import SwiftEntryKit

class BaseTableViewModel {
    
    var serviceInquiryItems: [ServiceInquiryItem] {
        UserSession.shared.serviceContacts ?? []
    }
    private lazy var loginRepos = LoginRepository()
    
    // 客服信息查询
    func fetchServiceInfo(completion: @escaping ([ServiceInquiryItem]?, String?) -> Void) {
        guard serviceInquiryItems.isEmpty else {
            completion(serviceInquiryItems, nil)
            return
        }
        GIFHUD.runTask { finish in
            loginRepos.serviceInfoInquiry { result in
                finish()
                switch result {
                case .success(let model):
                    UserSession.shared.serviceContacts = model.items
                    completion(model.items, nil)
                case .failure(let error):
                    completion(nil, error.message)
                }
            }
        }
    }
    
}
