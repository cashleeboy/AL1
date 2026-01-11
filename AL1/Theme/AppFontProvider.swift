//
//  AppFontProvider.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import UIKit

class AppFontProvider: NSObject {
    static let shared = AppFontProvider()
    
    // 私有初始化器，防止外部创建实例
    private override init() {}
    
    // 字体缓存，使用 String 作为 Key，存储 UIFont 实例
    private var fontCache: [String: UIFont] = [:]
    
    // ⭐️ 默认的自定义字体系列名称。如果您的项目中没有自定义字体，
    //    或者您主要使用系统字体，可以将其设置为 nil 或忽略。
    //    请替换为您的实际字体文件名称 (例如 "YourCustomFont-")
    private let customFontFamilyName: String? = nil // 例如: "PingFangSC" 或 "HelveticaNeue"
    
    // MARK: - 核心字体获取方法
    
    /// 获取缓存的或新创建的 UIFont 实例
    /// - Parameters:
    ///   - baseSize: 字体的基础大小 (CGFloat)
    ///   - weight: 字体的粗细 (UIFont.Weight)
    ///   - customName: 可选的自定义字体系列名称，如果为 nil 则使用系统字体
    /// - Returns: 对应的 UIFont 实例
    func getCachedFont(baseSize: CGFloat,
                       weight: UIFont.Weight,
                       customName: String? = nil) -> UIFont {
        
        let fontNameKey: String
        
        // 1. 确定字体名称 (Key)
        if let customName = customName ?? customFontFamilyName {
            // 尝试使用自定义字体 (例如: "PingFangSC-Semibold")
            fontNameKey = "\(customName)-\(weight.fontWeightString)"
        } else {
            // 使用系统字体 (Key 仅包含大小和粗细)
            fontNameKey = "System-\(baseSize)-\(weight.fontWeightString)"
        }
        
        // 2. 检查缓存
        if let cachedFont = fontCache[fontNameKey] {
            return cachedFont
        }
        
        // 3. 创建字体
        let newFont: UIFont
        
        if let customName = customName ?? customFontFamilyName {
            // 尝试创建自定义字体
            newFont = UIFont(name: fontNameKey, size: baseSize) ?? .systemFont(ofSize: baseSize, weight: weight)
        } else {
            // 创建系统字体
            newFont = .systemFont(ofSize: baseSize, weight: weight)
        }
        
        // 4. 存储到缓存
        fontCache[fontNameKey] = newFont
        
        return newFont
    }
    
    // MARK: - 公共方法
    func getFont50Bold() -> UIFont {
        return getCachedFont(baseSize: 50, weight: .bold)
    }
    
    func getFont30Bold() -> UIFont {
        return getCachedFont(baseSize: 30, weight: .bold)
    }
    
    // --- 字体大小 20 ---
    
    func getFont20Bold() -> UIFont {
        return getCachedFont(baseSize: 20, weight: .bold)
    }
    
    // --- 字体大小 18 ---
    
    /// 字体大小 18 (例如：Section 标题)
    func getFont18Semibold() -> UIFont {
        return getCachedFont(baseSize: 18, weight: .semibold)
    }
    
    func getFont18Bold() -> UIFont {
        return getCachedFont(baseSize: 18, weight: .bold)
    }
    
    // --- 字体大小 16 ---
    
    /// 字体大小 16 (例如：导航栏标题)
    func getFont16Semibold() -> UIFont {
        return getCachedFont(baseSize: 16, weight: .semibold)
    }
    
    func getFont16Medium() -> UIFont {
        return getCachedFont(baseSize: 16, weight: .medium)
    }
    
    func getFont16Bold() -> UIFont {
        return getCachedFont(baseSize: 16, weight: .bold)
    }
    
    func getFont16Regular() -> UIFont {
        return getCachedFont(baseSize: 16, weight: .regular)
    }
    
    func getFont15Semibold() -> UIFont {
        return getCachedFont(baseSize: 15, weight: .semibold)
    }
    
    func getFont15Regular() -> UIFont {
        return getCachedFont(baseSize: 15, weight: .regular)
    }

    // --- 字体大小 14 ---
    
    /// 字体大小 14 (例如：正文内容)
    func getFont14Regular() -> UIFont {
        return getCachedFont(baseSize: 14, weight: .regular)
    }
    /// 字体大小 14 (例如：表单中的值或重要副标题)
    func getFont14Semibold() -> UIFont {
        return getCachedFont(baseSize: 14, weight: .semibold)
    }
    
    // --- 字体大小 13 ---
    
    /// 字体大小 13 (例如：次要信息或表单标题)
    func getFont13Regular() -> UIFont {
        return getCachedFont(baseSize: 13, weight: .regular)
    }
    
    // --- 字体大小 12 ---
    
    /// 字体大小 12 (例如：提示文本或标签)
    func getFont12Medium() -> UIFont {
        return getCachedFont(baseSize: 12, weight: .medium)
    }
    
    /// 字体大小 12 (例如：Tab Bar 标题)
    func getFont12Regular() -> UIFont {
        return getCachedFont(baseSize: 12, weight: .regular)
    }
    
    func getFont12Semibold() -> UIFont {
        return getCachedFont(baseSize: 12, weight: .semibold)
    }
    
    // --- 字体大小 11 ---
    
    /// 字体大小 11 (例如：最小的版权信息或辅助说明)
    func getFont11Regular() -> UIFont {
        return getCachedFont(baseSize: 11, weight: .regular)
    }
    
    func getFont10Regular() -> UIFont {
        return getCachedFont(baseSize: 10, weight: .regular)
    }
    func getFont10Medium() -> UIFont {
        return getCachedFont(baseSize: 10, weight: .medium)
    }
}

// Extension to convert Font.Weight to string for font family names
extension UIFont.Weight {
    var fontWeightString: String {
        switch self {
        case .thin: return "Thin"
        case .light: return "Light"
        case .ultraLight: return "ExtraLight"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "Semibold"
        case .bold: return "Bold"
        case .heavy: return "Heavy" 
        case .black: return "Black"
        default: return "Regular"
        }
    }
}
