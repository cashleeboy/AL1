//
//  ImagePickerManager.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import UIKit
import Photos
import Foundation

class ImagePickerManager: NSObject {
    static let shared = ImagePickerManager()
    
    private var completion: ((UIImage?) -> Void)?
    
    private override init() {}
    
    /// 打开相册
    /// - Parameters:
    ///   - viewController: 发起跳转的控制器
    ///   - completion: 选好图片后的回调
    func openGallery(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .fullScreen // 兼容 iOS 13 的卡片样式
        
        // 确保在主线程弹出
        DispatchQueue.main.async {
            viewController.present(picker, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 1. 获取选中的图片（优先获取编辑后的，没有则获取原图）
        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        
        // 2. 关闭相册
        picker.dismiss(animated: true) { [weak self] in
            self?.completion?(image)
            self?.completion = nil // 释放闭包防止内存泄漏
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.completion?(nil)
            self?.completion = nil
        }
    }
}
