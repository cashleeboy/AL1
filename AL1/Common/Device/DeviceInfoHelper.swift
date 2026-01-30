//
//  DeviceInfoHelper.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import UIKit
import Foundation
import CoreTelephony
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import Alamofire

class DeviceInfoHelper
{
    // 1. 获取 App 信息
    static func fetchCurrentDeviceInfo() -> DeviceInfo {
        let infoDict = Bundle.main.infoDictionary
        let version = infoDict?["CFBundleShortVersionString"] as? String ?? ""
        let build = infoDict?["CFBundleVersion"] as? String ?? ""
        
        // 2. 获取屏幕尺寸
        let bounds = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let res = "\(Int(bounds.width * scale))x\(Int(bounds.height * scale))"
        
        // 4. 开机时长 (Uptime)
        let uptimeSecondsInt = Int(ProcessInfo.processInfo.systemUptime)
        let uptimeStr = "\(uptimeSecondsInt)"
        
        // 获取 IDFV
        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let idfa = AppIDFAProvider.shared.getIDFA()
        
        return DeviceInfo(
            deviceModel: getModelName(),
            deviceBrand: "Apple",
            osVersion: "iOS \(UIDevice.current.systemVersion)",
            deviceId: DeviceIDManager.getAdid(),
            appVersion: "iOS_\(version)",
            appBuildNumber: build,
            localTimezone: TimeZone.current.identifier,
            language: Locale.preferredLanguages.first ?? "en",
            screenSize: res,
            screenWidth: "\(bounds.width)",
            screenHeight: "\(bounds.height)",
            batteryLevel: batteryLevel,
            batteryState: isCharging ? 1 : 0,
            batteryPower: batteryLevel,
            isCharging: batteryStatusRawValue,
            idfv: idfv,
            idfa: idfa,
            networkType: getNetworkType(),
            carrierName: getCarrierName(),
            ipAddress: getIPAddress() ?? "0.0.0.0",
            currentTime: "\(Int(Date().timeIntervalSince1970))",
            bootTime: uptimeStr,
            isJailbroken: isJailbroken,
        )
    }
    
    // 私有辅助方法：获取具体型号名称
    private static func getModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        } 
        return identifier // 返回如 "iPhone13,4"
    }

    // 私有辅助方法：获取越狱状态
    private static func checkJailbreak() -> Bool {
        return isJailbroken
    }
    
    /// 是否为模拟器
    private static var isSimulator: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
    
    private static var isJailbroken: Bool {
        if isSimulator {
            return false
        }
        let paths = ["/Applications/Cydia.app","/private/var/lib/apt/","/private/var/lib/cydia","/private/var/stash"]
        for path in paths { if FileManager.default.fileExists(atPath: path) { return true } }
        if let fileHandler = fopen("/bin/bash", "r") { fclose(fileHandler); return true }
        let path = "/private/\(UUID())"
        do { try "".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {  }
        return false
    }
    
    
    private static func getBatteryState(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: return "Charging"
        case .full: return "Full"
        case .unplugged: return "Unplugged"
        default: return "Unknown"
        }
    }
    
    /// 是否正在充电
    static var isCharging: Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState
        UIDevice.current.isBatteryMonitoringEnabled = false
        return state == .charging || state == .full
    }
    
    /// 剩余电量（百分比）
    static var batteryLevel: Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let battery = UIDevice.current.batteryLevel
        UIDevice.current.isBatteryMonitoringEnabled = false
        return battery < 0 ? 0 : Int(battery * 100)
    }
    
    /// 映射电池状态：1：未知；2：充电中； 3：放电中；4：未充电；5：充满
    static var batteryStatusRawValue: Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState
        var batteryState = 1
        switch state {
        case .unknown:
            batteryState = 1
        case .charging:
            batteryState = 2
        case .unplugged:
            batteryState = 3
        case .full:
            batteryState = 5
        @unknown default:
            batteryState = 1
        }
        return batteryState
    }
    
    
    // 注意：获取 IP 地址通常涉及底层 C 代码（ifaddrs），此处省略具体实现以保持简洁
//    private static func getIPAddress() -> String? {
//        return "192.168.1.1"
//    }
    private static func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) { // IPv4
                    let name = String(cString: (interface?.ifa_name)!)
                    if name == "en0" { // WiFi 接口
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    private static func getNetworkType() -> String {
        // 这里应使用 NWPathMonitor 来判断 WiFi 还是蜂窝
        return networkType
    }
    
    static var wifiInfo: (name: String?, macAddress: String?) {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return (nil, nil)
        }
        
        for interface in interfaces {
            guard let info = CFBridgingRetain(CNCopyCurrentNetworkInfo(interface as CFString)) as? [String: Any] else {
                continue
            }
            return (info["SSID"] as? String, info["BSSID"] as? String)
        }
        
        return (nil, nil)
    }
    
    private static func getCarrierName() -> String {
        return carrierName
    }
}

// 网络状态
extension DeviceInfoHelper {
    static var cellularNetworkType: String {
        let telephonyInfo = CTTelephonyNetworkInfo()

        // Handle iOS 12 and later using serviceCurrentRadioAccessTechnology
        if #available(iOS 12.0, *) {
            if let technologies = telephonyInfo.serviceCurrentRadioAccessTechnology {
                for (_, technology) in technologies {
                    return mapRadioAccessTechnology(technology)
                }
            }
        } else {
            // Fallback for iOS versions below 12
            if let technology = telephonyInfo.currentRadioAccessTechnology {
                return mapRadioAccessTechnology(technology)
            }
        }

        return "UNKNOWN"
    }
    
    private static func mapRadioAccessTechnology(_ technology: String) -> String {
        switch technology {
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge:
            return "2G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMA1x, CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyLTE:
            return "4G"
        case let tech :
            if #available(iOS 14.1, *) {
                if tech == CTRadioAccessTechnologyNR || tech == CTRadioAccessTechnologyNRNSA {
                    return "5G"
                }
            } else {
                // Fallback on earlier versions
            }
            fallthrough
        default:
            return "OTHER"
        }
    }
    
    /// Comprehensive network type (WiFi or specific cellular type)
    static var networkType: String {
        guard let reachabilityManager = NetworkReachabilityManager() else {
            return "UNKNOWN"
        }

        if reachabilityManager.isReachable {
            if reachabilityManager.isReachableOnEthernetOrWiFi {
                return "WIFI"
            } else if reachabilityManager.isReachableOnCellular {
                return cellularNetworkType
            }
        } else {
            return "No Connection"
        }

        return "OTHER"
    }

    static var carrierName: String {
        let telephonyInfo = CTTelephonyNetworkInfo()
        
        // 检查 serviceSubscriberCellularProviders 是否有数据
        if #available(iOS 12.0, *) {
            let providers = telephonyInfo.serviceSubscriberCellularProviders
            // 使用 sorted 确保多卡时顺序相对固定，或者通过 serviceCurrentRadioAccessTechnology 匹配当前活跃卡
            let name = providers?.values
                .compactMap({ $0.carrierName })
                .first(where: { !$0.isEmpty })
            return name ?? "--"
        } else {
            return telephonyInfo.subscriberCellularProvider?.carrierName ?? "--"
        }
    }
}
