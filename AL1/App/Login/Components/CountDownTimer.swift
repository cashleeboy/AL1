//
//  CountDownTimer.swift
//  AL1
//
//  Created by cashlee on 2025/12/15.
//

import Foundation

class CountDownTimer {
    
    private var timer: Timer?
    var duration: TimeInterval
    private var remainingTime: TimeInterval
    private var updateBlock: ((Int) -> Void)?
    private var completionBlock: (() -> Void)?
    
    /// 检查计时器是否正在运行
    public var isRunning: Bool {
        return timer != nil
    }
    
    /// 初始化倒计时器
    /// - Parameter duration: 总倒计时时长（秒）。
    init(duration: TimeInterval = 60.0) {
        self.duration = duration
        self.remainingTime = duration
    }
    
    /// 开始倒计时
    /// - Parameters:
    ///   - update: 每秒调用一次，传入剩余秒数。
    ///   - completion: 倒计时结束时调用。
    public func start(update: @escaping (Int) -> Void, completion: @escaping () -> Void) {
        if isRunning {
            return
        }
        
        // 1. 设置闭包
        self.updateBlock = update
        self.completionBlock = completion
        self.remainingTime = self.duration // 确保每次启动都从完整时长开始
        
        // 2. 立即调用一次更新，显示初始时间
        update(Int(self.remainingTime))
        
        // 3. 启动计时器：每秒重复一次，并传入 Timer 实例
        // 使用提供的 Timer.every 扩展
        self.timer = Timer.every(1.0) { [weak self] timer in
            guard let self = self else {
                timer.invalidate() // 如果 self 被释放，停止计时器
                return
            }
            
            self.remainingTime -= 1
            
            if self.remainingTime > 0 {
                // 持续更新
                self.updateBlock?(Int(self.remainingTime))
            } else {
                // 倒计时结束
                timer.invalidate()
                self.completionBlock?()
            }
        }
    }
    
    /// 停止倒计时
    public func stop() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    deinit {
        stop() // 确保在对象销毁时计时器被停止
    }
}
