//
//  AppLocationProvider.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import CoreLocation
import UIKit

class AppLocationProvider: NSObject {
    
    static let shared = AppLocationProvider()
    private let locationManager = CLLocationManager()
    
    // 存储定位请求的回调
    private var locationHandler: ((CLLocation?, Error?) -> Void)?
    
    // 存储权限请求的回调（关键改进）
    private var permissionHandler: ((CLAuthorizationStatus) -> Void)?

    private override init() {
        super.init()
        locationManager.delegate = self
        // 针对借贷风控场景，建议百米精度，获取速度最快
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - 方法 1：请求定位权限
    /// 无论当前状态如何，都会通过 completion 返回最新状态
    func requestLocationPermission(completion: @escaping (CLAuthorizationStatus) -> Void) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        self.permissionHandler = completion
        if status == .notDetermined {
            // ⭐️ 如果未决定，保存回调，等待代理方法触发
            locationManager.requestWhenInUseAuthorization()
        } else {
            // 已有结果（允许或拒绝），直接同步返回
            completion(status)
        }
    }
    
    // MARK: - 方法 2：单次获取坐标
    func fetchCurrentLocation(completion: @escaping (CLLocation?, Error?) -> Void) {
        self.locationHandler = completion
        
        // 1. 检查全局开关
        guard CLLocationManager.locationServicesEnabled() else {
            completion(nil, NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "GPS服务未开启"]))
            return
        }
        
        // 2. 检查权限
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // 权限 OK，直接请求
            locationManager.requestLocation()
        } else if status == .notDetermined {
            // 如果没权限，先去请求权限，成功后再自动触发定位
            requestLocationPermission { [weak self] newStatus in
                if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                    self?.locationManager.requestLocation()
                } else {
                    completion(nil, NSError(domain: "LocationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "用户拒绝定位"]))
                }
            }
        } else {
            completion(nil, NSError(domain: "LocationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "无权限"]))
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AppLocationProvider: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationHandler?(location, nil)
        }
        locationHandler = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationHandler?(nil, error)
        locationHandler = nil
    }
    
    // 权限状态变更回调
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 当用户在系统弹窗点击了“允许”或“拒绝”后，此代理会触发
        if status != .notDetermined {
            // ⭐️ 触发保存的权限回调
            permissionHandler?(status)
            permissionHandler = nil
        }
    }
}
