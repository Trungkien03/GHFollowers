//
//  GithubUsersEndpoint.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 9/12/25.
//

import Foundation

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
