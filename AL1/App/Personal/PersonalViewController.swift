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
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
//                    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                }
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
            UserProfile(title: "historial de endeudamiento", icon: "personal_list_icon_1", position: .top, type: .loanHistory),
            UserProfile(title: "Cuenta bancaria", icon: "personal_list_icon_2", position: .middle, type: .bankAccount),
            UserProfile(title: "Feedback", icon: "personal_list_icon_3", position: .middle, type: .feedback),
            UserProfile(title: "Acerca de nosotros", icon: "personal_list_icon_4", position: .middle, type: .aboutUs),
            UserProfile(title: "Política de Privacidad", icon: "personal_list_icon_5", position: .middle, type: .privacy),
            UserProfile(title: "Configuración", icon: "personal_list_icon_6", position: .bottom, type: .settings),
        ]
        
        let rows: [RowRepresentable] = formItems.compactMap { item in
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { [weak self] selectedItem in
                    self?.handleRowSelection(item: selectedItem)
                })
            }
            return nil
//            switch item {
//            case let homeItem as UserProfile:
//                return ConcreteRow<UserProfile, ProfileHeaderSelectionView>(item: homeItem) { _ in
//                    // 具体的业务跳转
//                }
//            default:
//            }
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
            let url = H5Url.privacyPolicy.urlString
            let vc = CommonWebViewController(url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
