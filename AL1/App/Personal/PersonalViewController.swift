//
//  PersonalViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/12.
//

import UIKit

class PersonalViewController: BaseTableViewController {
    
    private lazy var viewModel = PersonalViewModel()
    private lazy var formItems: [any TableItemProtocol] = []
    
    private lazy var backgroundPagoView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "personal_pago_icon")
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTableViewTop(to: .viewTop, animated: false)
        view.backgroundColor = AppColorStyle.shared.backgroundLightGray
        bindViewModel()
        
        setupPullToRefresh()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.bar.alpha = 0
    }
    
    override func refresh() {
        
        viewModel.userInfo()
    }

    private func bindViewModel() {
        // 1. 订阅用户数据模型的变化
        viewModel.$userProfileModel
            .receive(on: RunLoop.main) // 确保在主线程处理 UI
            .sink { [weak self] model in
                guard let self = self, let model = model else { return }

                if let item = tableController?.sections.first?.filter({ row in
                    return row.item.identifier == HeaderProfile.reuseIdentifier
                }).first {
                    if var rowItem = item.item as? HeaderProfile {
                        rowItem.userProfile = model
                        updateData(with: rowItem, animated: false)
                    }
                }
                self.stopPullToRefresh()
                
                let isBankRow: (RowRepresentable) -> Bool = { row in
                    return row.item.identifier == UserProfileType.bankAccount.rawValue
                }
                if model.needsToSetBank {
                    let containBankRows = tableController?.containsRow(where: isBankRow)
                    if let contain = containBankRows, !contain {
                        let bankItem = UserProfile(identifier: UserProfileType.bankAccount.rawValue,
                                                   title: "Cuenta bancaria", icon: "personal_list_icon_2", position: .middle, type: .bankAccount)
                        
                        let targetPath = IndexPath(row: 2, section: 0)
                        
                        tableController?.insert(item: bankItem, at: targetPath, animation: .fade) { item in
                            return (item as! UserProfile).toRow { [weak self] selected in
                                self?.handleRowSelection(item: selected)
                            }
                        }
                    }
                } else {
                    tableController?.removeRow(where: isBankRow, animation: .fade)
                }
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.errorMsg
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                guard let self else { return }
                showToast(message)
            }
            .store(in: &viewModel.cancellables)
    }
    
    override func setupData() {
        self.formItems = [
            HeaderProfile(topInset: safeViewTopInset),
            UserProfile(identifier: UserProfileType.loanHistory.rawValue,
                        title: "historial de endeudamiento", icon: "personal_list_icon_1", position: .top, type: .loanHistory),
            UserProfile(identifier: UserProfileType.feedback.rawValue,
                        title: "Feedback", icon: "personal_list_icon_3", position: .middle, type: .feedback),
            UserProfile(identifier: UserProfileType.aboutUs.rawValue,
                        title: "Acerca de nosotros", icon: "personal_list_icon_4", position: .middle, type: .aboutUs),
            UserProfile(identifier: UserProfileType.privacy.rawValue,
                        title: "Acuerdo", icon: "personal_list_icon_5", position: .middle, type: .privacy),
            UserProfile(identifier: UserProfileType.settings.rawValue,
                        title: "Configuración", icon: "personal_list_icon_6", position: .bottom, type: .settings),
        ]
        
        let rows: [RowRepresentable] = formItems.compactMap { item in
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { [weak self] selectedItem in
                    self?.handleRowSelection(item: selectedItem)
                })
            }
            return nil
        }
        reloadData(with: rows)
    }
}

extension PersonalViewController {
    // 统一处理点击事件
    private func handleRowSelection(item: Any) {
        switch item {
        case let item as UserProfile:
            handleFormSelection(for: item)
        default:
            break
        }
    }
    
    private func handleFormSelection(for item: UserProfile) {
        switch item.type {
        case .loanHistory:
            let vc = LoanOrderViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .bankAccount:
            let vc = UserBankListViewController(entry: .personal)
            navigationController?.pushViewController(vc, animated: true)
        case .feedback:
            guard let userToken = UserSession.shared.token else {
                return
            }
            let feedbackURL = H5Url.feedback(token: userToken).urlString
            let vc = CommonWebViewController(url: feedbackURL)
            navigationController?.pushViewController(vc, animated: true)
        case .aboutUs:
            let vc = AcercaMePageView()
            navigationController?.pushViewController(vc, animated: true)
        case .settings:
            let vc = ConfigurarPageView()
            navigationController?.pushViewController(vc, animated: true)
        case .privacy:
            let vc = AcuerdoViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
