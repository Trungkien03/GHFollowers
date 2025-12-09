//
//  GitHubFollowersEndpoint.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 9/12/25.
//

import Foundation

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
