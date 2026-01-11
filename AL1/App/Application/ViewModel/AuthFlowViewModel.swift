//
//  ApplicationAuthViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/24.
//

import UIKit
import Combine

protocol ApplicationAuthModuleProtocol {
    // 定义关联类型，代表该模块具体的数据模型
    associatedtype DataModel
    associatedtype SubmitDataModel
    
    var isUpdate: Int { get }
    
    // 1. 将属性改为普通的 Bool，但增加一个计算属性返回 Publisher
    var isDataComplete: Bool { get }
    var isDataCompletePublisher: AnyPublisher<Bool, Never> { get }

//    var dataFailurePublisher: AnyPublisher<String, Never> { get }
    
    var reviewType: InfoReviewType { get }
    func fetchData(completion: @escaping (Result<DataModel, RequestError>) -> Void)
    func submitData(completion: @escaping (Result<SubmitDataModel, RequestError>) -> Void)
}

class AuthFlowViewModel {
    lazy var cancellables = Set<AnyCancellable>()
    
    // 弱引用导航控制器，用于执行 push/pop
    weak var navigationController: UINavigationController?
    // 新增：流程结束后的刷新回调
    var onFlowFinishedRequestRefresh: (() -> Void)?
    
    /// 外部入口：开启流程
    func startFlow(from nav: UINavigationController?, startStep: InfoReviewType, refreshBlock: (() -> Void)? = nil) {
        self.navigationController = nav
        self.onFlowFinishedRequestRefresh = refreshBlock
        navigateToStep(startStep)
    }
    
    /// 统一的退出并刷新方法
    func finishFlowAndRefresh() {
        navigationController?.popToRootViewController(animated: true)
        // 触发外部传入的刷新逻辑
        onFlowFinishedRequestRefresh?()
    }

    /// 跳转逻辑
    func navigateToStep(_ type: InfoReviewType) {
        guard let nav = navigationController else { return }
        let nextVC = AuthFlowProvider.makeApplyController(for: type, coordinator: self)
        nav.pushViewController(nextVC, animated: true)
    }
    
    /// 被子类 VC 调用：处理模块完成
    func handleModuleEntryFinished(current: InfoReviewType) {
        switch current {
        case .personal:
            navigateToStep(.contact)
        case .contact:
            navigateToStep(.bank)
        case .bank:
            navigateToStep(.certificate)
        case .certificate:
            navigateToStep(.faceRecognition)
        case .faceRecognition:
//            finishFlow()
            navigateToStep(.dataValid)
        case .dataValid:
            navigateToStep(.dataValid)
        }
    }
    
    private func finishFlow() {
        // 全部完成，可以返回首页或跳转结果页
        navigationController?.popToRootViewController(animated: true)
//        NotificationCenter.default.post(name: .authFlowDidFinish, object: nil)
    }
}


struct AuthFlowProvider {
    
    /// 根据流程类型，生产对应的 ViewController 并注入其依赖
    /// - Parameters:
    ///   - type: 认证步骤类型 (个人、联系人、银行等)
    ///   - coordinator: 流程导演 (AuthFlowViewModel)，用于处理跳转逻辑
    /// - Returns: 包装好 VM 和 导演的 BaseApplyViewController
    static func makeApplyController(for type: InfoReviewType, coordinator: AuthFlowViewModel) -> UIViewController
    {
        switch type {
        case .personal:
            let viewModel = PersonalInfoModuleViewModel()
            let viewController = PersonalInfoApplyView(viewModel: viewModel, coordinator: coordinator)
            return viewController
            
        case .contact:
            let viewModel = ContactModuleViewModel()
            let viewController = ContactInfoApplyView(viewModel: viewModel, coordinator: coordinator)
            return viewController
            
        case .bank:
            let viewModel = BankModuleViewModel()
            let viewController = BankInfoApplyView(viewModel: viewModel, coordinator: coordinator)
            return viewController
            
        case .certificate:
            let viewModel = CertificateModuleViewModel()
            let viewController = CertificateApplyView(viewModel: viewModel, coordinator: coordinator)
            return viewController
        case .faceRecognition:
            let viewModel = FaceRecognitionViewModel()
            let viewController = FaceRecognitionView(viewModel: viewModel, coordinator: coordinator)
            return viewController
        case .dataValid:
            let viewController = UploadDataPageView(step: .isDataValid, coordinator: coordinator)
            return viewController
        }
    }
}
