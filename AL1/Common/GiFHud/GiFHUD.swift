//
//  GiFHUD.swift
//  GiFHUD-Swift
//
//  Created by Cem Olcay on 07/11/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

private struct HUDTask {
    let id: UUID = UUID()
    let startTime: Date = Date()
    let message: String?
}

class GIFHUD: UIView {

    static let shared = GIFHUD()
    // 任务堆栈：记录每一次 show 的请求
    private var taskStack: [HUDTask] = []
    // 记录最后一次 show 的时间（便于调试或逻辑判断）
    private(set) var lastShowTime: Date?
    
    private var hudSize: CGSize = CGSize(width: 200, height: 160)
    private var fadeDuration: TimeInterval = 0.3
    private var overlayAlpha: CGFloat = 0.3
    
    private var overlayView: UIView?
    private let imageView: GIFHUDImageView = {
        let img = GIFHUDImageView()
        img.backgroundColor = .clear // 优化：透明背景
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = AppFontProvider.shared.getFont14Regular()
        label.textColor = UIColor(hex: "#717382")
        label.textAlignment = .center
        label.numberOfLines = 4
        label.text = "Cargando, por favor espere pacientemente..."
        return label
    }()
    
    private var isShowing: Bool = false
    
    // 优化：适配 iOS 13+ 的 Window 获取方式
    private var activeWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    private init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        self.alpha = 0
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        addSubview(imageView)
        addSubview(messageLabel)
        
        // 优化：使用 SnapKit 彻底解决布局问题
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(110)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().offset(-15)
        }
    }
    
    @discardableResult
    func show(message: String = "Cargando, por favor espere pacientemente...",
              withOverlay: Bool = true,
              defaultGif: String = "loading_compressed.gif") -> UUID{

        let task = HUDTask(message: message)
        taskStack.append(task)
        
        messageLabel.text = message
        
        // 如果当前没有设置图片，则加载默认图
        if imageView.image == nil {
            setGif(named: defaultGif)
        }
        if self.alpha > 0 { // 已经在显示中，仅更新文字
            return task.id
        }
        
        guard let window = activeWindow else { return task.id }
        
        if withOverlay {
            overlayView = UIView(frame: window.bounds)
            overlayView?.backgroundColor = .black
            overlayView?.alpha = 0
            window.addSubview(overlayView!)
            UIView.animate(withDuration: 0.3) { self.overlayView?.alpha = self.overlayAlpha }
        }
        
        if self.superview == nil {
            window.addSubview(self)
            self.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.greaterThanOrEqualTo(120)
                make.width.lessThanOrEqualTo(200)
            }
        }
        window.bringSubviewToFront(self)
        
        imageView.startAnimatingGif()
        
        UIView.animate(withDuration: fadeDuration) { self.alpha = 1 }
        return task.id
    }
    
    func dismiss(id: UUID? = nil) {
        if let targetId = id {
            if let index = taskStack.firstIndex(where: { $0.id == targetId }) {
                let task = taskStack.remove(at: index)
                let duration = Date().timeIntervalSince(task.startTime)
                print("HUD 任务 [\(targetId)] 结束，耗时: \(String(format: "%.2f", duration))s")
            }
        } else if !taskStack.isEmpty {
            taskStack.removeLast()
        }
        
        if taskStack.isEmpty {
            UIView.animate(withDuration: fadeDuration) {
                self.alpha = 0
                self.overlayView?.alpha = 0
            } completion: { _ in
                self.imageView.stopAnimatingGif()
                self.overlayView?.removeFromSuperview()
                self.removeFromSuperview()
                self.overlayView = nil
            }
        } else {
            // 如果栈内还有任务，文字切回上一个任务的文字
            messageLabel.text = taskStack.last?.message
        }
    }
    
    func setGif(named: String) {
        imageView.setAnimatableImage(named: named)
    }
}

extension GIFHUD {
    /// 自动管理生命周期的加载任务
    static func runTask(withOverlay: Bool = true, task: (@escaping () -> Void) -> Void) {
        shared.show(withOverlay: withOverlay)
        
        task {
            // 当任务闭包中调用此完成回调时，自动隐藏
            shared.dismiss()
        }
    }
}
