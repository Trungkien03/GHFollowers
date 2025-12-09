//
//  FavoriteRepository.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Implementation of FavoriteRepositoryProtocol
final class FavoriteRepository: FavoriteRepositoryProtocol {
    private let persistenceManager: PersistenceManagerProtocol

    init(persistenceManager: PersistenceManagerProtocol) {
        self.persistenceManager = persistenceManager
    }

    func getFavorites() async throws -> [Follower] {
        return try await withCheckedThrowingContinuation { continuation in
            persistenceManager.retrieveFavorites { result in
                switch result {
                case .success(let favorites):
                    continuation.resume(returning: favorites)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func addFavorite(_ follower: Follower) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            persistenceManager.updateWith(
                favorite: follower,
                actionType: .add
            ) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func removeFavorite(_ follower: Follower) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            persistenceManager.updateWith(
                favorite: follower,
                actionType: .remove
            ) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
