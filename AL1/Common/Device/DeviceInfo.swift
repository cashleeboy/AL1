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

struct DeviceInfo {
    // 设备基础信息
    let deviceModel: String
    let osVersion: String
    let deviceId: String
    
    // App 信息
    let appVersion: String
    let appBuildNumber: String
    
    // 环境与区域
    let localTimezone: String
    let language: String
    let screenSize: String
    
    // 电池状态
    let batteryLevel: Int
    let batteryState: Int
    
    // 网络相关
    let networkType: String    // 4G / 5G / etc.
    let carrierName: String
//    let connectionType: String // 4G / 5G / etc.
    let ipAddress: String
//    let connectionSpeed: String // 通常需要单独测速逻辑，这里预留占位
    
    // 系统状态
    let currentTime: String
    let bootTime: String
//    let isJailbroken: String
    
    /// 将所有属性转换为 [String: String] 字典
    /*
     - zGpbi9e_5rM body    true 用户上传数据请求对象
        - jPpDL2tisdQHoAurev false 请求设备信息对象
     
            - qjMmruhjLQop7 设备型号,示例值(deviceModel)
            - hPwQjcIzekdGPSrSR 设备品牌,示例值(deviceBrand)
            - m71TMNCxOlsp 设备id,示例值(deviceId)
     
            - lKNYK5 version :cKkElaYUF_17 : lKNYK5: 版本：默认传v1,示例值(version)
            - mgkeUyzUHHGmht type :mrpZzFdnAkFAAX7ZrZF : mgkeUyzUHHGmht: builder类型,示例值(type)
            
            - bG3RmPUIqylHzn 时区,示例值(time_zone)
            - bNgUmtc4d 本地语言,示例值(language)
            - pueFc5ruBO2jZtkF 设备分辨率
     
            - nD11iX6hOY 电量百分比，传数字整型
            - alfQJMy248tkn  是否正在充电:0-否，1-是,示例值(isCharging)
     
            - pNG53btUd internet_type :yVNuk_eI : pNG53btUd: 网络类型,示例值(internet_type)
            - peNVkgrNROOLjZsjPwP 网络运营商名称,示例值(networkOperatorName)
            - xiQ4j84soH ip address
     
            - hOdEboUQzlF1uzn9Q 编译时间,示例值(time)
            - bWgfnfmd01 开机时长,示例值(boot_time)
     */
    func toDictionary() -> [String: Any] {
        return [
//            "zGpbi9e_5rM" : [
                "jPpDL2tisdQHoAurev" : [
                    "qjMmruhjLQop7": deviceModel,
                    "hPwQjcIzekdGPSrSR": osVersion,
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
                ]
//            ]
        ]
    }
    
    
//                "isJailbroken": isJailbroken
}
