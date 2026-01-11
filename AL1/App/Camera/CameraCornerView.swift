//
//  CameraCornerView.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit

class CameraCornerView: UIView {
    
    var cornerColor: UIColor = AppColorStyle.shared.brandPrimary
    var lineWidth: CGFloat = 3.0
    var cornerLength: CGFloat = 25.0
    var cornerRadius: CGFloat = 12.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false // 不阻挡点击事件
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let halfWidth = lineWidth / 2
        
        // 调整绘制范围，使其刚好包裹在容器外侧
        let drawRect = rect.insetBy(dx: halfWidth, dy: halfWidth)
        let minX = drawRect.minX
        let minY = drawRect.minY
        let maxX = drawRect.maxX
        let maxY = drawRect.maxY
        
        // --- 左上角 ---
        path.move(to: CGPoint(x: minX, y: minY + cornerLength))
        path.addLine(to: CGPoint(x: minX, y: minY + cornerRadius))
        path.addArc(withCenter: CGPoint(x: minX + cornerRadius, y: minY + cornerRadius),
                    radius: cornerRadius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: true)
        path.addLine(to: CGPoint(x: minX + cornerLength, y: minY))

        // --- 右上角 ---
        path.move(to: CGPoint(x: maxX - cornerLength, y: minY))
        path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
        path.addArc(withCenter: CGPoint(x: maxX - cornerRadius, y: minY + cornerRadius),
                    radius: cornerRadius, startAngle: 1.5 * .pi, endAngle: 2 * .pi, clockwise: true)
        path.addLine(to: CGPoint(x: maxX, y: minY + cornerLength))

        // --- 右下角 ---
        path.move(to: CGPoint(x: maxX, y: maxY - cornerLength))
        path.addLine(to: CGPoint(x: maxX, y: maxY - cornerRadius))
        path.addArc(withCenter: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius),
                    radius: cornerRadius, startAngle: 0, endAngle: 0.5 * .pi, clockwise: true)
        path.addLine(to: CGPoint(x: maxX - cornerLength, y: maxY))

        // --- 左下角 ---
        path.move(to: CGPoint(x: minX + cornerLength, y: maxY))
        path.addLine(to: CGPoint(x: minX + cornerRadius, y: maxY))
        path.addArc(withCenter: CGPoint(x: minX + cornerRadius, y: maxY - cornerRadius),
                    radius: cornerRadius, startAngle: 0.5 * .pi, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: minX, y: maxY - cornerLength))

        cornerColor.setStroke()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.stroke()
    }
}
