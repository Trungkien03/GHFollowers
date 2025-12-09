//
//  EndPoint.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 3/12/25.
//

import Foundation

/// Endpoint describes a single HTTP request configuration
/// This allow to avoid hardcoding URLs inside NetworkManager
protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

extension Endpoint {
    func makeRequest(baseURL: URL, timeout: TimeInterval = 30) throws
        -> URLRequest
    {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.httpBody = body

        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}
