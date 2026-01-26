//
//  AcuerdoViewController.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//


import UIKit
import SwiftEntryKit

class AcuerdoViewController: BaseTableViewController
{
    private lazy var viewModel = PersonalViewModel()
    
    private var formItems: [any TableItemProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.backgroundWhiteF2
        tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        isShowBottomButtonContainer = false
        
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
        
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = "Acuerdo"
        navigation.bar.alpha = 1
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal), for: .top, barMetrics: .default)
    }
     
    override func setupData() {
        formItems = [
            ConfigurarSelectionModel(type: .Política, onContainerTap: { [weak self] in
                guard let self else { return }
                let url = H5Url.privacyPolicy.urlString
                let vc = CommonWebViewController(url: url)
                navigationController?.pushViewController(vc, animated: true)
            }),
            ConfigurarSelectionModel(type: .Condiciones, onContainerTap: {
                
            }),
            ConfigurarSelectionModel(type: .Contrato, onContainerTap: {
                
            }),
        ]
        
        let rows: [RowRepresentable] = formItems.compactMap { item in
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { _ in
                })
            }
            return nil
        }
        reloadData(with: rows)
    }
}
