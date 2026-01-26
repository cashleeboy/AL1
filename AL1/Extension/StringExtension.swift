//
//  StringExtension.swift
//  AL1
//
//  Created by cashlee on 2025/12/15.
//

import UIKit
import Foundation

extension String {
    /// 返回去除首尾空格和换行后的字符串
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    /// 统一定义的非法字符集：双引号、单引号、反斜杠、斜杠
    static let forbiddenInputChars = "\"'\\/"/// 过滤掉非法字符后的字符串
    var filteringForbiddenChars: String {
        let characterSet = CharacterSet(charactersIn: .forbiddenInputChars)
        return self.components(separatedBy: characterSet).joined()
    }
    
    /// 检查字符串是否包含非法字符
    var containsForbiddenChars: Bool {
        return self.rangeOfCharacter(from: CharacterSet(charactersIn: .forbiddenInputChars)) != nil
    }
    
    /// 是否是以空格开头
    var isStartingWithSpace: Bool {
        return self.hasPrefix(" ")
    }
    
    /// 通用正则验证
    func isValid(regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// 邮箱通用正则验证
    func isValidEmail() -> Bool {
        // 这是一个比较通用且严谨的邮箱正则
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return isValid(regex: emailRegex)
    }
    
    /// 姓名/姓氏校验逻辑
    /// - Parameters:
    ///   - min: 最小长度
    ///   - max: 最大长度
    /// - Returns: 是否通过校验 (仅限字母，开头不能是空格)
    func isValidName(min: Int, max: Int) -> Bool {
        // 1. 检查开头是否为空格
        if self.hasPrefix(" ") { return false }
        
        // 2. 正则说明：仅允许字母和空格（根据需求可调整是否允许中间空格）
        // 如果只允许纯字母：^[a-zA-ZáéíóúÁÉÍÓÚñÑ]{\(min),\(max)}$
        // 如果允许中间有空格：^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+( [a-zA-ZáéíóúÁÉÍÓÚñÑ]+)*$
        let regex = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{\(min),\(max)}$"
        return self.isValid(regex: regex)
    }
    
    /// 清除后端可能返回的 "null" 字符串字面量
    var removeNull: String {
        let lower = self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // 2. 判断是否为常见的 null 占位符
        if lower == "null" || lower == "<null>" || lower == "(null)" {
            return ""
        }
        // 3. 返回原始值（建议顺便去掉两端空格）
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 移除字符串中除数字以外的所有字符（包含空格、横杠、括号等）
    var digitsOnly: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    /// 灵活的千分位转换方法
    /// - Parameters:
    ///   - fractionDigits: 最多保留的小数位数
    ///   - prefix: 前缀（如 "$", "¥"）
    func formattedNumber(fractionDigits: Int = 2, prefix: String = "") -> String {
        // 1. 尝试将字符串转换为数字，失败则返回原字符串
        guard let number = Double(self) else { return self }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        // 2. 核心设置：
        // 只有当有小数时才显示，最多显示 fractionDigits 位
        formatter.maximumFractionDigits = fractionDigits
        // 最小保留 0 位，这样整数就不会带上 .00
        formatter.minimumFractionDigits = 0
        
        // 3. 格式化
        let formattedString = formatter.string(from: NSNumber(value: number)) ?? self
        return prefix + formattedString
    }
    
    // 使用示例
    // "1234567.8".formattedNumber(fractionDigits: 0)            // 输出: "1,234,568" (自动四舍五入)
    // "99999.99".formattedNumber(fractionDigits: 2, prefix: "¥") // 输出: "¥99,999.99"
}

extension String {

    /// 检查字符串是否只包含数字 (0-9)。
    /// 例如: "12345" -> true, "123a4" -> false, "" -> true
    var isNumeric: Bool {
        // 使用 CharacterSet 效率更高，但为了与你的原始正则匹配，我们保留正则
        let digitPattern = "^\\d*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", digitPattern)
        return predicate.evaluate(with: self)
        
        // 更 Swift 且更高效的实现：
        // return self.allSatisfy { $0.isNumber }
    }
    
    /// 检查字符串是否只包含给定字符集中的字符。
    /// 这是一个通用的验证方法。
    func containsOnly(charactersIn set: CharacterSet) -> Bool {
        // 将字符串中所有字符组成的集合，与目标集合求差集。如果差集为空，则只包含目标字符。
        // 注意：这是对 CharacterSet.init(charactersIn:) 的优化用法。
        return self.rangeOfCharacter(from: set.inverted) == nil
    }
}

extension String {
    
    var attributed: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    /// 带有基础属性配置的转换方法
    func toAttributedString(font: UIFont? = nil, color: UIColor? = nil) -> NSMutableAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let font = font { attributes[.font] = font }
        if let color = color { attributes[.foregroundColor] = color }
        
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
    
    func withHighlight(
        text highlightText: String,
        defaultColor: UIColor,
        highlightColor: UIColor,
        defaultFont: UIFont,
        highlightFont: UIFont? = nil,
        caseInsensitive: Bool = false
    ) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: self)
        let fullRange = NSRange(location: 0, length: self.utf16.count)
        
        attributedString.addAttributes([
            .font: defaultFont,
            .foregroundColor: defaultColor
        ], range: fullRange)
        
        var options: String.CompareOptions = []
        if caseInsensitive {
            options = [.caseInsensitive]
        }
        
        // 使用 Swift 的 range(of:) 查找
        if let swiftRange = self.range(of: highlightText, options: options) {
            let highlightRange = NSRange(swiftRange, in: self)
            var attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: highlightColor
            ]
            if let hFont = highlightFont {
                attributes[.font] = hFont
            }
            attributedString.addAttributes(attributes, range: highlightRange)
        }
        return attributedString
    }
}

extension String {
    static func fileNameGenerate(with extensionType: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let currentTime = dateFormatter.string(from: Date())
        return "img\(currentTime).\(extensionType)"
    }
}
