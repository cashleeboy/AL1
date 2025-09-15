//
//  BookingService.swift
//  MobileTest
//
//  Created by 李鸿章 on 2025/9/15.
//

import Foundation

protocol BookingServiceProtocol {
    func fetchBookings() async throws -> BookingResponse
}


class BookingService: BookingServiceProtocol {
    private let jsonFileName: String
    private let simulatedDelay: UInt64
    
    init(jsonFileName: String = "booking", simulatedDelaySeconds: UInt64 = 1) {
        self.jsonFileName = jsonFileName
        self.simulatedDelay = simulatedDelaySeconds * 1_000_000_000
    }

    func fetchBookings() async throws -> BookingResponse {
        
        try? await Task.sleep(nanoseconds: simulatedDelay)
 
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json") else {
            throw BookingError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let resp = try decoder.decode(BookingResponse.self, from: data)
            return resp
        } catch {
            throw BookingError.networkError(error)
        }
    }
}

