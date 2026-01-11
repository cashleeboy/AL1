//
//  ReembolsoBasePage.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import UIKit
import Combine

/// 借款列表基础页面类，处理共有逻辑
class ReembolsoBasePage: BaseTableViewController, JYPageChildContollerProtocol {
    
    lazy var viewModel = ReembolsoBaseViewModel()
    
    // 暴露一个用于观察数量的 Publisher
    var itemCountPublisher: AnyPublisher<Int, Never> {
        viewModel.$items
            .map { $0.count }
            .eraseToAnyPublisher()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPullToRefresh()
    }

    override func viewDidLoad() {
        emptyStateConfig = .noRepay
        super.viewDidLoad()
        
        view.backgroundColor = AppColorStyle.shared.backgroundWhiteF2
        tableView.register(ReembolsoBaseTableViewCell.self, forCellReuseIdentifier: ReembolsoBaseTableViewCell.baseIdentifier)
        setupBinding()
        
        setupPullToRefresh(to: false)
    }
    
    override func refresh() {
        loadData()
    }
    
    func loadData() {
        self.dataSources = []
        tableView.reloadData()
    }
    
    func setupBinding() {
        viewModel.$items
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self else { return }
                dataSources = items
                stopPullToRefresh()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { isLoading in
                
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                self?.showToast(msg)
                self?.stopPullToRefresh()
            }
            .store(in: &viewModel.cancellables)
    }
    
    override func configureBottomButton() {
        let style = BottomButtonStyle.primaryOnly(title: "Pago con un clic") { [weak self] in
            guard let self else { return }
            clicAction()
        }
        bottomContainer.configure(with: style)
    }
    
    override func handleEmptyStateAction(for config: EmptyStateConfig) {
        switch config {
        case .noRepay:
            startPullToRefresh()
        default:
            break
        }
    }
    
    func clicAction() {
        
    }
}

extension ReembolsoBasePage {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReembolsoBaseTableViewCell.baseIdentifier,
            for: indexPath
        ) as? ReembolsoBaseTableViewCell else {
            return UITableViewCell()
        }
        
        if let model = dataSources[indexPath.row] as? OrderListItem {
            cell.configure(with: model) { [weak self] toggle in
                guard let self else { return }
                viewModel.setupToggleProduct(with: indexPath.row, result: toggle)
                isShowBottomButtonContainer = viewModel.isShowBottomBtn()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSources[indexPath.row] as? OrderListItem {
            let vc = LoanOrderDetailViewController(orderId: item.appOrderId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
