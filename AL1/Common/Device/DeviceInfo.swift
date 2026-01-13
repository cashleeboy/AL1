//
//  DeviceInfo.swift
//  AL1
//
//  Created by cashlee on 2025/12/29.
//

import UIKit
import CoreTelephony // 用于获取运营商（部分 API 在 iOS 16+ 已弃用）
import Network       // 用于网络监测
import AdSupport     // 如果需要 IDFA

// 设备基础信息
struct DeviceInfo {
    let deviceModel: String
    let deviceBrand: String
    let osVersion: String
    let deviceId: String
    
    // App 信息
    let appVersion: String
    let appBuildNumber: String
    
    // 环境与区域
    let localTimezone: String
    let language: String
    let screenSize: String
    let screenWidth: String
    let screenHeight: String
    
    // 电池状态
    let batteryLevel: Int
    let batteryState: Int
    let batteryPower: Int       // 电池电量
    let isCharging: Int    // 是否正在充电 1：未知状态；2：充电中； 3：放电中；4：未充电；5：充满,示例值(is_charging)
    
    let idfv: String
    let idfa: String
    
    // 网络相关
    let networkType: String    // 4G / 5G / etc.
    let carrierName: String
    let ipAddress: String

    // 系统状态
    let currentTime: String
    let bootTime: String
    
    let isJailbroken: Bool

    func toDictionary() -> [String: Any] {
        return [
            "jPpDL2tisdQHoAurev" : [
                "qjMmruhjLQop7": deviceModel,
                "hPwQjcIzekdGPSrSR": deviceBrand,
                "rAsevvCXL": osVersion,
                "m71TMNCxOlsp": deviceId,
                
                "lKNYK5": appVersion,
                "mgkeUyzUHHGmht": appBuildNumber,
                
                "bG3RmPUIqylHzn": localTimezone,
                "bNgUmtc4d": language,
                "pueFc5ruBO2jZtkF": screenSize,
                
                "nD11iX6hOY": batteryLevel,
                "alfQJMy248tkn": batteryState,
                
                "pNG53btUd": networkType,
                "peNVkgrNROOLjZsjPwP": carrierName,
                "xiQ4j84soH": ipAddress,
                
                "hOdEboUQzlF1uzn9Q": currentTime,
                "bWgfnfmd01": bootTime,
                
                "mBXE4_rUGFJ": screenWidth,
                "thyVxbWcKDxro7Scum": screenHeight,
                "hJ0hmr1P4IKWlEy1R00": batteryLevel,      // battery_power
                "sn2fglK": isCharging,      //is_charging
                
                "tnucFGUZssOMpxCI": idfa,     // ios 系统 idfa,示例值(idfa)
                "teL0nVZnJRF67ekcH": idfv,    // ios 系统 idfv,示例值(idfv)
                
                "rqcMyAWfgacgpQ9_tv": "1",        // 客户端类型 0=安卓 1=IOS,示例值(client_type)
                "wu2I1apv4mZnxxNxNVLh": isJailbroken
            ]
        ]
    }
    
    
//                "isJailbroken": isJailbroken
}
