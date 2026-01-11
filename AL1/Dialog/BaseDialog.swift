//
//  BaseDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit
import SnapKit

typealias DialogAction = () -> Void

class BaseDialog: UIView {
    
    private let backgroundOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - 2. 通用内容组件 (从 NormalDialog 提升)
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont16Bold()
        label.textColor = AppColorStyle.shared.texBlackDialog
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Semibold()
        label.textColor = AppColorStyle.shared.texBlackDialog
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = AppColorStyle.shared.brandPrimary
        button.setTitleColor(AppColorStyle.shared.backgroundWhite, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont18Semibold()
        return button
    }()
    
    lazy var cancelButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "dialog_cancel_icon"), for: .normal)
        return button
    }()
    
    
    // MARK: - 3. 动作与初始化
    var primaryAction: DialogAction?
    var cancelAction: DialogAction?
    
    init() {
        super.init(frame: .zero)
        setupBaseUI()
        // 抽象方法：由子类实现具体组件的添加和约束
        setupViews()
        
        primaryButton.addTarget(self, action: #selector(handlePrimaryAction), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(handleCancelAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBaseUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        
        // 内容居中
        contentView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-10)
        }
    }
    
    @objc func handlePrimaryAction() {
        primaryAction?()
    }
    
    @objc func handleCancelAction() {
        cancelAction?()
    }
    
    func setupViews() {
        // 默认实现：将核心组件添加到 contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(primaryButton)
    }
}
