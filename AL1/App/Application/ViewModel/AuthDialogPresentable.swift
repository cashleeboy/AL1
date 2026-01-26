//
//  AuthDialogPresentable.swift
//  AL1
//
//  Created by cashlee on 2025/12/24.
//

import UIKit
import SwiftEntryKit

enum PhotoSource {
    case camera
    case gallery
}

protocol AuthDialogPresentable {
    func showContactPermissionAlert(viewController toPresent: UIViewController)
    func showPermissionAlert(for type: PermissionType, viewControllerToPresent: UIViewController)
    
    func showCCIDialog()
    func showTwoDialog(with action: @escaping () -> Void)
    func showUploadPhotoSheet(completion: @escaping (PhotoSource) -> Void)
    func showRecognizeSheet(onTryAgain: @escaping (() -> Void))
    
    func showPickerSheet(delegate: MZPickerControllerDelegate,
                         dataSource: MZPickerControllerDataSource,
                         nameTitle: String,
                         confirmTitle: String,
                         selectedRows: [Int]?
    )
    // Date of birth
    func showDateSheet(onDoneHandler: @escaping ((Date) -> Void))
    func showBankSheet(wiht list: [BankItem], onSelected: @escaping ((BankModel) -> Void))

    func dismiss()
}

extension AuthDialogPresentable where Self: UIViewController
{
    func showContactPermissionAlert(viewController toPresent: UIViewController) {
        let title = "Permiso de Contactos"
        let message = "Para seleccionar un contacto de emergencia, necesitamos acceder a su libreta de direcciones. Por favor, actívelo en la configuración."
        let cancelTitle = "Cancelar"
        let settingsTitle = "Configuración"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: settingsTitle, style: .default) { _ in
            PermissionsManager.shared.openSettings()
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        toPresent.present(alert, animated: true, completion: nil)
    }
    
    func showPermissionAlert(for type: PermissionType, viewControllerToPresent: UIViewController) {
        let message = type == .camera ? "Requerimos acceso a su cámara para continuar." : "Requerimos acceso a su galería."
        
        // 这里可以使用你项目通用的 Alert 弹窗
        let alert = UIAlertController(title: "Permiso denegado", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Configuración", style: .default) { _ in
            PermissionsManager.shared.openSettings()
        })
        viewControllerToPresent.present(alert, animated: true)
    }
    
    func showCCIDialog() {
        let dialog = SimpleInfoDialog()
        
        let steps = [
            "Abra la aplicación bancaria correspondiente en su teléfono.",
            "Entrar en cuenta",
            "Encontrar CCI (20 dígitos)",
            "Haga clic para copiar y obtener"
        ]
        let styledInstructions = NSMutableAttributedString.makeStepInstructions(
            steps: steps,
            boldKeywords: [],
            font: AppFontProvider.shared.getFont12Regular(),
            boldFont: AppFontProvider.shared.getFont12Regular(),
            color: UIColor(hex: "#929292"),
            lineSpacing: 10.0
        )
        
        dialog.configure(title: "Obtener CCI rápidamente", message: styledInstructions, buttonTitle: "Entendido") {
            SwiftEntryKit.dismiss()
        } onCancelAction: {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    func showInformation(with title: String, items: [ConfirmItem], modificar: @escaping (() -> Void)) {
        let dialog = InformationConfirmDialog()

        dialog.configure(
            title: title, //"Verifique su información bancaria",
            items: items,
            secondaryTitle: "Modificar",
            primaryTitle: "Confirmar"
        )
        // 设置点击逻辑
        dialog.primaryAction = {
            SwiftEntryKit.dismiss()
            modificar()
        }
        dialog.secondaryAction = {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    
    func showTwoDialog(with action: @escaping () -> Void) {
        let dialog = TwoButtonDialog()
        dialog.configure(
            title: "Los fondos han sido preparados para usted, ¿está seguro de abandonar?",
            message: nil,
            imageName: "dialog_retain_icon"
        )
        dialog.primaryAction = {
            SwiftEntryKit.dismiss()
        }
        dialog.secondaryAction = {
            SwiftEntryKit.dismiss()
            action()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    func showRewardDialog(with completion: @escaping (() -> Void)) {
        let dialog = RewardFillingDialog()
        dialog.configure(
            title: "¡Felicidades! Inicio\n de sesión exitoso.",
            content: "Ahora, al solicitar, tiene la oportunidad de obtener un límite más alto; ¡ve a solicitarlo ahora mismo!",
            primaryTitle: "Solicitar con un solo clic"
        )
        dialog.primaryAction = {
            SwiftEntryKit.dismiss()
            completion()
        }
        dialog.cancelAction = {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    func dismiss() {
        SwiftEntryKit.dismiss()
    }
}

extension AuthDialogPresentable {
    
    func showUploadPhotoSheet(completion: @escaping (PhotoSource) -> Void) {
        let sheet = PhotoUploadSheet(CGRectMake(0, 0, UIScreen.main.bounds.width, 0)) {
            SwiftEntryKit.dismiss()
        }
        sheet.cameraHandler = {
            // TODO: fetch access
            
            completion(.camera)
        }
        sheet.galleryHandler = {
            // TODO: fetch access
            
            completion(.gallery)
        }
        
        let size = sheet.calculateFittingSize()
        let attributes = EKAttributes.bottomSheet(size.height)
        SwiftEntryKit.display(entry: sheet, using: attributes, presentInsideKeyWindow: true)
    }
    
    func showRecognizeSheet(onTryAgain: @escaping (() -> Void)) {
        let recognizeSheet = IdentifyRecognizeSheet {
            SwiftEntryKit.dismiss()
        }
        recognizeSheet.primaryHandler = {
            SwiftEntryKit.dismiss()
            onTryAgain()
        }
        let attributes = EKAttributes.bottomSheet(recognizeSheet.calculateFittingSize().height)
        SwiftEntryKit.display(entry: recognizeSheet, using: attributes, presentInsideKeyWindow: true)
    }
    
    func showPickerSheet(delegate: MZPickerControllerDelegate,
                         dataSource: MZPickerControllerDataSource,
                         nameTitle: String,
                         confirmTitle: String,
                         selectedRows: [Int]?,
    ) {
        let picker = MZPickerController()
        picker.nameTitle = nameTitle
        picker.cancelImage = UIImage(named: "dialog_cancel_icon")
        picker.confirmTitle = confirmTitle
        picker.delegate = delegate
        picker.dataSource = dataSource
        picker.onDismiss = {
            SwiftEntryKit.dismiss()
        }
        if let rows = selectedRows, !rows.isEmpty {
            picker.selectRows(rows)
        }
        let attributes = EKAttributes.bottomSheet(310 + MZPickerView_SAFE_BOTTOM)
        SwiftEntryKit.display(entry: picker, using: attributes)
    }
    
    // Date of birth
    func showDateSheet(onDoneHandler: @escaping ((Date) -> Void)) {
        let date = MZDatePickerView(frame: CGRectMake(0, 0, 0, MZDatePickerView.defaultHeight))
//        date.canSelectFutureDate = false
        date.doneHandler = { date in
            onDoneHandler(date)
            SwiftEntryKit.dismiss()
        }
        date.cancelHandler = {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.bottomSheet(MZDatePickerView.defaultHeight)
        SwiftEntryKit.display(entry: date, using: attributes)
    }
    
    func showBankSheet(wiht list: [BankItem], onSelected: @escaping ((BankModel) -> Void)) {
        let sheet = BankTableSheet(CGRect(x: 0, y: 0, width: NavigationUtility.windowWidth, height: 0)) {
            SwiftEntryKit.dismiss()
        }
        sheet.onSelected = { bank in
            onSelected(bank)
            SwiftEntryKit.dismiss()
        }
        let banks = list.compactMap { item -> BankModel in
            BankModel(id: item.id, name: item.bankName)
        }
        sheet.updateData(banks: banks)
        let attributes = EKAttributes.bottomSheet(sheet.calculateFittingSize().height)
        SwiftEntryKit.display(entry: sheet, using: attributes, presentInsideKeyWindow: true)
    }
    
}

//extension BaseApplyViewController: AuthDialogPresentable { }
