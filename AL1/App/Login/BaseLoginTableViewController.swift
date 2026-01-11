//
//  BaseLoginTableViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class BaseLoginTableViewController: BaseTableViewController {
    lazy var viewModel = LoginViewModel()
    lazy var privacyIsToggle = true
    
    // 提取共有的悬浮按钮
    private lazy var serviceButton: DragableButton = {
        let button = DragableButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button.autoDocking = true
        button.setImage(UIImage(named: "service_float_icon"), for: .normal)
        button.setImage(UIImage(named: "service_float_icon"), for: .highlighted)
        button.addTarget(self, action: #selector(serviceFloatAction), for: .touchUpInside)
        return button
    }()

    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        updateTableViewTop(to: .viewTop, animated: false)
        
        view.addSubview(serviceButton)
        serviceButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.size.equalTo(80)
        }
        setupBindings()
        viewModel.fetchServiceInfo { _ in
        }
        
        tableController?.onScroll = { [weak self] _ in
            guard let self else { return }
            view.endEditing(true)
        }
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.bar.alpha = 0
    }

    // 提取公共弹窗逻辑
    @objc func serviceFloatAction() {
        view.endEditing(true)
        viewModel.contactServiceClick { [weak self] items in
            guard let self else { return }
            showServiceDialog(with: items)
        }
    }
    
    // 子类实现具体绑定
    func setupBindings() {
        viewModel.bindAuthCodeFailure { [weak self] message in
            guard let self else { return }
            // handler toast
            showToast(message)
        }
    }
    
    // 统一的数据渲染辅助方法
    func renderSections(_ items: [LoginHeaderSection]) {
        let rows = items.map { item in
            ConcreteRow<LoginHeaderSection, LoginHeaderSectionCell>(item: item) { _ in }
        }
        reloadData(with: rows)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
