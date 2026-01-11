//
//  NavigationUtility.swift
//  AL1
//
//  Created by cashlee on 2025/12/15.
//

import UIKit
import Foundation

class NavigationUtility
{
    // MARK: - 辅助属性：获取 Key Window
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows
                .filter { $0.isKeyWindow }
                .first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    static var windowWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // MARK: - 静态方法 1: 获取总的顶部安全区域高度
    
    /// 获取屏幕顶部的总高度：状态栏高度 + 导航栏高度。
    /// 适用于需要将内容锚定在导航栏底部时。
    static func totalTopSafeAreaHeight(for viewController: UIViewController? = nil) -> CGFloat {
        
        // 方案 A: 通过传入的 ViewController 获取 (最精确)
        if let nav = viewController?.navigationController {
            // navigationBar.frame.maxY 相当于 状态栏高度 + 导航栏高度
            return nav.navigationBar.frame.maxY
        }
        
        // 方案 B: 通过 Key Window 的安全区域获取状态栏高度，并加上标准的导航栏高度
        if #available(iOS 11.0, *), let topInset = keyWindow?.safeAreaInsets.top {
            // 假设标准的导航栏高度是 44.0 (非大标题模式)
            let standardNavBarHeight: CGFloat = 44.0
            return topInset + standardNavBarHeight
        }
        
        // 方案 C: Fallback 到旧的 UIApplication 状态栏高度
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let standardNavBarHeight: CGFloat = 44.0
        
        return statusBarHeight + standardNavBarHeight
    }
    
    // MARK: - 静态方法 2: 获取状态栏高度
    
    /// 获取状态栏的高度。
    static func statusBarHeight() -> CGFloat {
        if #available(iOS 11.0, *), let topInset = keyWindow?.safeAreaInsets.top {
            return topInset
        }
        return UIApplication.shared.statusBarFrame.height
    }
    
    static var topSafeAreaInset: CGFloat {
        return keyWindow?.safeAreaInsets.top ?? 0
    }
    
    // MARK: - 静态方法 3: 获取导航栏高度 (紧凑模式)
    
    /// 获取标准导航栏的高度 (通常是 44pt，不含状态栏)。
    /// ⚠️ 注意: 在大标题模式下，此值不准确。
    static func navigationBarHeight() -> CGFloat {
        return 44.0 // iOS 中标准的紧凑导航栏高度
    }
    
    static func totalBottomHeight() -> CGFloat {
        let window = UIApplication.shared.windows.first
        let safeBottom = window?.safeAreaInsets.bottom ?? 0
        // 49 是系统默认 TabBar 高度
        return safeBottom + 49
    }
}
