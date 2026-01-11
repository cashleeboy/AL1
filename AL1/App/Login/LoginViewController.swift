//
//  LoginViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/12.
//

import UIKit
import SwiftEntryKit

class LoginViewController: BaseLoginTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setupBindings() {
        // 1. 监听成功回调
        viewModel.$authCodeModel
            .compactMap { $0 } // 过滤掉 nil
            .sink { [weak self] model in
                guard let self else { return }
                view.endEditing(true)
                
                let vc = AuthCodeViewController(viewModel: viewModel)
                navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &viewModel.cancellables)
        
        // 2. 监听失败回调
        viewModel.$authCodeFailure
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self else { return }
                showToast(error.message)
            }
            .store(in: &viewModel.cancellables)
    }
    
    override func setupData() {
        let section = LoginHeaderSection(
            state: .normal,
            isShowLoginButton: false,
            fetchAuthAction: { [weak self] in
                guard let self else { return }
                view.endEditing(true)
                guard privacyIsToggle == true else {
                    showToast("Primero seleccione y acepte nuestra política de privacidad.")
                    return
                }
                viewModel.sendAuthCode()
            },
            textFieldOnEdit: { [weak self] text in
                guard let self else { return }
                viewModel.phone = text
                if text.count >= 9 {
                    guard privacyIsToggle == true else {
                        showToast("Primero seleccione y acepte nuestra política de privacidad.")
                        return
                    }
                    viewModel.sendAuthCode()
                }
            }) { errorMsg in
                
            } privacyAction: { [weak self] in
                guard let self else { return }
                view.endEditing(true)
                let url = H5Url.privacyPolicy.urlString
                let vc = CommonWebViewController(url: url)
                navigationController?.pushViewController(vc, animated: true)
            } privacyToggleAction: { [weak self] toggle in
                guard let self else { return }
                privacyIsToggle = toggle
            }
        renderSections([section])
    }
    
}
