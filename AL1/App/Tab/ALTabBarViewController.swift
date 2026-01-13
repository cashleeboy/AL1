//
//  ALTabBarViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/12.
//

import UIKit
import SwiftEntryKit

class ALTabBarViewController: UITabBarController {
    private static var isAlreadyKickedOut = false // 使用静态变量防止多个实例竞争
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self // 必须设置代理
        tabBar.tintColor = AppColorStyle.shared.brandPrimary
        tabBar.unselectedItemTintColor = AppColorStyle.shared.textGrayD9
        
        setupViewControllers()
        // 在某个全局管理类或 RootViewController 中
        NotificationCenter.default.addObserver(forName: .unauthorizedAccess, object: nil, queue: .main) { [self] _ in
            showLoginScreen()
        }
        // 1. 先移除旧的监听，确保唯一性
        NotificationCenter.default.removeObserver(self, name: .sessionKickedOut, object: nil)
        // 2. 添加监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleKickedOut), name: .sessionKickedOut, object: nil)
        
        NotificationCenter.default.addObserver(forName: .jumpToTabbarController, object: nil, queue: .main) { [self] notification in
            if let index = notification.object as? Int {
                jumpToVC(with: index)
                if let selectedNav = selectedViewController as? UINavigationController {
                    selectedNav.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .unauthorizedAccess, object: nil)
        NotificationCenter.default.removeObserver(self, name: .sessionKickedOut, object: nil)
    }
}


// MARK: - UITabBarControllerDelegate
extension ALTabBarViewController: UITabBarControllerDelegate
{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        // 2. 定义哪些页面需要登录（例如：首页 index 0 不需要，个人中心 index 1 需要）
        let protectedIndices = [1, 2]
        
        if protectedIndices.contains(index) {
            if !UserSession.shared.isLoggedIn {
                showLoginScreen()
                return false
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 这里可以处理选中后的震动反馈或埋点
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

extension ALTabBarViewController
{
    private func setupViewControllers() {
        let prestamoVC = PrestamoViewController()
        let reembolsoVC = ReembolsoViewController()
        let personalVC = PersonalViewController()
        
        let nav1 = createNavController(
            for: prestamoVC,
            title: "Préstamo",
            imageName: "tab_banknote_fill"
        )
        
        let nav2 = createNavController(
            for: reembolsoVC,
            title: "Reembolso",
            imageName: "tab_dollarsign_fill"
        )
        
        let nav3 = createNavController(
            for: personalVC,
            title: "Personal",
            imageName: "tab_person_fill"
        )

        self.viewControllers = [nav1, nav2, nav3]
    }
    
    // 辅助方法：创建并配置导航控制器和 TabBarItem
    private func createNavController(for rootViewController: UIViewController, title: String, imageName: String,
                                     selectedColor: UIColor = AppColorStyle.shared.brandPrimary,
                                     unselectedColor: UIColor = AppColorStyle.shared.textGrayD9) -> ALNavViewController
    {
        let navController = ALNavViewController(rootViewController: rootViewController)
        navController.navigation.configuration.isEnabled = true
        navController.navigation.bar.isTranslucent = true
        navController.navigation.bar.shadowImage = UIImage()
        navController.navigation.configuration.isShadowHidden = true
        navController.navigation.configuration.tintColor = .clear
        
        let tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate),
            tag: 0
        )
        let itemFont = AppFontProvider.shared.getFont14Regular()
        
        let unselectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: unselectedColor,
            .font: itemFont
        ]
        tabBarItem.setTitleTextAttributes(unselectedTextAttributes, for: .normal)

        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedColor,
            .font: itemFont
        ]
        tabBarItem.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        navController.tabBarItem = tabBarItem
        return navController
    }
}

extension ALTabBarViewController
{
    func showLoginScreen() {
        if let root = NavigationUtility.keyWindow?.rootViewController as? ALTabBarViewController,
            let nav = root.selectedViewController as? ALNavViewController {
            let loginVC = LoginViewController()
            nav.pushViewController(loginVC, animated: true)
        }
    }
    
    @objc func handleKickedOut() {
        guard !ALTabBarViewController.isAlreadyKickedOut else { return }
        ALTabBarViewController.isAlreadyKickedOut = true

        print("*** 处理被踢下线逻辑 ***")
        UserSession.shared.clear()

        // show dialog
        dataExpirationDialog { [weak self] in
            guard let self else { return }
            ALTabBarViewController.isAlreadyKickedOut = false
            // push to login page
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.showLoginScreen()
            }
        }
    }
    
    func jumpToVC(with idx: Int) {
        selectedIndex = idx
    }
}


extension ALTabBarViewController {
    // 数据过期弹窗
    func dataExpirationDialog(with completion: @escaping (() -> Void)) {
        let dialog = SimpleInfoDialog()
        dialog.configure(title: "Consejos amables", message: "Ya hay un pedido en curso para el producto actual, no repita la operación", buttonTitle: "Confirmar", action: {
            SwiftEntryKit.dismiss()
            completion()
        }, showCancelButton: true) {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
}
