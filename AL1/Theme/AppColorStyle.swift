//
//  AppColorStyle.swift
//  AL1
//
//  Created by cashlee on 2025/12/12.
//

import UIKit

class AppColorStyle: NSObject {
    static let shared = AppColorStyle()
    // 私有初始化器，防止外部创建实例
    private override init() {}
    
    /// 橙色主题色 (Primary Brand Color): #FF7307
    var brandPrimary: UIColor {
        // R: 255, G: 115, B: 7
        return UIColor(hex: "#FF7307")
    }
    
    var lightBrandPrimary: UIColor {
        return UIColor(hex: "#FFF7F1")
    }
    
    var brandSecondary: UIColor {
        return UIColor(hex: "#FEF9F6")
    }
    
    /// Primary 禁用状态色 (Primary Disable): #FFC99F
    var brandPrimaryDisabled: UIColor {
        // R: 255, G: 201, B: 159
        return UIColor(hex: "#FFC99F")
    }
    
    /// 纯白色 (White): #FFFFFF
    var backgroundWhite: UIColor {
        return UIColor(hex: "#FFFFFF")
    }
    
    var backgroundWhiteF0: UIColor {
        return UIColor(hex: "#F0F0F0")
    }
    
    var backgroundWhiteF2: UIColor {
        return UIColor(hex: "#F2F2F2")
    }
    
    // MARK: - 字体和文本颜色 (Text & Icon)
    
    /// 纯黑色 (Main Heading/Primary Text): #000000
    var textBlack: UIColor {
        return UIColor(hex: "#000000")
    }
    
    var textBlack33: UIColor {
        return UIColor(hex: "#333333")
    }
    
    var textBlack1C: UIColor {
        return UIColor(hex: "#1C1C1C")
    }
    
    /// 主要内容文本色: #1E1E1E
    var textPrimary: UIColor {
        return UIColor(hex: "#1E1E1E")
    }
    
    /// 副标题/次要信息文本色 (Subtitle/Secondary Text): #ABA2A2
    var textSecondary: UIColor {
        return UIColor(hex: "#ABA2A2")
    }
    
    /// 通用深色文本/背景色: #202020
    var textDarkGeneral: UIColor {
        return UIColor(hex: "#202020")
    }
    
    /// 按钮/图标等中等深色: #3A3A3A
    var textDarkMedium: UIColor {
        return UIColor(hex: "#3A3A3A")
    }
    
    var textBlack50: UIColor {
        return UIColor(hex: "#505050")
    }
    
    var texBlack33: UIColor {
        return UIColor(hex: "#333333")
    }
    
    var texBlack37: UIColor {
        return UIColor(hex: "#373737")
    }
    
    var texBlackDialog: UIColor {
        return UIColor(hex: "#262626")
    }
    
    /// 卡片/背景等深色: #262626
    var textDarkCard: UIColor {
        return UIColor(hex: "#262626")
    }
    
    var textGray: UIColor {
        return UIColor(hex: "#999999")
    }
    
    var textGrayF6: UIColor {
        return UIColor(hex: "#F6F6F6")
    }
    
    var textGray66: UIColor {
        return UIColor(hex: "#666666")
    }
    
    var textGrayED: UIColor {
        return UIColor(hex: "#EDEDED")
    }
    
    var textGrayD9: UIColor {
        return UIColor(hex: "#D9D9D9")
    }
    var textGrayDF: UIColor {
        return UIColor(hex: "#DFDFDF")
    }
    
    var textGray8E: UIColor {
        return UIColor(hex: "#8E8E8E")
    }
    
    var textGrayA3: UIColor {
        return UIColor(hex: "#A3A3A3")
    }
    
    var textGray94: UIColor {
        return UIColor(hex: "#949494")
    }
    
    var textGrayCE: UIColor {
        return UIColor(hex: "#CECECE")
    }
    
    var textGrayF7: UIColor {
        return UIColor(hex: "#F7F7F7")
    }
    /// 灰色文本或图标色: #A4A4A4
    var textGrayMedium: UIColor {
        return UIColor(hex: "#A4A4A4")
    }
    
    /// 较深的灰色文本或描边色: #8E8E8E
    var textGrayDark: UIColor {
        return UIColor(hex: "#8E8E8E")
    }
    
    var textGrayForm: UIColor {
        UIColor(hex: "#9093A1")
    }
    
    /// 错误/警示色 (Error/Alert): #FF3232
    var semanticError: UIColor {
        return UIColor(hex: "#FF3232")
    }
    
    /// 特殊灰色文本/图标色: #8B97A5
    var textGraySpecial: UIColor {
        return UIColor(hex: "#8B97A5")
    }
    
    // MARK: - 背景色 (Background)
    
    /// 主要页面背景色 (Light Gray): #F4F4F4
    var backgroundPagePrimary: UIColor {
        return UIColor(hex: "#F4F4F4")
    }
    
    /// 次要背景色 (Slightly Lighter Gray): #F6F6F6
    var backgroundPageSecondary: UIColor {
        return UIColor(hex: "#F6F6F6")
    }
    
    var backgroundLightGray: UIColor {
        return UIColor(hex: "#F2F2F2")
    }
    
    var activeBackground: UIColor {
        return UIColor(hex: "#FF790A")
    }
    var inactiveBackground: UIColor {
        return UIColor(hex: "#FFDBC3")
    }
    
    
    // MARK: - 渐变色定义
    
    /// 创建主品牌色的 CAGradientLayer
    /// CSS: linear-gradient(182.62deg, #FF7A0E 3.61%, #FEA626 55.97%, rgba(243, 204, 62, 0) 93.06%)
    /// - Parameter bounds: 渐变将要覆盖的视图的 Bounds
    /// - Returns: 配置好的 CAGradientLayer
    func brandPrimaryGradientLayer(in bounds: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        // 1. 颜色 (Colors)
        let color1 = UIColor(hex: "#FF7A0E").cgColor // 橙红
        let color2 = UIColor(hex: "#FEA626").cgColor // 中橙
        let color3 = UIColor(hex: "#F3CC3E").withAlphaComponent(0).cgColor // 透明黄
        
        gradientLayer.colors = [color1, color2, color3]
        
        // 2. 停止点 (Locations)
        // CSS 百分比转换为 CGFloat (0.0 - 1.0)
        gradientLayer.locations = [
            0.0361 as NSNumber, // 3.61%
            0.5597 as NSNumber, // 55.97%
            0.9306 as NSNumber  // 93.06%
        ]
        
        // 3. 起点和终点 (Start/End Points)
        // CSS 182.62deg 转换为 CGPoints。
        // 180度是垂直向下 (.5, 0) -> (.5, 1)。182.62度稍微偏右下角。
        
        // 我们需要使用三角函数来精确计算 182.62 度的起点和终点，
        // 但为了简化和实际应用，通常使用近似值：
        
        // 182.62度 ≈ 垂直向下
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 顶部中心
        gradientLayer.endPoint = CGPoint(x: 0.55, y: 1.0)  // 底部略偏右
        
        return gradientLayer
    }
    
    
    /// 可选：如果需要在背景图片中使用，返回 UIImage
    func brandPrimaryGradientImage(size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            let gradientLayer = brandPrimaryGradientLayer(in: CGRect(origin: .zero, size: size))
            // 渲染 Layer 到 Image Context
            gradientLayer.render(in: rendererContext.cgContext)
        }
    }
    
    /**
     创建配置好的 CAGradientLayer。
     
     - Parameters:
     - bounds: 渐变将要覆盖的视图的 Bounds。
     - colors: 用于渐变的颜色数组。如果数组为空，则使用默认的品牌颜色。
     - Returns: 配置好的 CAGradientLayer。
     */
    func brandPrimaryGradientLayer(in bounds: CGRect, colors: [UIColor] = []) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        // 检查是否提供了颜色，否则使用默认配置
        let finalColors = colors.isEmpty ? PrimaryGradientConfig.defaultColors : colors
        
        // 1. 设置颜色
        gradientLayer.colors = finalColors.map { $0.cgColor }
        
        // 2. 设置 Locations (如果颜色数量不等于默认 Locations 数量，则省略 Locations)
        if finalColors.count == PrimaryGradientConfig.defaultLocations.count {
            gradientLayer.locations = PrimaryGradientConfig.defaultLocations
        } else {
            // 如果提供了自定义颜色，但没有提供 Locations，系统会均匀分布
        }
        
        // 3. 设置起止点
        gradientLayer.startPoint = PrimaryGradientConfig.startPoint
        gradientLayer.endPoint = PrimaryGradientConfig.endPoint
        
        return gradientLayer
    }
}

private struct PrimaryGradientConfig {
    // 原始 CSS: linear-gradient(182.62deg, #FF7A0E 3.61%, #FEA626 55.97%, rgba(243, 204, 62, 0) 93.06%)
    
    // 颜色 (UIColor 数组)
    static let defaultColors: [UIColor] = [
        UIColor(hex: "#FF7A0E"), // 橙红
        UIColor(hex: "#FEA626"), // 中橙
        // 假设你需要处理透明度，这里使用带透明度的颜色
        UIColor(hex: "#F3CC3E").withAlphaComponent(0) // 透明黄
    ]
    
    // 停止点 (Locations)
    static let defaultLocations: [NSNumber] = [
        0.0361 as NSNumber, // 3.61%
        0.5597 as NSNumber, // 55.97%
        0.9306 as NSNumber  // 93.06%
    ]
    
    // 起点和终点 (182.62度 ≈ 垂直向下略偏右)
    static let startPoint = CGPoint(x: 0.5, y: 0.0)
    static let endPoint = CGPoint(x: 0.55, y: 1.0)
}
