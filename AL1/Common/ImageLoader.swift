//
//  ImageLoader.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit
import Alamofire
import AlamofireImage

class ImageLoader {
    static let shared = ImageLoader()
    
    // 全局图片下载器，配置内存和磁盘缓存
    private let downloader: ImageDownloader
    
    private init() {
        // 配置缓存策略：200MB 内存，500MB 磁盘
        let imageCache = AutoPurgingImageCache(
            memoryCapacity: 200 * 1024 * 1024,
            preferredMemoryUsageAfterPurge: 150 * 1024 * 1024
        )
        
        downloader = ImageDownloader(
            configuration: ImageDownloader.defaultURLSessionConfiguration(),
            downloadPrioritization: .fifo,
            maximumActiveDownloads: 4,
            imageCache: imageCache
        )
    }
    
    /// 核心加载方法
    func loadImage(
        into imageView: UIImageView,
        url: String?,
        placeholder: UIImage? = UIImage(named: "placeholder_default"),
        filter: ImageFilter? = nil,
        completion: ((AFIDataResponse<UIImage>) -> Void)? = nil
    ) {
        guard let urlString = url, let imageURL = URL(string: urlString) else {
            imageView.image = placeholder
            return
        }
        
        imageView.af.setImage(
            withURL: imageURL,
            placeholderImage: placeholder,
            filter: filter,
//            imageTransition: .crossDissolve(0.3), // 默认转场动画
            completion: completion
        )
    }
}
