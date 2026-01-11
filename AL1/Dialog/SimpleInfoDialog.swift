//
//  SimpleInfoDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit

class SimpleInfoDialog: BaseDialog {
    
    func configure(
        title: String,
        message: Any,
        buttonTitle: String,
        action: DialogAction?,
        showCancelButton: Bool = true,
        onCancelAction: DialogAction?
    ) {
        titleLabel.text = title
        primaryButton.setTitle(buttonTitle, for: .normal)
        primaryAction = action
        cancelAction = onCancelAction
        
        // 使用扩展，一行搞定
        messageLabel.anyText = message
        cancelButton.isHidden = !showCancelButton
        self.layoutIfNeeded()
    }
    
    override func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(primaryButton)
        contentView.addSubview(cancelButton)
        
        messageLabel.textColor = UIColor(hex: "#878787")
        
        let margin: CGFloat = 30
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(margin)
            make.leading.trailing.equalToSuperview().inset(margin)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(margin)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(margin)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-margin) // 撑开底部
        }
        
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(25)
            make.top.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        // 限制内容视图的宽度
        let width = UIScreen.main.bounds.width - 50
        contentView.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
    }
}
