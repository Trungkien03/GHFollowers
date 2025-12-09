//
//  Follower.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import Foundation
import UIKit

struct Follower: Identifiable, Codable, Hashable {
    let login: String
    let id: Int
    let avatarUrl: String
}
