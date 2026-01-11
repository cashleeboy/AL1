//
//  UserBankLisViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/8.
//

import UIKit
import Combine

enum UserBankListEntry {
    case home
    case personal
}

class UserBankLisViewModel {
    var cancellables = Set<AnyCancellable>()
    private lazy var applyRepos = ApplyRepository()
    
    @Published var bankList: [UserBankCardItem]?
    @Published var errorMassage: String?
    @Published var selectedBankModelItem: BankModel?
    
    var selectedBankCard: UserBankCardItem? {
        didSet {
            if let dict = selectedBankCard?.toBackendDictionary() {
                bankInfoParam = dict
            }
        }
    }
    lazy var bankInfoParam: [String: Any] = [:]
    func fetchBankList() {
        applyRepos.fetchUserBankList { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                bankList = success.bankCardList.map { item in
                    var mutableItem = item // 1. 创建一个可变副本
                    // 2. 这里的判断逻辑通常是 ID 对比，确保类型一致
                    if mutableItem.id == UserSession.shared.bankInfoAuditing?.id {
                        mutableItem.isSelected = true
                    }
                    return mutableItem // 3. 返回副本
                }
            case .failure(let failure):
                errorMassage = failure.message
            }
        }
    }
    
    /*
     {
       "poW1L_VZhHh": "appOrderId",
       "lVAVr1YrRdMw3DZ": "bankAccountCCI",
       "fMuuZkDBUJIxAczLcIR": "bankAccountId",
       "sB29fpnkHEfSxCczPUu": "bankAccountType",
       "s_0ioeu": "bankCardNo",
       "hvTDGT8j9GQ8JjT": "bankId",
       "y0_BW": "bankName"
     }
     */
    // 修改银行卡
    func queryBankInfo() {
        if let model = selectedBankCard {
            selectedBankModelItem = BankModel(id: model.id, name: model.bankName, bankCardNo: model.bankCardNo)
        }
    }
}
