//
//  TapActionLabel.swift
//  AL1
//
//  Created by cashlee on 2025/12/15.
//

import UIKit
import CoreText

class TapActionLabel: UIView {

    // MARK: - Properties
    
    /// 控制文字对齐方式
    @objc var textAlignment: NSTextAlignment = .left {
        didSet {
            updateParagraphStyle()
            setNeedsDisplay()
        }
    }

    @objc var attString: NSMutableAttributedString = NSMutableAttributedString(string: "输入字符串为空")
    @objc var rectFrame: CTFrame?
    
    // 用于点击事件的数组
    private var tapStringArray: [NSString] = []
    private var reactFunctionArray: [() -> Void] = []
    
    // 内部记录垂直居中的偏移量，用于点击判定
    private var verticalOffset: CGFloat = 0

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Public Methods
    
    @objc func setText(_ textString: NSMutableAttributedString) {
        attString = textString
        updateParagraphStyle()
        setNeedsDisplay()
    }
    
    @objc func tap(string: String, with action: @escaping () -> Void) {
        tapStringArray.append(string as NSString)
        reactFunctionArray.append(action)
    }

    // 更新段落样式以支持水平对齐
    private func updateParagraphStyle() {
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        attString.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, attString.length))
    }

    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // 1. 翻转坐标系 (UIKit -> CoreText)
        context.textMatrix = .identity
        context.translateBy(x: 0, y: rect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 2. 创建 Framesetter
        let frameSetter = CTFramesetterCreateWithAttributedString(attString)
        
        // 3. 计算文字路径 (Path)
        let path = CGMutablePath()
        
        // 如果需要居中，计算垂直方向的 Offset
        if textAlignment == .center || textAlignment == .right {
            let constraints = CGSize(width: rect.width, height: CGFloat.greatestFiniteMagnitude)
            let suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, attString.length), nil, constraints, nil)
            
            // 计算垂直居中的起始 Y 值
            verticalOffset = (rect.height - suggestSize.height) / 2
            let drawRect = CGRect(x: 0, y: verticalOffset, width: rect.width, height: suggestSize.height)
            path.addRect(drawRect)
        } else {
            verticalOffset = 0
            path.addRect(rect)
        }

        // 4. 绘制
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attString.length), path, nil)
        rectFrame = frame
        CTFrameDraw(frame, context)
    }

    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let frame = rectFrame else { return }
        
        // 1. 获取点击在 View 上的原始坐标
        let location = touch.location(in: self)
        
        // 2. 将 UIKit 坐标转换为 CoreText 坐标 (Y轴翻转)
        // CoreText 的原点在左下角
        var ctLocation = CGPoint(x: location.x, y: self.bounds.height - location.y)
        
        // 3. 修正垂直居中带来的偏移
        // 文字是在 verticalOffset 基础上绘制的，所以点击坐标要减去这个偏移量
        ctLocation.y -= verticalOffset

        // 4. 获取所有行信息
        let lines = CTFrameGetLines(frame)
        let lineCount = CFArrayGetCount(lines)
        if lineCount == 0 { return }

        var lineOrigins = [CGPoint](repeating: .zero, count: lineCount)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)

        // 5. 遍历每一行，找到点击了哪一行
        for i in 0..<lineCount {
            let lineOrigin = lineOrigins[i]
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, i), to: CTLine.self)
            
            // 获取行的上下边界 (Ascent/Descent)
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let lineWidth = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
            
            // 判定点击是否在当前行的纵向范围内
            let lineBottom = lineOrigin.y - descent
            let lineTop = lineOrigin.y + ascent
            
            if ctLocation.y >= lineBottom && ctLocation.y <= lineTop {
                // 6. 确定在该行中的字符索引
                let relativeClickPoint = CGPoint(x: ctLocation.x - lineOrigin.x, y: ctLocation.y - lineOrigin.y)
                let index = CTLineGetStringIndexForPosition(line, relativeClickPoint)
                
                // 7. 匹配点击范围
                checkTapActions(at: index)
                break
            }
        }
    }
    
    private func checkTapActions(at index: Int) {
        for (idx, tapNSString) in tapStringArray.enumerated() {
            let fullString = attString.string as NSString
            let range = fullString.range(of: tapNSString as String)
            
            if index >= range.location && index <= (range.location + range.length) {
                if idx < reactFunctionArray.count {
                    reactFunctionArray[idx]()
                }
            }
        }
    }
}
