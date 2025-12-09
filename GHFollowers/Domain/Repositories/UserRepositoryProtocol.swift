//
//  UserRepositoryProtocol.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Protocol định nghĩa các operations liên quan đến User
protocol UserRepositoryProtocol {
    func getUserInfo(for username: String) async throws -> User
}

