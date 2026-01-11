//
//  Storage.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import Foundation

@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return defaultValue
            }
            // 使用 JSONDecoder 还原对象
            return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            // 优化点：支持通过赋值 nil 来移除对象
            if let optional = newValue as? AnyOptional, optional.isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                if let data = try? JSONEncoder().encode(newValue) {
                    UserDefaults.standard.set(data, forKey: key)
                }
            }
            UserDefaults.standard.synchronize()
        }
    }
}

// 辅助协议：用于在 Property Wrapper 内部识别 Optional.none
private protocol AnyOptional { var isNil: Bool { get } }
extension Optional: AnyOptional { var isNil: Bool { self == nil } }
