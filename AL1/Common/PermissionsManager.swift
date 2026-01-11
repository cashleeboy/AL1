//
//  PermissionsManager.swift
//  AL1
//
//  Created by cashlee on 2025/12/23.
//

import Foundation
import AVFoundation
import Photos
import UIKit

enum PermissionType {
    case camera
    case photoLibrary
}

class PermissionsManager {

    static let shared = PermissionsManager()
    private init() {}
    
    /// 授权结果回调，增加 isFirstTime 参数
    /// - isFirstTime: true 表示这是用户第一次触发系统弹窗并进行选择；false 表示之前已经选过了，现在只是查询或从设置返回。
    typealias PermissionCompletion = (_ granted: Bool, _ isFirstTime: Bool) -> Void

    func requestPermission(for type: PermissionType, completion: @escaping PermissionCompletion) {
        switch type {
        case .camera:
            checkCameraPermission(completion: completion)
        case .photoLibrary:
            checkPhotoLibraryPermission(completion: completion)
        }
    }

    private func checkCameraPermission(completion: @escaping PermissionCompletion) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        let isFirstTime = (status == .notDetermined)
        
        if status == .authorized {
            completion(true, isFirstTime)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted, isFirstTime) // 第一次请求，返回 true
                }
            }
        } else {
            completion(false, isFirstTime) // 之前已拒绝
        }
    }

    private func checkPhotoLibraryPermission(completion: @escaping PermissionCompletion) {
        // iOS 14+ 使用新的权限查询 API
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            handlePHStatus(status, completion: completion)
        } else {
            // iOS 13 及以下使用旧 API
            let status = PHPhotoLibrary.authorizationStatus()
            handlePHStatusLegacy(status, completion: completion)
        }
    }

    // 处理 iOS 14+ 状态
    @available(iOS 14, *)
    private func handlePHStatus(_ status: PHAuthorizationStatus, completion: @escaping PermissionCompletion) {
        switch status {
        case .authorized, .limited:
            completion(true, false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited, true)
                }
            }
        default:
            completion(false, false)
        }
    }

    // 处理 iOS 13 及以下状态
    private func handlePHStatusLegacy(_ status: PHAuthorizationStatus, completion: @escaping PermissionCompletion) {
        let isFirstTime = (status == .notDetermined)
        
        switch status {
        case .authorized:
            completion(true, isFirstTime)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized, isFirstTime)
                }
            }
        default:
            completion(false, isFirstTime)
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

