//
//  ConfirmLoanPageView.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//

import UIKit

class ConfirmLoanPageView: BaseTableViewController {
    var isFirstConfirm: Bool
    
    init(isFirstConfirm: Bool) {
        self.isFirstConfirm = isFirstConfirm
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var viewModel = ConfirmLoanViewModel()
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.bar.titleTextAttributes = [
            .foregroundColor : AppColorStyle.shared.backgroundWhite
        ]
        navigation.bar.tintColor = .white
        navigation.item.title = "Confirmar préstamo"
        
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
    
    override func configureBottomButton() {
        let style = BottomButtonStyle.primaryOnly(title: viewModel.bottomTitle) { [weak self] in
            guard let self else { return }
            
        }
        bottomContainer.configure(with: style)
    }
    
    override func refresh() {
        bindViewModel()
    }
    
    override func handleEmptyStateAction(for config: EmptyStateConfig) {
        switch config {
        case .imageTitleMessage(_, _, _, _):
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FFF9F5")
        updateTableViewTop(to: .safeArea, animated: false)
        isShowBottomButtonContainer = true
        
        bindPublished()
        
        setupPullToRefresh()
        
        if isFirstConfirm {
            viewModel.showRatingIfNeeded()
        }
    }
    
    func bindPublished() {
        viewModel.$errorMessage
            .dropFirst()
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                guard let self else { return }
                showToast(msg)
                stopPullToRefresh()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$applyModel
            .dropFirst()
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] model in
                guard let self else { return }
                stopPullToRefresh()
//                if model.someStatus {
//                    let list = viewModel.buildLoanSections()
//                    setupFormData(with: list)
//                } else {
                    emptyStateConfig = .imageTitleMessage(image: UIImage(named: "empty_funding_right"),
                                                          title: "Aplicación exitosa",
                                                          message: "Hemos recibido su solicitud de préstamo y la estamos revisando... Por favor espere.",
                                                          buttonTitle: "Volver")
                    reloadData(with: [])
//                }
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$selectedProductsMap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] map in
                guard let self else { return }
                updateBottomState()
            }
            .store(in: &viewModel.cancellables)
        
    }
    
    func bindViewModel() {
        viewModel.fetchApply()
    }
    
    
    func setupFormData(with items: [any TableItemProtocol]?) {
        guard let items else { return }
        //PrestamoProductCardItem(topInset: safeViewTopInset + 20),
        // 核心逻辑：利用协议自动转换，无需关心具体的 Model 类型
        let rows: [RowRepresentable] = items.compactMap { item in
            // 如果 Model 遵循了转换协议，则调用其转换方法
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { [weak self] selectedItem in
                    
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
    
}

extension ConfirmLoanPageView {
    private func updateBottomState() {
        let hasSelection = !viewModel.selectedProductsMap.isEmpty
        
        if self.isShowBottomButtonContainer != hasSelection {
            self.isShowBottomButtonContainer = hasSelection
        }
        let count = viewModel.selectedProductsMap.count
        print("*** count = \(viewModel.selectedProductsMap)")
        let title = "Solicitar \(viewModel.selectedProductsMap.count) producto con un clic"
        viewModel.bottomTitle = title
        
        let style = BottomButtonStyle.primaryOnly(title: viewModel.bottomTitle) { [weak self] in
            guard let self else { return }
            
        }
        bottomContainer.configure(with: style)
    }
}
