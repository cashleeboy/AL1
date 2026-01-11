//
//  AppRootSwitcher.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import UIKit

struct AppRootSwitcher {
    /// 切换到主界面 (登录成功后调用)
    /// 切换到主界面
    /// - Parameter pushVC: 切换后需要立即 push 的控制器（可选）
    static func switchToMain(withPushVC pushVC: UIViewController? = nil) {
        let tabBarVC = ALTabBarViewController()
        
        updateRoot(to: tabBarVC, animation: .transitionCrossDissolve) {
            // 确保动画完成后执行
            guard let pushVC = pushVC else { return }
            
            // 安全寻找当前选中的导航控制器
            if let nav = tabBarVC.selectedViewController as? UINavigationController {
                nav.pushViewController(pushVC, animated: true)
            } else if let firstNav = tabBarVC.viewControllers?.first as? UINavigationController {
                // 如果 selectedViewController 为空，尝试第一个
                firstNav.pushViewController(pushVC, animated: true)
            }
        }
    }
    
    /// 切换到登录界面 (初始化或退出登录调用)
    static func switchToLogin() {
        let loginVC = LoginViewController()
        let nav = ALNavViewController(rootViewController: loginVC)
        updateRoot(to: nav, animation: .transitionFlipFromRight)
    }
    
    private static func updateRoot(to vc: UIViewController,
                                   animation: UIView.AnimationOptions,
                                   completion: (() -> Void)? = nil) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        UIView.transition(with: window, duration: 0.5, options: animation, animations: {
            // 建议：在替换前清除旧的视图层级，防止某些特定 SDK 的视图残留
            window.rootViewController = vc
        }) { _ in
            completion?()
        }
        
        window.makeKeyAndVisible()
    }
}
