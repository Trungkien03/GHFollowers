//
//  Follower.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import Foundation

struct Follower: Decodable {
    var login: String?
    var id: Int?
    var avatarUrl: String?
}
