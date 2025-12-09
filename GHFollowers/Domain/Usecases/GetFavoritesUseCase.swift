//
//  GetFavoritesUseCase.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Use Case để lấy danh sách favorites
final class GetFavoritesUseCase {
    private let repository: FavoriteRepositoryProtocol
    
    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Follower] {
        return try await repository.getFavorites()
    }
}

