//
//  WebViewDialog.swift
//  AL1
//
//  Created by cashlee on 2026/1/5.
//

import UIKit
import Foundation

class WebViewDialog: BaseDialog {
    
    private var articles: [NSMutableAttributedString] = []
    var onRejectHandler: (() -> Void)?
    var onPrimaryHandler: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var webView: CommonWebView = {
        let webView = CommonWebView()
//        webView.delegate = self
        return webView
    }()

    lazy var rejectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = AppFontProvider.shared.getFont12Regular()
        
        let color = UIColor(hex: "#A4A4A4")
        button.setAttributedTitle(NSMutableAttributedString(string: "Rechazo", color: color), for: .normal)
        button.addTarget(self, action: #selector(rejectAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Setup
    
    override func setupViews() {
        super.setupViews()
        // 1. 初始化父类组件状态
        primaryButton.setTitle("Acepto", for: .normal)
        
        // 2. 添加到 contentView (注意：BaseDialog 里的子组件通常在 contentView 中)
        contentView.addSubview(webView)
        contentView.addSubview(rejectButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(35)
        }
        
        // 3. 重新布局
        // 标题已在 BaseDialog 中布局，此处处理其他组件
        webView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            make.width.equalTo(screenWidth * 0.8).priority(.high)
            make.height.equalTo(screenHeight * 0.4).priority(.high)
        }

        primaryButton.snp.remakeConstraints { make in
            make.top.equalTo(webView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }

        rejectButton.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20) // 闭合约束链
        }
        
        contentView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-10)
        }
    }

    // MARK: - Actions
    
    @objc func rejectAction() {
        onRejectHandler?()
    }
    
    override func handlePrimaryAction() {
        onPrimaryHandler?()
    }

    func configure(with url: String, primaryAction:(() -> Void)?, rejectAction: (() -> Void)?) {
        self.onRejectHandler = rejectAction
        self.onPrimaryHandler = primaryAction
        
        webView.load(urlString: url)
        
    }
}
