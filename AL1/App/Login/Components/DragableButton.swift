//
//  DragableButton.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

import UIKit

class DragableButton: UIButton {
    
    typealias btnClosure = (_ btn: DragableButton) -> Void
    
    // 配置常量
    private let DOUBLE_CLICK_TIME = 0.25
    private let ANIMATION_DURATION: TimeInterval = 0.25
    
    // 属性状态
    var draggable: Bool = true
    var autoDocking: Bool = true
    
    private var isDragging: Bool = false
    private var beginLocation: CGPoint = .zero
    private var lastClickTime: TimeInterval = 0
    
    // 回调
    var clickClosure: btnClosure?
    var doubleClickClosure: btnClosure?
    var draggingClosure: btnClosure?
    var dragDoneClosure: btnClosure?
    var autoDockEndClosure: btnClosure?
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // 添加点击事件
        self.addTarget(self, action: #selector(handleInternalClick), for: .touchUpInside)
    }
    
    // MARK: - 点击逻辑处理 (区分单双击)
    @objc private func handleInternalClick() {
        let now = CACurrentMediaTime()
        
        // 如果有双击回调，则走延迟逻辑
        if doubleClickClosure != nil {
            if now - lastClickTime < DOUBLE_CLICK_TIME {
                // 取消之前的单击任务
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(executeSingleClick), object: nil)
                doubleClickClosure?(self)
                lastClickTime = 0 // 重置
            } else {
                lastClickTime = now
                self.perform(#selector(executeSingleClick), with: nil, afterDelay: DOUBLE_CLICK_TIME)
            }
        } else {
            // 没有双击回调，直接触发单击
            executeSingleClick()
        }
    }
    
    @objc private func executeSingleClick() {
        if !isDragging {
            clickClosure?(self)
        }
    }
    
    // MARK: - 触摸追踪 (核心修复)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isDragging = false
        if let touch = touches.first {
            beginLocation = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard draggable, let touch = touches.first, let superview = self.superview else { return }
        
        isDragging = true
        let currentLocation = touch.location(in: self)
        
        // 计算偏移
        let offsetX = currentLocation.x - beginLocation.x
        let offsetY = currentLocation.y - beginLocation.y
        
        var newCenter = CGPoint(x: self.center.x + offsetX, y: self.center.y + offsetY)
        
        // 边界限制
        let padding = self.bounds.width / 2
        newCenter.x = max(padding, min(newCenter.x, superview.bounds.width - padding))
        newCenter.y = max(self.bounds.height / 2, min(newCenter.y, superview.bounds.height - self.bounds.height / 2))
        
        self.center = newCenter
        draggingClosure?(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 如果是拖拽结束，我们需要阻止 super.touchesEnded 触发点击事件
        if isDragging {
            self.isHighlighted = false // 取消高亮状态
            handleAutoDocking()
            dragDoneClosure?(self)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isDragging = false
    }
    
    // MARK: - 自动吸附逻辑
    private func handleAutoDocking() {
        guard autoDocking, let superview = self.superview else {
            isDragging = false
            return
        }
        
        let middleX = superview.bounds.width / 2.0
        let targetX = self.center.x >= middleX ? (superview.bounds.width - self.bounds.width / 2.0) : (self.bounds.width / 2.0)
        
        UIView.animate(withDuration: ANIMATION_DURATION, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.center = CGPoint(x: targetX - 5, y: self.center.y)
        }) { _ in
            self.isDragging = false
            self.autoDockEndClosure?(self)
        }
    }
    
    // MARK: - Window 管理 (适配 iOS 13+)
    func addButtonToKeyWindow() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.addSubview(self)
    }
    
    func removeFromKeyWindow() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.subviews.forEach {
            if $0 is DragableButton { $0.removeFromSuperview() }
        }
    }
}
