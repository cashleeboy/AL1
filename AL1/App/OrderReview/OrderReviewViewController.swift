//
//  OrderReviewViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/23.
//

import UIKit

class OrderReviewViewController: BaseTableViewController {
    private var formItems: [any TableItemProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        
        updateTableViewTop(to: .safeArea, animated: false)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = "Detalles de orden"
        
        navigation.bar.alpha = 1
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
        
        
        navigation.bar.backBarButtonItem?.shouldBack = { [weak self] item in
            guard let self else { return false }
            navigationController?.popToRootViewController(animated: true)
            return false
        }
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
    
    override func setupData() {
        super.setupData()
        
        formItems = [
            OrderReviewItem(contactarHandler: {
                //
            }),
        ]
        
        var rows: [RowRepresentable] = []
        for item in formItems {
            if let temp = item as? OrderReviewItem {
                let row = ConcreteRow<OrderReviewItem, OrderReviewCell>(
                    item: temp
                ) { selectedItem in
                    
                }
                rows.append(row)
            }
        }
        reloadData(with: rows)
    }
    
}



