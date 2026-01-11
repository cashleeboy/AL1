//
//  ViewExtensions.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import UIKit

// MARK: - UIView 扩展：自定义圆角

extension UIView {
    
    func setCornerRadius(_ radius: CGFloat, maskedCorners: CACornerMask) {
        layer.cornerRadius = radius
        layer.maskedCorners = maskedCorners
        
        // ⭐️ 核心：确保内容被裁剪到圆角边界
        layer.masksToBounds = true
    }
    
}


// MARK: - 辅助方法：应用渐变

extension UIView {
    /// 移除所有 CAGradientLayer
    func removeGradientLayer() {
        self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
    }
    
    /// 设置背景渐变色
    func applyGradient(with colors: [UIColor]) {
        // 1. 移除旧的渐变层，避免重复
        removeGradientLayer()
        
        // 2. 获取新的渐变层
        let gradientLayer = AppColorStyle.shared.brandPrimaryGradientLayer(in: self.bounds, colors: colors)
        
        // 3. 插入到最底层 (索引 0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

