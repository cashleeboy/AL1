//
//  TaskAggregator.swift
//  AL1
//
//  Created by cashlee on 2025/12/26.
//

import Foundation

enum TaskPriority {
    case core      // 核心任务：如果失败，最终聚合结果判定为失败
    case optional  // 可选任务：如果失败，结果为 nil，但不影响流程
}

struct TaskItem {
    let priority: TaskPriority
    let action: (@escaping (Result<Any, RequestError>) -> Void) -> Void
}

struct TaskAggregator {
    static func fetch(
        items: [TaskItem],
        completion: @escaping (Result<[Any?], RequestError>) -> Void
    ) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.app.taskAggregator.sync")
        
        var results: [Int: Any?] = [:]
        var firstCoreError: RequestError? // 记录第一个核心任务的错误

        for (index, item) in items.enumerated() {
            group.enter()
            
            // 执行包装的任务
            item.action { result in
                queue.async {
                    switch result {
                    case .success(let data):
                        results[index] = data
                    case .failure(let error):
                        if item.priority == .core {
                            // 如果是核心任务失败，且之前没记录过错误，则记录
                            if firstCoreError == nil { firstCoreError = error }
                        }
                        results[index] = nil // 失败的任务结果填 nil
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            if let error = firstCoreError {
                // 只要有任何一个核心任务失败，整体回调失败
                completion(.failure(error))
            } else {
                // 否则，按顺序组装结果返回（包含可选任务的 nil）
                let orderedResults = (0..<items.count).map { results[$0] ?? nil }
                completion(.success(orderedResults))
            }
        }
    }
}
