//
//  GIFHUDImage.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit
import Foundation

class GIFHUDImage: UIImage, @unchecked Sendable {

    // 优化：使用代理类解决 CADisplayLink 对 self 的强引用导致的内存泄漏
    private class DisplayLinkProxy {
        weak var target: GIFHUDImage?
        init(_ target: GIFHUDImage) { self.target = target }
        @objc func update() { target?.updateCurrentFrame() }
    }
    
    private let lock = NSLock() // 优化：增加互斥锁保证多线程预加载安全
    private let framesToPreload = 10
    private let maxTimeStep = 1.0
    
    weak var delegate: GIFHUDImageView?
    var frameDurations = [TimeInterval]()
    var frames = [UIImage?]()
    var totalDuration: TimeInterval = 0.0
    
    private lazy var displayLink: CADisplayLink = {
        let proxy = DisplayLinkProxy(self)
        let dl = CADisplayLink(target: proxy, selector: #selector(DisplayLinkProxy.update))
        return dl
    }()
    
    private lazy var preloadFrameQueue = DispatchQueue(label: "com.gifhud.preload", qos: .userInteractive)
    private var currentFrameIndex = 0
    private var imageSource: CGImageSource?
    private var timeSinceLastFrameChange: TimeInterval = 0.0
    
    var currentFrame: UIImage? {
        return frameAtIndex(currentFrameIndex)
    }
    
    var isAnimated: Bool {
        return imageSource != nil
    }

    // MARK: Initializers
    init(data: Data, delegate: GIFHUDImageView?) {
        let options = [kCGImageSourceShouldCache: true] as CFDictionary
        self.imageSource = CGImageSourceCreateWithData(data as CFData, options)
        self.delegate = delegate
        super.init()
        
        prepareFrames(imageSource)
        attachDisplayLink()
        pauseAnimation()
    }
    
    convenience init?(image named: String, delegate: GIFHUDImageView?) {
        // 兼容不同的路径获取方式
        let path = Bundle.main.path(forResource: named, ofType: nil) ?? Bundle.main.bundlePath + "/\(named)"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        self.init(data: data, delegate: delegate)
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
//    @objc required init(imageLiteralResourceName name: String) { fatalError("init(name:) has not been implemented") }

    deinit {
        displayLink.invalidate() // 优化：销毁时必须停止渲染循环
    }

    // MARK: 逻辑方法
    func attachDisplayLink() {
        displayLink.add(to: .main, forMode: .common)
    }
    
    private func prepareFrames(_ source: CGImageSource?) {
        guard let source = source else { return }
        let numberOfFrames = CGImageSourceGetCount(source)
        
        frames.reserveCapacity(numberOfFrames)
        for index in 0..<numberOfFrames {
            let duration = getFrameDuration(source, index: index)
            frameDurations.append(duration)
            totalDuration += duration
            
            if index < framesToPreload {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                    frames.append(UIImage(cgImage: cgImage))
                }
            } else {
                frames.append(nil)
            }
        }
    }

    private func frameAtIndex(_ index: Int) -> UIImage? {
        lock.lock(); defer { lock.unlock() } // 优化：加锁保护
        if index >= frames.count { return nil }
        let img = frames[index]
        updatePreloadedFramesAtIndex(index)
        return img
    }

    private func updatePreloadedFramesAtIndex(_ index: Int) {
        if frames.count <= framesToPreload { return }
        
        // 释放旧帧
        if index != 0 { frames[index] = nil }
        
        // 预加载后续帧
        for i in 1...framesToPreload {
            let nextIndex = (index + i) % frames.count
            if frames[nextIndex] == nil {
                preloadFrameQueue.async { [weak self] in
                    guard let self = self, let source = self.imageSource else { return }
                    if let cgImage = CGImageSourceCreateImageAtIndex(source, nextIndex, nil) {
                        self.lock.lock()
                        self.frames[nextIndex] = UIImage(cgImage: cgImage)
                        self.lock.unlock()
                    }
                }
            }
        }
    }

    @objc fileprivate func updateCurrentFrame() {
        guard isAnimated else { return }
        
        timeSinceLastFrameChange += min(maxTimeStep, displayLink.duration)
        let frameDuration = frameDurations[currentFrameIndex]
        
        if timeSinceLastFrameChange >= frameDuration {
            timeSinceLastFrameChange -= frameDuration
            currentFrameIndex = (currentFrameIndex + 1) % frames.count
            delegate?.layer.setNeedsDisplay() // 触发显示
        }
    }

    func pauseAnimation() { displayLink.isPaused = true }
    func resumeAnimation() { displayLink.isPaused = false }
    var isAnimating: Bool { return !displayLink.isPaused }

    private func getFrameDuration(_ source: CGImageSource, index: Int) -> TimeInterval {
        var duration = 0.1
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        if let props = cfProperties as? [String: Any],
           let gifProps = props[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
            duration = (gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double)
                ?? (gifProps[kCGImagePropertyGIFDelayTime as String] as? Double) ?? 0.1
        }
        return duration < 0.011 ? 0.1 : duration
    }
}
