//
//  PrestamoViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import UIKit
import Network
import Combine
import Foundation

enum HomeDisplayStatus {
    case loading            // 加载中
    case apply              // 1: 未申请或资料未完成
    case confirmAmount      // 2: 首贷额度确认页
    case reviewing        // 3: 首页单订单状态
    case multiOrder         // 4: 首页多产品/多订单状态
    case error(String)      // 错误状态
}

class PrestamoViewModel
{
    @Published var isNetworkAvailable: Bool = false
    @Published var isNetworkRestricted: Bool = false
    
    var cancellables = Set<AnyCancellable>()
 
    // 原始数据模型
    @Published var homeModel: PrestamoHomeModel?
    // 当前页面应该展示的状态
    @Published var displayStatus: HomeDisplayStatus = .loading
    
    private lazy var baseCepository: BaseRepository = BaseRepository()
    private lazy var repository: PrestamoRepository = PrestamoRepository()
    private lazy var applyRepos = ApplyRepository()
    
    //
    var homeTableItems: [any TableItemProtocol]?
    var prestamoHome: PrestamoHome?
    
    @Published var isDataValid: Bool = false
    @Published var firstLoanMap: [String: Any] = [:]
    // selected map
    @Published var selectedProductsMap: [String: Any] = [:]
    @Published var emptyStatus: EmptyStateConfig?
    
    // MARK: - Actions (UI 回调)
    var onActionNeedLogin: (() -> Void)?
    var onActionStartRecovery: (() -> Void)?
    var onActionNavigateToAuth: ((AuthStepType) -> Void)?
    var onActionFinish: (() -> Void)?
    var onErrorMessage: ((String) -> Void)?

    //
    var onActionShowBankInfo: (() -> Void)?
    var onActionShowFee: ((String, [String], [String], Bool) -> Void)?
    
    init() {
        // apply sections
        let applyClosure: (() -> Void) = { [weak self] in
            guard let self else { return }
            userSolicitar()
        }
        prestamoHome = PrestamoHome(solicitarAhoraAction: applyClosure)
        
    }
    
    // 获取数据 
    func buildHomeSections() -> [any TableItemProtocol] {
        let buildInitialSections: () -> [any TableItemProtocol] = { [weak self] in
            guard let self = self else { return [] }
            var list: [any TableItemProtocol] = []
            if let homeItem = self.prestamoHome {
                list.append(homeItem)
            }
            list.append(PrestamoMenuItem())
            return list
        }
        guard let model = homeModel else {
            return buildInitialSections()
        }
        
        switch model.layoutType {
        case .initialOrIncomplete:
            return buildInitialSections()
        case .firstLoanConfirm:     // 首次借款
            firstLoanMap.removeAll()
            
            var list: [any TableItemProtocol] = []
            if let info = model.loanInfo {
                
                if UserSession.shared.bankInfoAuditing == nil{
                    let bankModel: BankModel = BankModel(id: info.bankId, name: info.bankCardName, bankCardNo: info.bankCardNo)
                    UserSession.shared.bankInfoAuditing = bankModel
                }
                
                let model = FirstLoamHeaderModel(loanInfoModel: info, bankModel: UserSession.shared.bankInfoAuditing) { [weak self] in
                    guard let self else { return }
                    onActionShowBankInfo?()
                } serviceRepaymentPopupAction: { [weak self] title, titles, values, showSecondaryButton in
                    guard let self else { return }
                    onActionShowFee?(title, titles, values, showSecondaryButton)
                }
                list.append(model)
                let isOnlyOne = info.products.count == 1
                
                let items = info.products.map { model in
                    let item = FirstLoamItemModel(loanInfoModel: model, isSelected: model.isCheck, isOnlyOne: isOnlyOne) { [weak self] identifier, isSelected, params in
                        guard let self = self else { return }
                        guard isOnlyOne == false else {
                            onErrorMessage?("El límite mínimo de endeudamiento es uno")
                            return
                        }
                        if isSelected, info.products.count > 1 {
                            self.firstLoanMap[identifier] = params
                        } else {
                            self.firstLoanMap.removeValue(forKey: identifier)
                        }
                    }
                    if model.isCheck {
                        self.firstLoanMap[item.uuid] = item.loanInfoModel.fetchComfirmLoan()
                    }
                    return item
                }
                list.append(contentsOf: items)
                
                // 如果 UserSession 
            }
            return list
        case .singleOrderStatus:
            //FIXME: 下个版本完善
            var list: [any TableItemProtocol] = []
            if let type = model.orderInfo?.orderShowType, let config = type.emptyConfig {
                let emptyStatus = EmptyStateConfig.imageTitleMessage(
                    image: UIImage(named: config.imageName),
                    title: config.title,
                    message: config.message,
                    buttonTitle: config.btnTitle
                )
                let item = PrestamoEmptyModel(emptyStatus: emptyStatus) { _ in
                    
                }
                list.append(item)
            }
            return list
        case .multiOrderStatus:
            // TODO: 处理多订单状态布局，例如返回多个订单卡片
            var list: [any TableItemProtocol] = []
            let item = PrestamoTitleSectionItem(title: "Aplicación recomendada")
            list.append(item)
            
            let products = model.loanInfo?.products.map { productModel in
                PrestamoProductItem(productModel: productModel) { [weak self] identifier, isSelected in
                    guard let self = self else { return }
                    if isSelected {
                        self.selectedProductsMap[identifier] = true
                    } else {
                        self.selectedProductsMap.removeValue(forKey: identifier)
                    }
                }
            } ?? []
            list.append(contentsOf: products)
            
            return list
        case .unknown:
            return buildInitialSections()
        }
    }
    
    func userSolicitar() {
        guard UserSession.shared.isLoggedIn else {
            self.onActionNeedLogin?() // 1. 登录校验：提前退出
            return
        }
        // 2. 检查被拒恢复期 (Recover Flag)
        if homeModel?.recoverFlag == true {
            handleRecoveryFlow()
            return
        }
        obtainApplyStatus { [weak self] progressModel in
            guard let self = self else { return }
            if progressModel.isAllStepsFinished {
                // 获取时效
                dataValid()
            } else {
                // 根据我们定义的 AuthStepType 枚举跳转
                let nextStep = progressModel.currentStepType
                self.onActionNavigateToAuth?(nextStep)
            }
        } onFailure: { [weak self] message in
            self?.onErrorMessage?(message)
        }
    }
    
    // 获取定位权限
    func requestLocationPermission(thenFetchIdfa: @escaping () -> Void) {
        AppLocationProvider.shared.requestLocationPermission { status in
            // 定位权限流程结束（无论成功或失败），去请求 IDFA
//            print("*** Location auth done, now fetching IDFA...")
            thenFetchIdfa()
        }
    }
    
    func fetchIdfa(thenFetchIdfa: @escaping () -> Void) {
        AppIDFAProvider.shared.requestAuthorization { isAuthorized in
            thenFetchIdfa()
        }
    }
    
    func auditingModifyBankInfo(with info: BankModel) {
        UserSession.shared.bankInfoAuditing = info
    }
}

// MARK: - 私有处理方法
extension PrestamoViewModel {
    /// 处理被拒恢复流程
    private func handleRecoveryFlow() {
        // 流程：基本信息 -> 联系人 -> 风控上传
        self.onActionStartRecovery?()
    }
    
    /// 根据 orderShowType 解析当前 UI 状态
    private func parseDisplayStatus(_ model: PrestamoHomeModel) {
        if let orderStatus = model.orderInfo?.orderShowType, orderStatus == .lendFailedBankReason {
            emptyStatus = .noResults(query: "Actualmente no hay productos disponibles para préstamo")
            displayStatus = .error("Error en la cuenta. Modifique su tarjeta bancaria.")
            return
        }
        switch model.layoutType {
        case .initialOrIncomplete:
            self.displayStatus = .apply
        case .firstLoanConfirm:
            self.displayStatus = .confirmAmount
        case .singleOrderStatus:
            self.displayStatus = .reviewing
        case .multiOrderStatus:
            // 情况 4: 这种模式下通常会显示 statistics 里的产品列表
            self.displayStatus = .multiOrder
        case .unknown:
            self.displayStatus = .apply
        }
    }
    
    func performNetworkCheck() {
        NWPathMonitorManager.shared.onStatusChanged = { [weak self] isAvailable, isRestricted in
            guard let self = self else { return }
            if isAvailable {
                self.isNetworkAvailable = isAvailable
                self.isNetworkRestricted = isRestricted
                // 如果后续不需要再监听，可以关掉
                 NWPathMonitorManager.shared.stopMonitoring()
            } else {
                emptyStatus = .noNetwork
            }
        }
        // 启动监听
        NWPathMonitorManager.shared.startMonitoring()
    }
    
}

extension PrestamoViewModel
{
    //首页查询
    func fetchHomeData(onSuccess: @escaping (() -> Void), onFail: @escaping (() -> Void)) {
        self.displayStatus = .loading
        repository.obtainHomeSearch { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.homeModel = model
                    self?.parseDisplayStatus(model)
                    onSuccess()
                case .failure(_):
                    self?.emptyStatus = .noResults(query: "Actualmente no hay productos disponibles para préstamo")
                    self?.displayStatus = .error("Error de red")
                    onFail()
                }
            }
        }
    }
    
    // use hud
    /// 获取项目初始配置
    /// - Parameters:
    ///   - useHud: 是否显示加载动画（HUD）
    ///   - onSuccess: 成功回调
    ///   - onFailure: 失败回调
    func obtainInitial(useHud: Bool = false, onSuccess: @escaping (() -> Void), onFailure: @escaping (() -> Void)) {
        // 定义核心业务逻辑块
        let taskLogic: (@escaping () -> Void) -> Void = { [weak self] completion in
            guard let self = self else { return }
            self.baseCepository.obtainInitial { [weak self] result in
                guard let self = self else {
                    completion()
                    return
                }
                switch result {
                case .success:
                    // 串行执行首页数据获取
                    self.fetchHomeData(onSuccess: {
                        completion()
                        onSuccess()
                    }, onFail: {
                        completion()
                        onFailure()
                    })
                case .failure:
                    completion()
                    onFailure()
                }
            }
        }

        // 根据参数决定是否包裹 HUD
        if useHud {
            GIFHUD.runTask { finish in
                taskLogic { finish() }
            }
        } else {
            // 直接执行，传入一个空的闭包作为完成信号
            taskLogic { }
        }
    }
    
    func obtainIndexInfo() {
        repository.obtainIndexInfo { result in
            switch result {
            case .success(let data):
                
                break
            case .failure(_):
                
                break
            }
        }
    }
    
    // 获取进件进度
    func obtainApplyStatus(onCompletion: @escaping ((AuthStatusModel) -> Void), onFailure: @escaping (String) -> Void) {
        applyRepos.fetchAuthStatus { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                onCompletion(data)
            case .failure(let error):
                onFailure(error.message)
            }
        }
    }
    
    /// 检查数据是否有效
    /// - Parameter completion: 可选的自定义处理闭包。如果传入，则由外部控制跳转逻辑。
    func dataValid(completion: ((Bool) -> Void)? = nil) {
        baseCepository.fetchDataIsValid { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                let isValid = success.isValid
                
                if let completion = completion {
                    completion(isValid)
                } else {
                    if isValid {
                        self.onActionFinish?()
                    } else {
                        self.isDataValid = false
                    }
                }
            case .failure(let failure):
                self.onErrorMessage?(failure.message)
            }
        }
    }
    
    // 首款申请
    func fetchComfirmToLoan() {
        
        dataValid { [weak self] isValid in
            guard let self else { return }
            guard isValid else {
                isDataValid = false
                return
            }
            let itemsArray = Array(self.firstLoanMap.values)
            var params: [String: Any] = [
                PrestamoKey.LoanOrder.upload.rawValue : itemsArray
            ]
            if let bankId = UserSession.shared.bankInfoAuditing?.id {
                params[PrestamoKey.LoanOrder.bankId.rawValue] = bankId
            }
            repository.fetchComfirmToLoan(with: params) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.onActionFinish?()
                case .failure(let failure):
                    self.onErrorMessage?(failure.message)
                }
            }
        }
    }
}
