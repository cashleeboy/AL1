//
//  GradientProgressView.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class ImageStepSlider: UIControl {
    
    /// 激活状态的刻度图标
    var dotActiveImage: UIImage? { didSet { setNeedsLayout() } }
    /// 未激活状态的刻度图标
    var dotInactiveImage: UIImage? { didSet { setNeedsLayout() } }
    
    /// 滑块图标 (如果不设置，则使用默认圆点)
    var thumbImage: UIImage? { didSet { updateThumbView(); setNeedsLayout() } }
    
    // MARK: - 颜色与尺寸配置
    var steps: [String] = ["", "25%", "50%", "75%", "100%"] {
        didSet { setupSteps() }
    }
    
    var currentIndex: Int = 0 {
        didSet {
            sendActions(for: .valueChanged)
            setNeedsLayout()
        }
    }
    
    var activeBarColor = UIColor(red: 0.95, green: 0.60, blue: 0.29, alpha: 1.0)
    var inactiveBarColor = UIColor(red: 0.95, green: 0.88, blue: 0.82, alpha: 1.0)
    var labelActiveColor = UIColor(red: 0.95, green: 0.60, blue: 0.29, alpha: 1.0)
    var labelInactiveColor = UIColor.lightGray
    
    var trackHeight: CGFloat = 6.0
    var dotSize = CGSize(width: 24, height: 24) // 刻度图的大小
    
    // MARK: - UI 组件
    private let trackLayer = CALayer()
    private let progressLayer = CALayer()
    private var dotImageViews: [UIImageView] = []
    private var labels: [UILabel] = []
    private let thumbView = UIImageView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // 背景条
        trackLayer.masksToBounds = true
        layer.addSublayer(trackLayer)
        
        // 进度条
        progressLayer.masksToBounds = true
        layer.addSublayer(progressLayer)
        
        // 滑块
        thumbView.contentMode = .scaleAspectFit
        addSubview(thumbView)
        
        setupSteps()
    }
    
    private func updateThumbView() {
        if let img = thumbImage {
            thumbView.image = img
            thumbView.backgroundColor = .clear
        } else {
            // 默认样式
            thumbView.image = dotActiveImage
        }
    }
    
    private func setupSteps() {
        // 清理
        dotImageViews.forEach { $0.removeFromSuperview() }
        labels.forEach { $0.removeFromSuperview() }
        dotImageViews.removeAll()
        labels.removeAll()
        
        for text in steps {
            // 刻度图片视图
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            addSubview(iv)
            dotImageViews.append(iv)
            
            // 标签
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            addSubview(label)
            labels.append(label)
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sideMargin: CGFloat = dotSize.width / 2 + 20
        let availableWidth = bounds.width - (sideMargin * 2)
        let stepWidth = availableWidth / CGFloat(steps.count - 1)
        
        // 1. 轨道布局
        let trackY = bounds.height / 2 - trackHeight / 2 - 10
        trackLayer.frame = CGRect(x: sideMargin, y: trackY, width: availableWidth, height: trackHeight)
        trackLayer.backgroundColor = inactiveBarColor.cgColor
        trackLayer.cornerRadius = trackHeight / 2
        
        // 2. 进度条布局
        let progressWidth = CGFloat(currentIndex) * stepWidth
        progressLayer.frame = CGRect(x: sideMargin, y: trackY, width: progressWidth, height: trackHeight)
        progressLayer.backgroundColor = activeBarColor.cgColor
        progressLayer.cornerRadius = trackHeight / 2
        
        // 3. 刻度点与文字布局
        for i in 0..<steps.count {
            let centerX = sideMargin + CGFloat(i) * stepWidth
            let centerY = trackLayer.frame.midY
            
            // 刻度图标
            let iv = dotImageViews[i]
            iv.frame = CGRect(x: 0, y: 0, width: dotSize.width, height: dotSize.height)
            iv.center = CGPoint(x: centerX, y: centerY)
            
            let isActive = i <= currentIndex
            iv.image = isActive ? dotActiveImage : dotInactiveImage
            
            // 文字
            let label = labels[i]
            label.textColor = isActive ? labelActiveColor : labelInactiveColor
            label.sizeToFit()
            label.center = CGPoint(x: centerX, y: centerY + 20)
        }
        
        // 4. 滑块布局
        thumbView.frame = CGRect(x: 0, y: 0, width: dotSize.width + 4, height: dotSize.height + 4)
        thumbView.center = CGPoint(x: sideMargin + progressWidth, y: trackLayer.frame.midY)
    }
    
    // MARK: - Interaction
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        handleTouch(touch)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        handleTouch(touch)
        return true
    }
    
    private func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self)
        let sideMargin: CGFloat = dotSize.width / 2 + 10
        let availableWidth = bounds.width - (sideMargin * 2)
        
        let rawPercent = (location.x - sideMargin) / availableWidth
        let percentage = max(0, min(1, rawPercent))
        
        let closestIndex = Int(round(percentage * CGFloat(steps.count - 1)))
        if closestIndex != currentIndex {
            currentIndex = closestIndex
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}
