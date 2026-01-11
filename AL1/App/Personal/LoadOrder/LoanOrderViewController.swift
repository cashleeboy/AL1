//
//  LoanOrderViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit

class LoanOrderViewController: BaseTableViewController {
    
    private lazy var viewModel = LoanOrderViewModel()
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        navigation.item.title = "orden de préstamo"
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
    }
    
    override func handleEmptyStateAction(for config: EmptyStateConfig) {
        switch config {
        case .noPrdido:
            NotificationCenter.default.post(name: .jumpToTabbarController, object: 0)
            self.navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        emptyStateConfig = .noPrdido
        super.viewDidLoad()
        updateTableViewTop(to: .safeArea, animated: false)
        view.backgroundColor = AppColorStyle.shared.backgroundWhiteF2
        tableView.register(LoanOrderTableViewCell.self, forCellReuseIdentifier: LoanOrderTableViewCell.baseIdentifier)
        
        viewModel.$errorMessage
        .dropFirst()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] message in
            guard let self else { return }
            showToast(message)
            stopPullToRefresh()
        }
        .store(in: &viewModel.cancellables)
        
        viewModel.$orderList
        .receive(on: DispatchQueue.main)
        .sink { [weak self] items in
            guard let self, let items else { return }
            dataSources = items
            stopPullToRefresh()
        }
        .store(in: &viewModel.cancellables)
        
        DispatchQueue.main.async { [self] in
            setupPullToRefresh()
        }
    }
    
    override func refresh() {
        viewModel.fetchHistoryOrder()
    }
}

extension LoanOrderViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LoanOrderTableViewCell.baseIdentifier,
            for: indexPath
        ) as? LoanOrderTableViewCell else {
            return UITableViewCell()
        }
        
        if let item = dataSources[indexPath.row] as? OrderListItem {
            cell.configure(with: item)
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
