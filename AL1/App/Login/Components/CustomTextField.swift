//
//  CustomTextField.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class CustomTextField: UITextField, UITextFieldDelegate
{
    // 允许的最大输入长度
    var maxCount: Int = 9
    var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - 辅助方法：计算包含视图占位的实际 Rect
    private func adjustedRect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds.inset(by: padding)
        
        // 如果右视图存在，减去右侧宽度（避免文字钻到右图标下）
        if let rightView = rightView {
            let rightWidth = rightView.frame.width + 10 // 图标宽 + 间距
            rect.size.width -= rightWidth
        }
        
        return rect
    }
    
    /// 设置 Placeholder 的文本、颜色和字体
    func setCustomPlaceholder(text: String, color: UIColor, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        self.attributedPlaceholder = attributedString
    }
    
    // 重写 textRect 以控制文本绘制区域
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedRect(forBounds: bounds)
    }
    
    // 重写 placeholderRect 以控制占位符区域
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedRect(forBounds: bounds)
    }
    
    // 重写 editingRect 以控制编辑时的文本区域
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedRect(forBounds: bounds)
    }
    
    // 重写 leftViewRect 以控制左视图的区域
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x = bounds.minX
        rect.size.width = leftView?.frame.width ?? 0
        return rect
    }
    
    // 重写 rightViewRect 以控制右视图的区域
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x = bounds.width - (rightView?.frame.width ?? 0)
        return rect
    }
}
