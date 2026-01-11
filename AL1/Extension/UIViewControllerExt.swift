//
//  UIViewControllerExt.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit
import Toast
import SwiftEntryKit

extension UIViewController {
    
    /// 统一配置导航栏右侧客服按钮
    func setupServiceNavigationItem() {
        navigation.item.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "nav_service_item_icon")?.withRenderingMode(.alwaysOriginal),
            style: .plain, target: self, action: #selector(serviceAction))
    }
    
    /// 在 Extension 中提供一个默认的 serviceAction 实现（可选）
    /// 如果子类有特殊需求，直接在子类中使用 @objc func serviceAction() 重写即可
    @objc func serviceAction() {
        // 可以在这里统一调用你的 IdentityRouter 或者弹出对话框逻辑
        // 例如：IdentityRouter.shared.showServiceDialog(items: ...)
        print("*** 点击了客服按钮")
    }
    
    
    func showServiceDialog(with items: [ServiceInquiryItem]) {
        let finalItems = items.filter { item in
            !item.content.isEmpty
        }
        let dialog = ServiceContactDialog {
            SwiftEntryKit.dismiss()
        }
        dialog.configure(title: "Servicio al Cliente", items: finalItems)
        dialog.callServiceAction = { [weak self] item in
            guard let self else { return }
            SwiftEntryKit.dismiss()
            handleServiceAction(type: item.inquiryTypes.first, content: item.content)
            // 处理拨打或跳转逻辑...
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    // 统一处理客服跳转逻辑
    private func handleServiceAction(type: ServiceInquiryType?, content: String) {
        switch type {
        case .phone:
            if let url = URL(string: "tel://\(content)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            break
        case .whatsapp:
            let cleanNumber = content.filter { "0123456789".contains($0) }
            if let url = URL(string: "https://wa.me/\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            break
        case .email:
            UIPasteboard.general.string = content
            showToast("Dirección de correo copiada con éxito")
            break
        case .none:
            break
        }
    }
}

extension UIViewController {
    /// 专门处理业务错误的 Toast
    func showToast(_ message: String?) {
        // 确保在主线程弹出
        DispatchQueue.main.async { [self] in
            // toast with a specific duration and position
            view.makeToast(message, duration: 3.0, position: .center)
        }
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        // 1. 处理 Modal 弹出
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        // 2. 处理 UINavigationController
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        // 3. 处理 UITabBarController
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        // 4. 返回自身
        return self
    }
}
