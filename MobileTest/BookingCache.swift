//
//  BookingCache.swift
//  MobileTest
//
//  Created by 李鸿章 on 2025/9/15.
//

import Foundation

class BookingCache {
    private let cacheFileURL: URL
    private let queue = DispatchQueue(label: "booking.cache.queue")

    struct CacheContainer: Codable {
        let timestamp: Date
        let response: BookingResponse
    }

    init(filename: String = "booking_cache.json") {
        let fm = FileManager.default
        let folder = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheFileURL = folder.appendingPathComponent(filename)
    }

    func loadCache() -> BookingResponse? {
        var result: BookingResponse?
        queue.sync {
            guard FileManager.default.fileExists(atPath: cacheFileURL.path) else {
                result = nil
                return
            }
            do {
                let data = try Data(contentsOf: cacheFileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let container = try decoder.decode(CacheContainer.self, from: data)
                result = container.response
            } catch {
                print("[BookingCache] load failed:", error)
                result = nil
            }
        }
        return result
    }

    func loadCacheWithTimestamp() -> (response: BookingResponse, timestamp: Date)? {
        var res: (BookingResponse, Date)?
        queue.sync {
            guard FileManager.default.fileExists(atPath: cacheFileURL.path) else { return }
            do {
                let data = try Data(contentsOf: cacheFileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let container = try decoder.decode(CacheContainer.self, from: data)
                res = (container.response, container.timestamp)
            } catch {
                print("[BookingCache] loadWithTimestamp failed:", error)
            }
        }
        return res
    }

    func save(response: BookingResponse) throws {
        try queue.sync {
            let container = CacheContainer(timestamp: Date(), response: response)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(container)
            try data.write(to: cacheFileURL, options: [.atomic])
        }
    }

}
