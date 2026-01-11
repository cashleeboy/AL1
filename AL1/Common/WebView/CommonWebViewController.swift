//
//  CommonWebViewController.swift
//  AL1
//
//  Created by cashlee on 2026/1/5.
//

import UIKit
import WebKit
import SnapKit

class CommonWebViewController: UIViewController {
    
    private let urlString: String
    private lazy var commonWebView = CommonWebView(handlers: WebViewJSBridgeManager.allHandlers)
    
    // 强引用 Manager 防止被销毁
    private lazy var bridgeManager: WebViewJSBridgeManager = {
        let manager = WebViewJSBridgeManager()
        manager.viewController = self
        return manager
    }()
    
    // MARK: - Init
    /// - Parameters:
    ///   - url: H5 链接
    ///   - handlers: 需要监听的 JS 方法名数组（如 ["onPageFinished"]）
    init(url: String) {
        self.urlString = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setupNavigationBar() {
        navigation.bar.additionalHeight = 0
        navigation.bar.tintColor = .white
        navigation.bar.alpha = 1
        let navImage = UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal)
        navigation.bar.setBackgroundImage(navImage, for: .top, barMetrics: .default)
        
        navigation.bar.titleTextAttributes = [
            .foregroundColor : AppColorStyle.shared.backgroundWhite,
            .font: AppFontProvider.shared.getFont16Medium()
        ]
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        commonWebView.load(urlString: urlString)
    }
    
    //    func evaluateJS(_ script: String) {
    //        webView?.evaluateJavaScript(script, completionHandler: nil)
    //    }
}

extension CommonWebViewController
{
    private func setupUI() {
        
        view.addSubview(commonWebView)
        commonWebView.delegate = self
        commonWebView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

// MARK: - CommonWebViewDelegate
extension CommonWebViewController: CommonWebViewDelegate {
    func webView(_ webView: CommonWebView, didReceiveJSMessage name: String, body: Any) {
        print("*** 收到 JS 消息: \(name), 数据: \(body)")
        
        // 统一分发给 BridgeManager 处理
        // bridgeManager.handle(name: name, body: body)
        
        if name == "onPageFinished" {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: CommonWebView, didUpdateTitle title: String?) {
        self.navigation.item.title = title
    }
}

