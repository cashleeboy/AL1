//
//  PrestamoDialogPresentable.swift
//  AL1
//
//  Created by cashlee on 2026/1/5.
//

import UIKit
import SwiftEntryKit

protocol PrestamoDialogPresentable {
    // service fee
    func showServiceFeeDialog(with title: String, titles: [String], values: [String], showSecondaryButton: Bool)
}

extension PrestamoDialogPresentable where Self: UIViewController
{

    func showServiceFeeDialog(with title: String, titles: [String], values: [String], showSecondaryButton: Bool) {

        let dialog = ServiceFeeDialog(title: title, titles: titles, values: values)
        dialog.primaryAction = {
            SwiftEntryKit.dismiss()
        }
        dialog.cancelAction = {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    // 数据过期弹窗
    func dataExpirationDialog(with completion: @escaping (() -> Void)) {
        let dialog = SimpleInfoDialog()
        dialog.configure(title: "pista", message: "Los datos han caducado. Vuelva a subir los datos y vuelva a evaluarlos.", buttonTitle: "Confirmar", action: {
            SwiftEntryKit.dismiss()
            completion()
        }, showCancelButton: true) {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
}
