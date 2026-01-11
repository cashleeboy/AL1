//
//  NSAttributedStringExtension.swift
//  AL1
//
//  Created by cashlee on 2025/12/15.
//

import UIKit
import Foundation

// MARK: - 1. Attributed String 样式封装

extension NSAttributedString {
    
    /// 创建一个包含特定链接样式的 NSMutableAttributedString
    /// - Parameters:
    ///   - fullText: 完整的文本字符串。
    ///   - linkText: 需要突出显示并应用链接样式的子字符串。
    ///   - linkColor: 链接文本的颜色。
    ///   - defaultFont: 默认文本的字体。
    ///   - defaultColor: 默认文本的颜色。
    ///   - linkStyle: 链接样式 (例如 .underline)。
    /// - Returns: 配置好的 NSAttributedString。
    static func createLinkString(
        fullText: String,
        linkText: String,
        linkColor: UIColor,
        defaultFont: UIFont,
        defaultColor: UIColor,
        linkStyle: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
    ) -> NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(string: fullText)
        // 1. 设置默认样式
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: defaultFont, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: defaultColor, range: fullRange)
        
        // 2. 查找并应用链接样式
        if let linkRange = fullText.range(of: linkText) {
            let nsRange = NSRange(linkRange, in: fullText)
            
            // 链接颜色
            attributedString.addAttribute(.foregroundColor,
                                          value: linkColor,
                                          range: nsRange)
            
            // 链接风格 (如下划线)
            for (key, value) in linkStyle {
                attributedString.addAttribute(key, value: value, range: nsRange)
            }
        }
        return attributedString
    }
    
}

extension NSMutableAttributedString {
    
    /// 快速创建一个带有颜色和下划线的富文本
    /// - Parameters:
    ///   - string: 文本内容
    ///   - color: 字体颜色
    ///   - underlineStyle: 下划线样式，默认为单下划线
    convenience init(string: String, color: UIColor, underlineStyle: NSUnderlineStyle = .single) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .underlineStyle: underlineStyle.rawValue
        ]
        self.init(string: string, attributes: attributes)
    }
    
    /// 给现有的富文本追加带有下划线样式的文字
    /// - Parameters:
    ///   - string: 追加的文本内容
    ///   - color: 字体颜色
    ///   - underlineStyle: 下划线样式
    func appendUnderlineString(_ string: String, color: UIColor, underlineStyle: NSUnderlineStyle = .single) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .underlineStyle: underlineStyle.rawValue
        ]
        let attrString = NSAttributedString(string: string, attributes: attributes)
        self.append(attrString)
    }
}


extension NSMutableAttributedString {
    /// 创建带有特定加粗部分和段落样式的富文本
    /// - Parameters:
    ///   - fullText: 完整文本
    ///   - boldParts: 需要加粗的字符串数组
    ///   - font: 常规字体大小
    ///   - boldFont: 加粗部分的大小（如果不传，默认使用常规字号的 Bold 变体）
    ///   - lineSpacing: 行间距
    ///   - alignment: 对齐方式
    static func makeStyledText(
        fullText: String,
        boldParts: [String],
        font: UIFont,
        boldFont: UIFont? = nil,
        textColor: UIColor? = nil,
        boldTextColor: UIColor? = nil,
        lineSpacing: CGFloat? = 4.0,
        alignment: NSTextAlignment = .left
    ) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 1. 设置全局默认样式（常规字体和颜色）
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: font, range: fullRange)
        
        if let textColor {
            attributedString.addAttribute(.foregroundColor, value: textColor, range: fullRange)
        }
        
        if let lineSpacing {
            // 2. 设置段落样式
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.alignment = alignment
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        }
        // 3. 应用粗体样式（根据子字符串查找 Range）
        let finalBoldFont = boldFont ?? UIFont.boldSystemFont(ofSize: font.pointSize)
        
        for part in boldParts {
            let range = (fullText as NSString).range(of: part)
            if range.location != NSNotFound {
                attributedString.addAttribute(.font, value: finalBoldFont, range: range)
                if let boldTextColor {
                    attributedString.addAttribute(.foregroundColor, value: boldTextColor, range: range)
                }
            }
        }
        return attributedString
    }
}

extension NSMutableAttributedString {
    
    /// 将步骤字符串数组转换为带序号、行间距和关键词加粗的富文本
    static func makeStepInstructions(
        steps: [String],
        boldKeywords: [String],
        font: UIFont,
        boldFont: UIFont,
        color: UIColor,
        lineSpacing: CGFloat = 8.0
    ) -> NSMutableAttributedString {
        
        let fullAttributedString = NSMutableAttributedString()
        
        for (index, text) in steps.enumerated() {
            // 添加序号 (1. 2. 3...)
            let stepText = "\(index + 1). \(text)\(index == steps.count - 1 ? "" : "\n")"
            let attrString = NSMutableAttributedString(string: stepText)
            
            // 全局样式
            let range = NSRange(location: 0, length: attrString.length)
            attrString.addAttribute(.font, value: font, range: range)
            attrString.addAttribute(.foregroundColor, value: color, range: range)
            
            // 段落样式（间距）
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
            // 关键词加粗
            for keyword in boldKeywords {
                let keywordRange = (stepText as NSString).range(of: keyword)
                if keywordRange.location != NSNotFound {
                    attrString.addAttribute(.font, value: boldFont, range: keywordRange)
                }
            }
            
            fullAttributedString.append(attrString)
        }
        
        return fullAttributedString
    }
}
