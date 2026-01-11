//
//  ComplexErrorDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/14.
//

import UIKit

class ComplexErrorDialog: BaseDialog {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        // 假设图标是图片文件中的纸张/感叹号图标
        imageView.image = UIImage(named: "dialog_apply_limit")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    func configure(icon: UIImage?, title: String, message: String, buttonTitle: String, action: DialogAction?) {
        iconImageView.image = icon
        titleLabel.text = title
        messageLabel.text = message
        primaryButton.setTitle(buttonTitle, for: .normal)
        primaryAction = action
    }
    
    override func setupViews() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(primaryButton)
        
        let margin: CGFloat = 25
        let buttonHeight: CGFloat = 55
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(margin)
            make.centerX.equalToSuperview()
            make.size.equalTo(80) // 固定图标尺寸
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(margin)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(margin)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(margin)
            make.height.equalTo(buttonHeight)
            make.bottom.equalToSuperview().offset(-margin) // 撑开底部
        }
        
        let width = UIScreen.main.bounds.width - 50
        contentView.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
    }
}
