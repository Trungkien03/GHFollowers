//
//  NetworkError.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 3/12/25.
//

import Foundation

// MARK: - Network Error (User-Friendly Errors)
enum NetworkError: Error {
    case invalidURL
    case transport(Error)  // low-level connection error (no internet, timeout...)
    case server(statusCode: Int)  // Non-200 status code received
    case noData  // Response received but empty
    case invalidResponse
    case invalidData
    case decoding(Error)  // JSON decoding failed
    case cancelled  // Task was cancelled
}
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."

        case .transport(let err):
            return "Network error: \(err.localizedDescription)"

        case .server(let statusCode):
            return "Server responded with an error: \(statusCode)."

        case .noData:
            return "No data received from the server."

        case .decoding:
            return "Failed to decode the server response."

        case .cancelled:
            return "The request was cancelled."

        case .invalidResponse:
            return "Invalid response from the server."

        case .invalidData:
            return "The data received from the server is invalid."
        }
    }
}

enum PersistenceError: Error, LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case noData
    case alreadyExists
    case unableToFavorite(Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode the data."
        case .decodingFailed:
            return "Failed to decode the data."
        case .noData:
            return "No data to decode."
        case .alreadyExists:
            return "The item you are trying to save already exists."
        case .unableToFavorite:
            return "There was an error favoriting this user. Please try again."
        }
    }
}
