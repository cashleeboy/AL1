//
//  UIImageExtension.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit
import AVFoundation

extension UIImage {
    func cropImage(to previewLayer: AVCaptureVideoPreviewLayer) -> UIImage {
        let outputRect = previewLayer.metadataOutputRectConverted(
            fromLayerRect: previewLayer.bounds
        )

        guard let cgImage = cgImage else { return self }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        let cropRect = CGRect(
            x: outputRect.origin.x * width,
            y: outputRect.origin.y * height,
            width: outputRect.size.width * width,
            height: outputRect.size.height * height
        )

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return self
        }

        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: imageOrientation)
    }
    
    func fixImageOrientation() -> UIImage {
        // 如果图片方向是正常的，直接返回
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        // 根据图片方向设置变换矩阵
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        // 处理镜像变换
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        // 创建上下文
        guard let cgImage = self.cgImage else { return self }
        let colorSpace = cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )
        
        guard let ctx = context else { return self }
        
        ctx.concatenate(transform)
        
        // 绘制图片到上下文
        let rect: CGRect
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
        default:
            rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        }
        ctx.draw(cgImage, in: rect)
        
        // 从上下文中创建新的图片
        guard let newCGImage = ctx.makeImage() else { return self }
        return UIImage(cgImage: newCGImage)
    }
}


// MARK: - UIImage Extension

extension UIImage {
    convenience init(imageLiteralResourceName name: String) {
        self.init(named: name)!
    }
}
