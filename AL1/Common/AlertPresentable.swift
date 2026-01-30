//
//  AlertPresentable.swift
//  AL1
//
//  Created by cashlee on 2026/1/27.
//

import UIKit

import UIKit

protocol AlertPresentable {
    func showPermissionAlert(title: String, message: String, cancelHandler: (() -> Void)?)
}

extension AlertPresentable where Self: UIViewController {
    /// 通用的权限引导弹窗
    func showPermissionAlert(title: String, message: String = "", cancelHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // 跳转设置
        alert.addAction(UIAlertAction(title: "Configuración", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        // 取消或返回
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            cancelHandler?()
        })
        self.present(alert, animated: true)
    }
}
