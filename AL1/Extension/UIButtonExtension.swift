//
//  UIButtonExtension.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit
import AlamofireImage

extension UIButton {
    
    /// 图片 和 title 的布局样式
    enum ImageTitleLayout {
        case imgTop
        case imgBottom
        case imgLeft
        case imgRight
    }
    
    // MARK: 3.1、设置图片和 title 的位置关系(提示：title和image要在设置布局关系之前设置)
    /// 设置图片和 title 的位置关系(提示：title和image要在设置布局关系之前设置)
    /// - Parameters:
    ///   - layout: 布局
    ///   - spacing: 间距
    /// - Returns: 返回自身
    func setImageTitleLayout(_ layout: ImageTitleLayout, spacing: CGFloat = 0) {
        switch layout {
        case .imgLeft:
            alignHorizontal(spacing: spacing, imageFirst: true)
        case .imgRight:
            alignHorizontal(spacing: spacing, imageFirst: false)
        case .imgTop:
            alignVertical(spacing: spacing, imageTop: true)
        case .imgBottom:
            alignVertical(spacing: spacing, imageTop: false)
        }
    }
    
    /// 水平方向
    /// - Parameters:
    ///   - spacing: 间距
    ///   - imageFirst: 图片是否优先
    private func alignHorizontal(spacing: CGFloat, imageFirst: Bool) {
        let edgeOffset = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -edgeOffset,
                                            bottom: 0,right: edgeOffset)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: edgeOffset,
                                            bottom: 0, right: -edgeOffset)
        if !imageFirst {
            transform = CGAffineTransform(scaleX: -1, y: 1)
            imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        contentEdgeInsets = UIEdgeInsets(top: 0, left: edgeOffset, bottom: 0, right: edgeOffset)
    }
    
    /// 垂直方向
    /// - Parameters:
    ///   - spacing: 间距
    ///   - imageTop: 图片是不是在顶部
    private func alignVertical(spacing: CGFloat, imageTop: Bool) {
        guard let imageSize = self.imageView?.image?.size,
              let text = self.titleLabel?.text,
              let font = self.titleLabel?.font
        else {
            return
        }
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: font])
        
        let imageVerticalOffset = (titleSize.height + spacing) / 2
        let titleVerticalOffset = (imageSize.height + spacing) / 2
        let imageHorizontalOffset = (titleSize.width) / 2
        let titleHorizontalOffset = (imageSize.width) / 2
        let sign: CGFloat = imageTop ? 1 : -1
        
        imageEdgeInsets = UIEdgeInsets(top: -imageVerticalOffset * sign,
                                            left: imageHorizontalOffset,
                                            bottom: imageVerticalOffset * sign,
                                            right: -imageHorizontalOffset)
        titleEdgeInsets = UIEdgeInsets(top: titleVerticalOffset * sign,
                                            left: -titleHorizontalOffset,
                                            bottom: -titleVerticalOffset * sign,
                                            right: titleHorizontalOffset)
        // increase content height to avoid clipping
        let edgeOffset = (min(imageSize.height, titleSize.height) + spacing) / 2
        contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0, bottom: edgeOffset, right: 0)
    }
}

extension UIButton {
    /// 加载按钮前景图片 (Image)
    /// - Parameters:
    ///   - url: 图片链接
    ///   - state: 按钮状态，默认 .normal
    ///   - placeholder: 占位图
    ///   - isCircle: 是否切圆角
    func loadImage(_ url: String?, for state: UIControl.State = .normal, placeholder: UIImage? = nil, isCircle: Bool = false) {
        guard let urlString = url, let imageURL = URL(string: urlString) else {
            self.setImage(placeholder, for: state)
            return
        }
        
        // 如果需要切圆角，配置过滤器
        let filter = isCircle ? AspectScaledToFillSizeWithRoundedCornersFilter(
            size: self.frame.size,
            radius: self.frame.width / 2
        ) : nil
        
        // AlamofireImage 提供的原生支持
        self.af.setImage(
            for: state,
            url: imageURL,
            placeholderImage: placeholder,
            filter: filter,
            completion:  { [weak self] response in
                // 可以在这里处理加载完成后的逻辑
                switch response.result {
                case .success(_):
//                    print("*** img = \(img)")
                    break
                case .failure(let error):
                    print("*** error = \(error)")
                    break
                }
            }
        )
    }
    
    /// 加载按钮背景图片 (BackgroundImage)
    func loadBackgroundImage(_ url: String?, for state: UIControl.State = .normal, placeholder: UIImage? = nil) {
        guard let urlString = url, let imageURL = URL(string: urlString) else {
            self.setBackgroundImage(placeholder, for: state)
            return
        }
        
        self.af.setBackgroundImage(
            for: state,
            url: imageURL,
            placeholderImage: placeholder
        )
    }
}
