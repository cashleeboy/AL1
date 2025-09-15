//
//  BookingResponse.swift
//  MobileTest
//
//  Created by 李鸿章 on 2025/9/15.
//

import Foundation

enum BookingError: Error, LocalizedError {
    case fileNotFound
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .fileNotFound: return "Booking JSON not found in bundle."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .unknown: return "Unknown error."
        }
    }
}

struct BookingResponse: Codable {
    let shipReference: String
    let shipToken: String
    let canIssueTicketChecking: Bool
    let expiryTime: String   
    let duration: Int
    let segments: [Segment]
}

struct Segment: Codable {
    let id: Int
    let originAndDestinationPair: OriginAndDestinationPair
}

struct OriginAndDestinationPair: Codable {
    let destination: Destination
    let destinationCity: String
    let origin: Destination
    let originCity: String
}

struct Destination: Codable {
    let code: String
    let displayName: String
    let url: String
}
