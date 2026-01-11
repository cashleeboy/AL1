//
//  MZDateUitl.swift
//  MZDatePicker
//
//  Created by 曾龙 on 2021/12/27.
//

import Foundation

struct MZDateUtil {
    
    // MARK: - 常用格式化器 (静态属性提高性能)
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    // MARK: - Date 转 字符串
    
    /// 将 Date 转换为指定格式的字符串 (默认 yyyy-MM-dd)
    static func string(from date: Date, format: String = "dd-MM-yyyy") -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // MARK: - 字符串 转 Date
    
    /// 将字符串转换为 Date
    static func date(from string: String, format: String = "dd-MM-yyyy") -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    // MARK: - 业务常用方法
    
    /// 计算两个日期之间的年龄 (用于校验是否成年)
    static func getAge(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
    
    /// 判断是否为今天
    static func isToday(date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    /// 获取日期的特定组件 (年, 月, 日)
    static func getComponent(from date: Date) -> (year: Int, month: Int, day: Int) {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return (comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }
}
