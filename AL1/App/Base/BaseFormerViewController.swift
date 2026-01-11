//
//  BaseFormerViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class BaseFormerViewController: FormViewController {
    
    lazy var zeroSpaceHeader: (() -> CustomViewFormer<FormHeaderFooterView>) = {
        let former = CustomViewFormer<FormHeaderFooterView>()
            .configure { $0.viewHeight = 0 }
        return former
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView()
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: view.frame.width, bottom: 0, right: 0)
        
        loadFormer()
    }
    
    func setupNavigationBar() {
        navigation.bar.tintColor = .white
        setupServiceNavigationItem()
        navigation.bar.titleTextAttributes = [
            .foregroundColor : AppColorStyle.shared.backgroundWhite,
            .font: AppFontProvider.shared.getFont16Medium()
        ]
    }
    
    func loadFormer() {
    }
    
    // 定义更新约束的方法
    func updateTableViewConstraints(
        top: CGFloat,
        bottom: CGFloat,
        leading: CGFloat,
        trailing: CGFloat,
        pinToScreenTop: Bool
    ) {
        view.constraints.filter {
                $0.firstItem as? UIView == tableView ||
                $0.secondItem as? UIView == tableView
        }.forEach {
            view.removeConstraint($0)
        }
        let topAnchor = pinToScreenTop ? view.topAnchor : view.safeAreaLayoutGuide.topAnchor

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: top),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailing)
        ])
    }
    
}

extension BaseFormerViewController {
    override func serviceAction() {
    }
    
}
