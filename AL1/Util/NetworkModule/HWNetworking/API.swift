//
//  API.swift
//  AL1
//
//  Created by Ethan.li on 2024/12/5.
//

import UIKit
import Foundation

struct API {
    
    private static let domainQueue = DispatchQueue(label: "com.api.domain.al1")
    
    struct ProjectConfig {
        // 获取项目初始配置
        static let projectConfig = APIItem(APIConfig.Path.Project.initialConfig, m: .get)
        // 通用配置查询、获取风控数据过滤规则
        static let sysConfig = APIItem(APIConfig.Path.Project.sysConfig)
        // 提交客户上传数据
        static let submitCustomerData = APIItem(APIConfig.Path.Project.submitCustomerData, m: .post)
        
        // 提交反馈信息 /gZ2VBtAYnEeuA/uvA_7/ax1Wf/sCpOPuNcW
        static let feedbackInfo = APIItem(APIConfig.Path.Project.feedbackInfo, m: .post)
    }
    
    struct Prestamo {
        // Home searc
        static let homeSearch = APIItem(APIConfig.Path.Loan.homeSearch)
         // Recommended Information
        static let recommendInfo = APIItem(APIConfig.Path.Loan.recommendInfo)
        
        // 确认借款-提交订单
        static let comfirmLoan = APIItem(APIConfig.Path.Loan.comfirmLoan)
        // 申请成功推荐
        static let applySuccess = APIItem(APIConfig.Path.Loan.applySuccess, m: .post)
    }
    
    struct Login {
//        static func initializeLogin(with params: [String: Any]) -> APIItem {
//            return APIItem("/scrappy/marooned", m: .get, includeFixedParams: true, additionalParams: params)
//        }
        
        // 发送验证额吗
        static let sendAuth = APIItem(APIConfig.Path.Auth.sendAuthCode, m: .post)
        // 注册和登录
        static let login = APIItem(APIConfig.Path.Auth.login, m: .post)
        // 退出登录
        static let logout = APIItem(APIConfig.Path.Auth.logout, m: .post)
        // 注销用户账号
        static let cancelUserAccount = APIItem(APIConfig.Path.Auth.cancelUserAccount, m: .post)
        // 获取用户信息
        static let userInfo = APIItem(APIConfig.Path.Auth.userInfo)
        // 客服信息查询
        static let serviceInfoInquiry = APIItem(APIConfig.Path.Auth.serviceInfoInquiry)
    }
    
    // MARK: 认证相关接口
    struct Apply {
        // 获取认证进度
        static let getAuthStatus = APIItem(APIConfig.Path.Apply.getAuthStatus)
        // 检测数据是否有效
        static let dataIsValid = APIItem(APIConfig.Path.Apply.dataIsValid)
        
        // 个人信息项 (Personal Info)
        static let submitPersonalInfo = APIItem(APIConfig.Path.Apply.submitPersonalInfo, m: .post)
        static let queryPersonalInfo = APIItem(APIConfig.Path.Apply.queryPersonalInfo)
        
        // 联系人 (Contacts)
        static let submitContacts = APIItem(APIConfig.Path.Apply.submitContacts, m: .post)
        static let queryContacts = APIItem(APIConfig.Path.Apply.queryContacts)
        
        // 银行卡 (Bank Card)
        static let submitBankInfo = APIItem(APIConfig.Path.Apply.submitBankInfo, m: .post)
        static let queryBankInfo = APIItem(APIConfig.Path.Apply.queryBankInfo)
        
        // OCR 进件信息 (OCR Form Data)
        static let submitOCRInfo = APIItem(APIConfig.Path.Apply.submitOCRInfo, m: .post)
        static let queryOCRInfo = APIItem(APIConfig.Path.Apply.queryOCRInfo)
        
        // 人脸与 OCR 校验 (Verification)
        static let faceRecognition = APIItem(APIConfig.Path.Apply.faceRecognition, m: .post)
        static let customerOCRVerify = APIItem(APIConfig.Path.Apply.customerOCRVerify, m: .post)
        
        // 行政区域配置查询
        static let regionConfigQuery = APIItem(APIConfig.Path.Apply.regionConfigQuery)
    }
    
    struct BankApi {
        // 获取用户银行卡列表
        static let userBankList = APIItem(APIConfig.Path.BankApi.userBankList)
        // 查询银行名称列表
        static let bankListQuery = APIItem(APIConfig.Path.BankApi.bankListQuery)
        // 提交银行卡信息-个人银行卡页面
        static let submitBankInfo = APIItem(APIConfig.Path.BankApi.submitBankInfo, m: .post)
        // 删除银行卡信息
        static let deleteBankInfo = APIItem(APIConfig.Path.BankApi.deleteBankInfo, m: .post)
        // 修改银行卡重新放款-首页订单状态51
        static let queryBankCard = APIItem(APIConfig.Path.BankApi.queryBankCard, m: .post)
    }
    
    // MARK: 订单
    struct Order {
        // 订单列表
        static let orderList = APIItem(APIConfig.Path.Order.orderList, m: .post)
        // 订单详情
        static let orderDetail = APIItem(APIConfig.Path.Order.orderDetail, m: .post)
 
    }

}
