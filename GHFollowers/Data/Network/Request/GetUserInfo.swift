//
//  GetUserInfo.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 9/12/25.
//

import Foundation

struct GetUserInfo: Endpoint {
    let username: String

    var path: String {
        return "/users/\(username)"  // Endpoint tìm kiếm người dùng (Không kèm query)
    }
    var method: HTTPMethod { .get }
    // 2. store query items
    var queryItems: [URLQueryItem]? {
        return []
    }

    var headers: [String: String]? {
        ["Accept": "application/vnd.github+json"]
    }

    var body: Data? { nil }
}
