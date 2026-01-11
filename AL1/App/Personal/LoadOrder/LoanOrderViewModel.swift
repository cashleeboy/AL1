//
//  LoanOrderViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import Combine
import Foundation

class LoanOrderViewModel {

    @Published var orderList: [OrderListItem]?
    @Published var errorMessage: String?
    
    private lazy var repository = ReembolsoRepository()
    lazy var cancellables = Set<AnyCancellable>()

    // 历史订单
    func fetchHistoryOrder() {
        var params: [String: Any] = [:]
        params[HistoryOrderStatus.OrderListQueryArray] = HistoryOrderStatus.history.rawStatusValues
//        GIFHUD.runTask { [weak self] finish in
//            guard let self else { return }
            NW.requestPOST(API.Order.orderList, parameters: params) { (result: Result<OrderHistoryResponse, RequestError>) in
//                finish()
                switch result {
                case .success(let success):
                    self.orderList = success.orderList
                case .failure(let failure):
                    self.errorMessage = failure.message
                }
            }
//        }
    }
    
}
