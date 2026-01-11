//
//  CommonWebView.swift
//  AL1
//
//  Created by cashlee on 2026/1/5.
//

import UIKit
import WebKit
import SnapKit

protocol CommonWebViewDelegate: AnyObject {
    func webView(_ webView: CommonWebView, didReceiveJSMessage name: String, body: Any)
    func webView(_ webView: CommonWebView, didUpdateTitle title: String?)
}

class CommonWebView: UIView {
    
    // MARK: - UI Components
    private(set) var webView: WKWebView!
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .clear
        progress.progressTintColor = AppColorStyle.shared.brandPrimary
        return progress
    }()
    
    weak var delegate: CommonWebViewDelegate?
    private var handlers: [String] = []
    
    // MARK: - Init
    init(handlers: [String] = []) {
        self.handlers = handlers
        super.init(frame: .zero)
        setupWebView()
        setupConstraints()
        addObservers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        // 安全移除监听
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        let userContent = webView.configuration.userContentController
        handlers.forEach { userContent.removeScriptMessageHandler(forName: $0) }
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let userContent = WKUserContentController()
        
        // 批量注入 JS 监听
        handlers.forEach { userContent.add(LeakFreeScriptHandler(delegate: self), name: $0) }
        
        config.userContentController = userContent
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        
        addSubview(webView)
        addSubview(progressView)
    }
    
    private func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        progressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide).offset(6)
            make.height.equalTo(3)
        }
    }
    
    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func evaluateJS(_ script: String) {
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    private func addObservers() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.setProgress(progress, animated: true)
            
            // 进度条平滑消失逻辑
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.setProgress(0, animated: false)
                })
            } else {
                progressView.alpha = 1
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension CommonWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webView(self, didUpdateTitle: webView.title)
    }
}

// MARK: - 处理 JS 内存泄漏的包装类
class LeakFreeScriptHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) { self.delegate = delegate }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

extension CommonWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.webView(self, didReceiveJSMessage: message.name, body: message.body)
    }
}
