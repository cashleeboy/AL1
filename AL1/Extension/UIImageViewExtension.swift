//
//  UIImageViewExtension.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit
import AlamofireImage

extension UIImageView {
    /// 加载网络图片
    /// - Parameters:
    ///   - url: 图片链接
    ///   - placeholder: 占位图（默认使用项目通用占位图）
    ///   - isCircle: 是否切圆角
    func loadImage(_ url: String?, placeholder: UIImage? = nil, isCircle: Bool = false) {
        let filter = isCircle ? AspectScaledToFillSizeWithRoundedCornersFilter(
            size: self.frame.size,
            radius: self.frame.width / 2
        ) : nil
        
        ImageLoader.shared.loadImage(
            into: self,
            url: url,
            placeholder: placeholder,
            filter: filter
        )
    }
}
