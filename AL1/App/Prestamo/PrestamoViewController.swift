//
//  PrestamoViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/12.
//

import UIKit
import SwiftEntryKit

// MARK: - 样式枚举和闭包定义
typealias ButtonAction = () -> Void

class PrestamoViewController: BaseTableViewController
{
    private lazy var leftBarTitle: UILabel = {
        let label = UILabel()
        label.text = "Fácil Crédito"
        label.textColor = AppColorStyle.shared.backgroundWhite
        label.font = AppFontProvider.shared.getFont18Semibold()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var privacyTermsView = PrivacyTermsView()
    
    private lazy var viewModel = PrestamoViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.performNetworkCheck()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.brandSecondary
        updateTableViewTop(to: .viewTop, animated: false)
        bindPublished()
        bindViewModel()
        
        // initial form data
        viewModel.homeTableItems = viewModel.buildHomeSections()
        setupFormData(with: viewModel.homeTableItems)
        
        // ⭐️ 串行执行：定位 -> IDFA
        viewModel.fetchIdfa { [weak self] in
            self?.viewModel.requestLocationPermission {
            }
        }
        setupPullToRefresh(to: false)
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
    
    override func configureBottomButton() {
        let style = BottomButtonStyle.primaryOnly(title: "Solicitar un préstamo ahora") { [weak self] in
            guard let self else { return }
            
        }
        bottomContainer.configure(with: style)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        //navigation.bar.additionalHeight = 20
        navigation.bar.layoutPaddings = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        navigation.bar.backgroundColor = .clear
        navigation.bar.alpha = 0
    }
    
    override func handleEmptyStateAction(for config: EmptyStateConfig) {
        switch config {
        case .noIndexData, .noNetwork, .noResults(_):
            viewModel.obtainInitial(useHud: true) {
            } onFailure: {
            }
        default:
            break
        }
    }
    
    func setupFormData(with items: [any TableItemProtocol]?) {
        guard let items else { return }
        //PrestamoProductCardItem(topInset: safeViewTopInset + 20),
        // 核心逻辑：利用协议自动转换，无需关心具体的 Model 类型
        let rows: [RowRepresentable] = items.compactMap { item in
            // 如果 Model 遵循了转换协议，则调用其转换方法
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { [weak self] selectedItem in
                    self?.handleRowSelection(item: selectedItem)
                })
            }
            
            // 特殊处理逻辑（如果有些 Model 不方便实现协议）
            switch item {
            case let cardItem as PrestamoProductCardItem:
                return ConcreteRow<PrestamoProductCardItem, PreProductOrderSectionCell>(item: cardItem) { _ in
                    // 具体的业务跳转
                }
            default:
                return nil
            }
        }
        reloadData(with: rows)
    }
    
    override func refresh() {
        viewModel.obtainInitial {
            self.stopPullToRefresh()
        } onFailure: {
        }
    }
    
}

// bind
extension PrestamoViewController
{
    private func bindPublished() {
        viewModel.$isNetworkAvailable
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                guard let self else { return }
                if isAvailable {
                    startPullToRefresh()
                }
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$isDataValid
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                guard let self else { return }
                if !isAvailable {
                    // 风控过期弹窗
                    dataExpirationDialog {
                        // 跳转上传数据
                        self.navigateToStep(.isDataValid)
                    }
                }
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$emptyStatus
            .dropFirst()
            .sink { [weak self] status in
                guard let self else { return }
                self.emptyStateConfig = status
                reloadData(with: [])
                isShowBottomButtonContainer = false
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$displayStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                print("*** displayStatus = \(status)")
                switch status {
                case .loading:
                    // 展示加载动画
                    break
                case .apply:
                    navigation.item.title = ""
                    navigation.item.leftBarButtonItem = UIBarButtonItem(customView: leftBarTitle)
                    navigation.bar.alpha = 0
                    navigation.bar.setBackgroundImage(nil, for: .default)
                    
                    isShowBottomButtonContainer = false
                    isShowTopBannerContainer = false
                    
                    updateTableViewTop(to: .viewTop, animated: false)
                    viewModel.homeTableItems = viewModel.buildHomeSections()
                    setupFormData(with: viewModel.homeTableItems)
                    
                    if var home = viewModel.prestamoHome {
                        home.value = viewModel.homeModel?.marketLoanAmount
                        home.marketLoanDays = viewModel.homeModel?.marketLoanDays
                        updateData(with: home)
                    }
                case .confirmAmount:    // 首次借款
                    navigation.item.title = "Confirmar préstamo"
                    navigation.item.leftBarButtonItem = nil
                    
                    viewModel.homeTableItems = viewModel.buildHomeSections()
                    setupFormData(with: viewModel.homeTableItems)
                case .reviewing:
                    navigation.item.title = ""
                    navigation.item.leftBarButtonItem = UIBarButtonItem(customView: appIconName())
                    
                    isShowBottomButtonContainer = false
                    isShowTopBannerContainer = true
                    
                    configureTopBanner(with: "¡Atención! No transfiera fondos a ninguna cuenta personal.")
                    navigation.bar.alpha = 1
                    navigation.bar.setBackgroundImage(
                        UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
                        for: .top,
                        barMetrics: .default)
                    updateTableViewTop(to: .viewTop, animated: false)
                    
                    viewModel.homeTableItems = viewModel.buildHomeSections()
                    setupFormData(with: viewModel.homeTableItems)
                case .multiOrder:
                    navigation.item.leftBarButtonItem = UIBarButtonItem(customView: leftBarTitle)
                    navigation.bar.alpha = 1
                    let navImage = UIImage(named: "home_nav_bar")?.withRenderingMode(.alwaysOriginal)
                    navigation.bar.setBackgroundImage(navImage, for: .top, barMetrics: .default)
                    if #available(iOS 13.0, *) {
                        let appearance = UINavigationBarAppearance()
                        appearance.configureWithTransparentBackground()
                        appearance.backgroundImage = navImage
                        appearance.shadowColor = .clear
                        
                        navigation.bar.standardAppearance = appearance
                        navigation.bar.scrollEdgeAppearance = appearance
                    }
                    updateTableViewTop(to: .safeArea, animated: false)
                    // show list
                    viewModel.homeTableItems = viewModel.buildHomeSections()
                    setupFormData(with: viewModel.homeTableItems)
                case .error(let msg):
                    self.showToast(msg)
                }
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$selectedProductsMap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] map in
                guard let self else { return }
                updateBottomState()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$firstLoanMap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] map in
                guard let self else { return }
                updateFirstLoanBottom()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func bindViewModel() {
        // 1. 处理登录跳转
        viewModel.onActionNeedLogin = { [weak self] in
            guard let self else { return }
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
        }
        // 2. 处理被拒恢复流程 (跳转至该流程的第一步)
        viewModel.onActionStartRecovery = { [weak self] in
            guard let self else { return }
            // 假设恢复流程从个人信息开始
            navigateToStep(.personalInfo)
        }
        // 3. 处理正常认证跳转
        viewModel.onActionNavigateToAuth = { [weak self] step in
            guard let self else { return }
            navigateToStep(step)
//            navigateToStep(.bankCardInfo)
        }
        viewModel.onActionFinish = { [weak self] in
            guard let self else { return }
            viewModel.obtainInitial {
            } onFailure: {
            }
        }
        viewModel.onErrorMessage = { [weak self] message in
            guard let self else { return }
            showToast(message)
            stopPullToRefresh()
        }
        
        viewModel.onActionShowBankInfo = { [weak self] in
            guard let self else { return }
            let vc = UserBankListViewController(entry: .home)
            vc.toModifyBankInfo = { model in
                self.viewModel.auditingModifyBankInfo(with: model)
                if let index = self.viewModel.homeTableItems?.firstIndex(where: { $0.identifier == "FirstLoamHeaderCell" }),
                   var cell = self.viewModel.homeTableItems?[index] as? FirstLoamHeaderModel {
                    
                    cell.bankModel = UserSession.shared.bankInfoAuditing
                    self.viewModel.homeTableItems?[index] = cell
                    self.updateData(with: cell, animated: false)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        viewModel.onActionShowFee = { [weak self] title, titles, values, showSecondaryButton in
            guard let self else { return }
            showServiceFeeDialog(with: title, titles: titles, values: values, showSecondaryButton: showSecondaryButton)
        }
        
    }

    // 统一的跳转分发器
    private func navigateToStep(_ step: AuthStepType) {
        switch step {
        case .personalInfo:
            let coordinator = AuthFlowViewModel()
            coordinator.startFlow(from: navigationController, startStep: .personal)
        case .contactInfo:
            let coordinator = AuthFlowViewModel()
            coordinator.startFlow(from: navigationController, startStep: .contact)
        case .bankCardInfo:
            let coordinator = AuthFlowViewModel()
            coordinator.startFlow(from: navigationController, startStep: .bank)
        case .identityInfo:
            let coordinator = AuthFlowViewModel()
            coordinator.startFlow(from: navigationController, startStep: .certificate)
        case .faceRecognieInfo:
            let coordinator = AuthFlowViewModel()
            coordinator.startFlow(from: navigationController, startStep: .faceRecognition) { [weak self] in
                guard let self else { return }
                refresh()
            }
        case .isDataValid:
            let coordinator = AuthFlowViewModel()
            coordinator.startFlow(from: navigationController, startStep: .dataValid) { [weak self] in
                guard let self else { return }
                refresh()
            }
        default:
            break
        }
    }
    
    // 统一处理点击事件
    private func handleRowSelection(item: Any) {
        switch item {
        case let product as PrestamoProductItem:
            print("点击: \(product.identifier)")
        
        default:
            break
        }
    }
}

extension PrestamoViewController
{
    private func updateBottomState() {
        let hasSelection = !viewModel.selectedProductsMap.isEmpty
        
        if self.isShowBottomButtonContainer != hasSelection {
            self.isShowBottomButtonContainer = hasSelection
        }
    }
    
    private func updateFirstLoanBottom() {
        let hasSelection = !viewModel.firstLoanMap.isEmpty
        
        // Evitar re-configurar si el estado no ha cambiado
        guard isShowBottomButtonContainer != hasSelection else { return }
        self.isShowBottomButtonContainer = hasSelection
        
        if hasSelection {
            setupBottomContainer()
        }
    }
    
    private func setupBottomContainer() {
        privacyTermsView.onPrivacyTerms = {
            // push to web view 
        }
        let style = BottomButtonStyle.customContentView(
            primaryTitle: "Someter",
            topContentView: privacyTermsView,
            bottomContentView: nil
        ) { [weak self] in
            guard let self = self, self.privacyTermsView.isAccepted else {
                // Mostrar alerta de "Debe aceptar los términos"
                self?.showToast("Por favor lea y acepte nuestro Contrato de Préstamo.")
                return
            }
            self.viewModel.fetchComfirmToLoan { model in
                // push
                let vc = ConfirmLoanPageView(isFirstConfirm: model)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        bottomContainer.configure(with: style)
    }
    
    private func appIconName() -> UIView {
        let view = UIView()
        
        // 1. 初始化 ImageView
        let imageView = UIImageView()
        imageView.image = UIImage(named: "acerca_me_icon")
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        
        let infoDict = Bundle.main.infoDictionary
        let appname = infoDict?["CFBundleDisplayName"] as? String ?? infoDict?["CFBundleName"] as? String
        // 2. 初始化 Label
        let titleLabel = UILabel()
        titleLabel.text = appname
        titleLabel.font = AppFontProvider.shared.getFont14Semibold()
        titleLabel.textColor = AppColorStyle.shared.backgroundWhite
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        
        // 4. 使用 SnapKit 处理约束
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(imageView)
        }
        return view
    }
    
}

extension PrestamoViewController: PrestamoDialogPresentable { }
