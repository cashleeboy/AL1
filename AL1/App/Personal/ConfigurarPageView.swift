//
//  ConfigurarPageView.swift
//  AL1
//
//  Created by cashlee on 2025/12/25.
//

import UIKit
import SwiftEntryKit

class ConfigurarPageView: BaseTableViewController
{
    private lazy var viewModel = PersonalViewModel()
    
    private var formItems: [any TableItemProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.backgroundWhiteF2
        tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)

        isShowBottomButtonContainer = true
        // 在 setupBindings 或 viewDidLoad 中
        viewModel.$isLogout
            .filter { $0 }
            .sink { _ in
                // 创建登录页
                let loginVC = LoginViewController()
                // 执行切换并 Push
                AppRootSwitcher.switchToMain(withPushVC: loginVC)
            }
            .store(in: &viewModel.cancellables)

        viewModel.$isAccountCancel
            .filter { $0 }
            .sink { _ in
                AppRootSwitcher.switchToMain()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.errorMsg
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                self?.showToast(msg)
            }
            .store(in: &viewModel.cancellables)
        
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
        
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = "configurar"
        navigation.bar.alpha = 1
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal), for: .top, barMetrics: .default)
    }
    
    override func configureBottomButton() {
        let style = BottomButtonStyle.primaryOnly(title: "cerrar la sesión") { [weak self] in
            guard let self else { return }
            showLogoutDialog {
                self.viewModel.logout()
            }
        }
        bottomContainer.setPrimaryState(isEnable: true, enableColor: UIColor(hex: "#CACACA"))
        bottomContainer.backgroundColor = AppColorStyle.shared.backgroundWhiteF2
        bottomContainer.configure(with: style)
    }
    
    override func setupData() {
        formItems = [
            ConfigurarSelectionModel(type: .cache, onContainerTap: { [weak self] in
                guard let self else { return }
                // cache dialog
                showCacheDialog {
                    self.showToast("Datos borrados correctamente")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        let loginVC = LoginViewController()
                        // 执行切换并 Push
                        AppRootSwitcher.switchToMain(withPushVC: loginVC)
                    }
                }
            }),
            ConfigurarSelectionModel(type: .version, onContainerTap: {
                
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


extension ConfigurarPageView {
    func showLogoutDialog(with title: String = "¿Está seguro de que desea cerrar la sesión?", onLogout: @escaping (() -> Void)) {
        let dialog = TwoButtonDialog()
        dialog.configure(
            title: title,
            message: nil,
            imageName: nil,
            primaryTitle: "No",
            secondaryTitle: "Sí"
        )
        dialog.primaryAction = {
            SwiftEntryKit.dismiss()
        }
        dialog.secondaryAction = {
            SwiftEntryKit.dismiss()
            onLogout()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    func showCacheDialog(with completion: @escaping (() -> Void)) {
        let dialog = SimpleInfoDialog()
        dialog.configure(title: "Consejos amables",
                         message: "Borraremos todos sus datos y cancelaremos su cuenta ¿Quiere confirmar?",
                         buttonTitle: "Sí") { [weak self] in
            
            guard let self else { return }
            viewModel.clearCache {
                completion()
            }
            SwiftEntryKit.dismiss()
        } onCancelAction: {
            SwiftEntryKit.dismiss()
        }
        
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
}
