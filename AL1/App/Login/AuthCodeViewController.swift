//
//  AuthCodeViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class AuthCodeViewController: BaseLoginTableViewController {

    init(viewModel: LoginViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func setupBindings() {
        super.setupBindings()
        
        viewModel.bindLoginStatus {
            AppRootSwitcher.switchToMain()
        }
    }
    
    override func setupData()
    {
        let section = LoginHeaderSection(
            state: .countdown(countDown: viewModel.authCodeModel?.expireTime),
            isShowLoginButton: true,
            areaCode: viewModel.areaCode,
            phoneNumber: viewModel.phone,
            inputMaxCount: 4,
            iniciarSesionAction: { [weak self] in
                guard let self else { return }
                view.endEditing(true)
                guard privacyIsToggle == true else {
                    showToast("Primero seleccione y acepte nuestra política de privacidad.")
                    return
                }
                viewModel.loginRequest()
            },
            fetchAuthAction: { [weak self] in
                self?.viewModel.sendAuthCode()
            },
            textFieldOnEdit: { [weak self] text in
                self?.viewModel.auth = text
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
