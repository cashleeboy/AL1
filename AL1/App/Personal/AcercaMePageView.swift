//
//  AcercaMePageView.swift
//  AL1
//
//  Created by cashlee on 2025/12/25.
//

import UIKit

class AcercaMePageView: BaseTableViewController
{
    private var formItems: [any TableItemProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
        
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = "Acerca de nosotros"
        navigation.bar.alpha = 1
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal), for: .top, barMetrics: .default)
    }
    
    override func setupData() {
        let infoDict = Bundle.main.infoDictionary
        let version = infoDict?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let appname = infoDict?["CFBundleDisplayName"] as? String ?? infoDict?["CFBundleName"] as? String
        
        formItems = [
            AcercaMeSelectionModel(appname: appname, appversion: version)
        ]
        
        let rows: [RowRepresentable] = formItems.compactMap { item in
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { [weak self] selectedItem in

                })
            }
            return nil
        }
        reloadData(with: rows)
    }
}



