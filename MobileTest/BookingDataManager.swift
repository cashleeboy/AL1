//
//  BookingDataManager.swift
//  MobileTest
//
//  Created by 李鸿章 on 2025/9/15.
//

import Foundation
import Combine

final class BookingDataManager {
    let segmentsPublisher = CurrentValueSubject<[Segment], Never>([])
    let errorPublisher = PassthroughSubject<Error, Never>()

    private let ttl: TimeInterval
    private let service: BookingServiceProtocol
    private let cache: BookingCache
    private var lastCacheTimestamp: Date?
    private var refreshTask: Task<Void, Never>?

    init(service: BookingServiceProtocol = BookingService(),
         cache: BookingCache = BookingCache(),
         ttl: TimeInterval = 200) {
        self.service = service
        self.cache = cache
        self.ttl = ttl

        if let (resp, ts) = cache.loadCacheWithTimestamp() {
            lastCacheTimestamp = ts
            segmentsPublisher.send(resp.segments)
        }
    }

    private func isCacheFresh() -> Bool {
        guard let ts = lastCacheTimestamp else { return false }
        return Date().timeIntervalSince(ts) <= ttl
    }

    func fetch(forceRefresh: Bool = false) async -> Result<[Segment], Error> {
        if !forceRefresh, isCacheFresh() {
            return .success(segmentsPublisher.value)
        }

        if let (resp, ts) = cache.loadCacheWithTimestamp(), !forceRefresh {
            lastCacheTimestamp = ts
            segmentsPublisher.send(resp.segments)
            Task {
                await self.refreshFromNetwork()
            }
            return .success(resp.segments)
        }

        do {
            let resp = try await service.fetchBookings()
            try cache.save(response: resp)
            lastCacheTimestamp = Date()
            segmentsPublisher.send(resp.segments)
            return .success(resp.segments)
        } catch {
            errorPublisher.send(error)
            return .failure(error)
        }
    }

    func refreshFromNetwork() async -> Result<[Segment], Error> {
        refreshTask?.cancel()
        let task = Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let resp = try await self.service.fetchBookings()
                try self.cache.save(response: resp)
                self.lastCacheTimestamp = Date()
                self.segmentsPublisher.send(resp.segments)
            } catch {
                self.errorPublisher.send(error)
            }
        }
        refreshTask = task
        return .success(segmentsPublisher.value)
    }
}
