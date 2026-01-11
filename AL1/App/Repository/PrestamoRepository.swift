//
//  PrestamoRepository.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation
import SwiftyJSON

class PrestamoRepository {
    
    // 首页查询
    func obtainHomeSearch(completion: @escaping (Result<PrestamoHomeModel, RequestError>) -> Void) {
        NW.requestGET(API.Prestamo.homeSearch) { (result: Result<PrestamoHomeModel, RequestError>) in
            switch result {
            case .success(let success):
                print("*** success.code = \(success.code)")
//                print("*** success = \(success)")
            case .failure(_):
                break
            }
            completion(result)
        }
    }
    
    //获取首页推荐信息
    func obtainIndexInfo(completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        NW.requestGET(API.Prestamo.recommendInfo, completion: completion)
    }
 

    // 确认借款-提交订单
    /*
     bankId :qS904 : hvTDGT8j9GQ8JjT: 收款银行账号（首借可不传）,示例值(bankId)
     "wSHJYIU1HgMwuLvO": [
     {
       "poW1L_VZhHh": "appOrderId",             // 非必须 (首贷 预下单再确认)有就传 没有就不传,示例值(appOrderId)
       "fS2chxKewoa7dtFQSV": "loanAmount",      // 借款金额,示例值(loanAmount)
       "btdxX7JuiyUOwNdk": "productCode"        // 产品编号,示例值(productCode)
     }
     ]
     */
    func fetchComfirmToLoan(with param: [String: Any], completion: @escaping (Result<PlainData, RequestError>) -> Void) {
        GIFHUD.runTask { finish in
            NW.requestPOST(API.Prestamo.comfirmLoan, parameters: param) { (result: Result<PlainData, RequestError>) in
                finish()
                completion(result)
            }
        }
    }
}
