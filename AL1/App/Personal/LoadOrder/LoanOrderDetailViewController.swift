//
//  LoanOrderDetailViewController.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import UIKit

class LoanOrderDetailViewController: BaseTableViewController {
    let orderId: String
    private var viewModel: LoanOrderDetailViewModel
    init(orderId: String) {
        self.orderId = orderId
        viewModel = LoanOrderDetailViewModel(orderId: orderId)
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        navigation.item.title = "Detalles de orden"
        
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupPullToRefresh()
    }
    
    override func refresh() {
        viewModel.fetchOrderDetail()
    }
    
    func bindViewModel() {
        viewModel.$detailModel
            .compactMap { $0 }
            .sink { [weak self] detailModel in
                guard let self else { return }
                
                let items = viewModel.orderDetailSections(with: detailModel)
                setupFormData(with: items)
                
                stopPullToRefresh()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                guard let self else { return }
                showToast(message)
                stopPullToRefresh()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.onContactService = { [weak self] in
            guard let self else { return }
            serviceAction()
        }
    }
    
}

extension LoanOrderDetailViewController {

    func setupFormData(with items: [any TableItemProtocol]) {
        let rows: [RowRepresentable] = items.compactMap { item in
            // 如果 Model 遵循了转换协议，则调用其转换方法
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { [weak self] selectedItem in
//                    self?.handleRowSelection(item: selectedItem)
                })
            }
            return nil
        }
        reloadData(with: rows)
    }
}
