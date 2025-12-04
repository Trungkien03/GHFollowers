//
//  EndPoint.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 3/12/25.
//

import Foundation

// MARK: - Endpoint Protocol
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

// MARK: - Example Endpoint (GitHub Followers)
/// A strongly-typed endpoint for GitHub Followers API.
struct GitHubFollowersEndpoint: Endpoint {
    let username: String
    let page: Int

    var path: String { "/users/\(username)/followers" }
    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "100"),
        ]
    }

    var headers: [String: String]? {
        ["Accept": "application/vnd.github.v3+json"]
    }

    var body: Data? { nil }
}

// MARK: -  Endpoint (GitHub Users)
struct GithubUsersEndpoint: Endpoint {
    let username: String
    let page: Int

    var path: String {
        return "/search/users"  // Endpoint tìm kiếm người dùng (Không kèm query)
    }

    var method: HTTPMethod { .get }

    // 2. store query items
    var queryItems: [URLQueryItem]? {
        // q: chuỗi tìm kiếm (cần URL encode) + giới hạn tìm kiếm trong login
        // per_page: số lượng kết quả trên mỗi trang (Ví dụ: 100)
        // page: trang hiện tại

        let searchQuery = username + "+in:login"
        let encodedQuery =
            searchQuery.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) ?? searchQuery

        return [
            URLQueryItem(name: "q", value: encodedQuery),
            URLQueryItem(name: "per_page", value: "100"),  // default limit 100
            URLQueryItem(name: "page", value: "\(page)"),
        ]
    }

    var headers: [String: String]? {
        ["Accept": "application/vnd.github+json"]
    }

    var body: Data? { nil }
}
