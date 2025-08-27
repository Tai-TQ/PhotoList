//
//  APIService.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Foundation

public enum APIServiceError: Error {
    case invalidURL
    case timeout
    case noInternetConnection
    case serverUnavailable
    case decodingError
    case networkError(String)
    case unknown(String)
}

extension APIServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .timeout:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection"
        case .serverUnavailable:
            return "Server is unavailable"
        case .decodingError:
            return "Failed to decode response"
        case let .networkError(message):
            return "Network error: \(message)"
        case let .unknown(message):
            return "Unknown error: \(message)"
        }
    }
}

public final class APIService: @unchecked Sendable {
    public static let shared = APIService()
    private init() {}
}
