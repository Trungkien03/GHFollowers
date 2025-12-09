//
//  AddFavoriteUseCase.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Use Case to add new favorite
final class AddFavoriteUseCase {
    private let repository: FavoriteRepositoryProtocol

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(follower: Follower) async throws {
        try await repository.addFavorite(follower)
    }
}
