//
//  RemoveFavoriteUseCase.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Use Case để xóa một favorite
final class RemoveFavoriteUseCase {
    private let repository: FavoriteRepositoryProtocol
    
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(follower: Follower) async throws {
        try await repository.removeFavorite(follower)
    }
}

