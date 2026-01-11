//
//  AppLocationProvider.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import Foundation
import CoreLocation
import UIKit

class AppLocationProvider: NSObject {
    
    static let shared = AppLocationProvider()
    private let locationManager = CLLocationManager()
    
    // 异步回调获取坐标
    private var locationHandler: ((CLLocation?, Error?) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        // 设置精度（针对借贷/风控场景，建议使用百米精度即可，省电且快）
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - 方法 1：请求定位权限
    /// 建议在 App 启动或进入特定业务前调用
    func requestLocationPermission(completion: ((CLAuthorizationStatus) -> Void)? = nil) {
        let status: CLAuthorizationStatus
        
        // iOS 14.0+ 权限 API 发生了变化
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            // 请求前台定位权限
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("定位权限被拒绝")
        case .authorizedAlways, .authorizedWhenInUse:
            print("定位权限已授权")
        @unknown default:
            break
        }
        completion?(status)
    }
    
    // MARK: - 方法 2：单次获取坐标
    /// 仅在有权限时调用。该方法获取一次结果后会自动停止硬件工作。
    func fetchCurrentLocation(completion: @escaping (CLLocation?, Error?) -> Void) {
        self.locationHandler = completion
        
        // 1. 检查系统全局开关
        guard CLLocationManager.locationServicesEnabled() else {
            completion(nil, NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Servicio de ubicación desactivado"]))
            return
        }
        
        // 2. 检查 App 自身权限状态
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // 权限已就绪，切到后台队列触发请求，避免阻塞主线程 UI
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.locationManager.requestLocation()
            }
            
        case .notDetermined:
            // 还没请求过权限，先去请求权限
            locationManager.requestWhenInUseAuthorization()
            // 注意：请求权限后，结果会在代理方法 didChangeAuthorization 中返回
            // 你可以在代理方法里再次调用 fetchCurrentLocation
            
        case .denied, .restricted:
            completion(nil, NSError(domain: "LocationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sin permiso de ubicación"]))
            
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AppLocationProvider: CLLocationManagerDelegate {
    
    // 处理获取到的位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("*** 定位成功: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            locationHandler?(location, nil)
        }
        locationHandler = nil // 清空闭包，防止重复回调
    }
    
    // 处理定位失败（requestLocation 必须实现此代理）
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("*** 定位失败: \(error.localizedDescription)")
        locationHandler?(nil, error)
        locationHandler = nil
    }
    
    // 监听权限变化 (兼容 iOS 13 & 14+)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // 权限通过后的逻辑（如果需要自动触发获取可以加在这里）
        }
    }
}
