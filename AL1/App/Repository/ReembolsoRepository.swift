//
//  BankRepository.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import Foundation

// 审核/转账中类目，待还款类目 当前订单：20,3,4,5 （待还款：4，审核中：20,3,5） 历史订单：22,7
// 订单状态集合 20:审核中 22:审核拒绝 3:放款中 4:还款中 5:放款失败未关闭 6:还款完成 结清订单 7-异常关闭
enum HistoryOrderStatus {
    case tobePay    // 待还款：4
    case review     // 审核中：20,3,5
    case history    // 历史订单：22,7
    
    /// 返回后端映射的状态码数组
    var rawStatusValues: [Int] {
        switch self {
        case .tobePay: return [4]
        case .review:  return [20]  // , 3, 5
        case .history: return [3, 4, 5, 6, 7, 20, 22]
        }
    }
    
    static var OrderListQueryReq = "toa0ZkswvKE"
    static var OrderListQueryArray = "h48cfWders"
    // app 订单列表
    static var OrderListDetailArray = "fhi5GcCx7cKfOtghj"
}

class ReembolsoRepository
{
    //审核/转账中类目，待还款类目 （待还款：4，审核中：20,3,5） 历史订单：22,7
    func fetchHistoryOrder(with status: HistoryOrderStatus, completion: @escaping (Result<OrderHistoryResponse, RequestError>) -> Void) {
        var params: [String: Any] = [:]
        params[HistoryOrderStatus.OrderListQueryArray] = status.rawStatusValues
//        GIFHUD.runTask { finish in
            NW.requestPOST(API.Order.orderList, parameters: params) { (result: Result<OrderHistoryResponse, RequestError>) in
//                finish()
                completion(result)
            }
//        }
    }
    
    // 
    func fetchOrderDetail(with orderId: [String], completion: @escaping (Result<OrderDetailModel, RequestError>) -> Void) {
        var params: [String: Any] = [:]
        params[HistoryOrderStatus.OrderListDetailArray] = orderId
//        GIFHUD.runTask { finish in
            NW.requestPOST(API.Order.orderDetail, parameters: params) { (result: Result<OrderDetailModel, RequestError>) in
//                finish()
                completion(result)
            }
//        }
    }
}
