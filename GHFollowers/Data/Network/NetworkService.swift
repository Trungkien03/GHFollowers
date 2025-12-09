//
//  NetworkService.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import Foundation


// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    var session: URLSession { get }
    func fetch<T: Decodable>(_ endpoint: Endpoint, _ baseURL: URL) async throws
        -> T
    func fetchData(_ endpoint: Endpoint, _ baseURL: URL) async throws -> Data
}

final class NetworkService: NetworkServiceProtocol {
    var session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// this method is used to fetching data from API
    func fetchData(_ endpoint: Endpoint, _ baseURL: URL) async throws -> Data {
        let request = try endpoint.makeRequest(baseURL: baseURL)

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.server(statusCode: http.statusCode)
            }

            return data
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.transport(error)
        }
    }

    /// this method is used to decode the data after fetching the data
    func fetch<T: Decodable>(_ endpoint: Endpoint, _ baseURL: URL) async throws
        -> T
    {
        let data = try await fetchData(endpoint, baseURL)

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            logDecodingError(error, data: data)
            throw NetworkError.decoding(error)
        }
    }

    /// helper function is used to log decode error
    private func logDecodingError(_ error: Error, data: Data) {
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                print(
                    "Type mismatch for type \(type) — \(context.debugDescription)"
                )
                print("CodingPath: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print(
                    "Value not found for type \(type) — \(context.debugDescription)"
                )
                print("CodingPath: \(context.codingPath)")
            case .keyNotFound(let key, let context):
                print(
                    "Key '\(key.stringValue)' not found: \(context.debugDescription)"
                )
                print("CodingPath: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
                print("CodingPath: \(context.codingPath)")
            @unknown default:
                print(
                    "Unknown decoding error: \(decodingError.localizedDescription)"
                )
            }
        } else {
            print("Other decode error: \(error.localizedDescription)")
        }

        if let jsonStr = String(data: data, encoding: .utf8) {
            print("---- Raw JSON ----\n\(jsonStr)\n---- end ----")
        }
    }

}
