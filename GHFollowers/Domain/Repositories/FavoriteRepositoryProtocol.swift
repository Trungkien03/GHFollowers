//
//  FavoriteRepositoryProtocol.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Protocol định nghĩa các operations liên quan đến Favorites
protocol FavoriteRepositoryProtocol {
    func getFavorites() async throws -> [Follower]
    func addFavorite(_ follower: Follower) async throws
    func removeFavorite(_ follower: Follower) async throws
}

