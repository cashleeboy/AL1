//
//  SequenceExtension.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import Foundation


extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Sequence where Element: Numeric {
    /// 对序列中的所有元素进行求和
    func sum() -> Element {
        return reduce(0, +)
    }
}

// 使用方式：一行代码直接搞定
// let totalSum = info.products.sum(for: \.totalDays)
extension Sequence {
    /// 根据指定的键路径（KeyPath）对元素进行映射并求和
    func sum<T: Numeric>(for keyPath: KeyPath<Element, T>) -> T {
        return reduce(0) { $0 + $1[keyPath: keyPath] }
    }
}


extension Encodable {
    /// 将模型转换为字典，遵循 CodingKeys 的映射规则
    var toDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any]
    }
}
