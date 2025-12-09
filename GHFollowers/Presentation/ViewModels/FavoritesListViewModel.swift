//
//  FavoritesListViewModel.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Combine
import Foundation

/// ViewModel cho FavoritesListVC - manage logic to show favorite list
@MainActor
final class FavoritesListViewModel {
    // MARK: - Published Properties
    @Published var favorites: [Follower] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isEmpty: Bool = false

    // MARK: - Dependencies
    private let getFavoritesUseCase: GetFavoritesUseCase
    private let removeFavoriteUseCase: RemoveFavoriteUseCase

    // MARK: - Initialization
    init(
        getFavoritesUseCase: GetFavoritesUseCase,
        removeFavoriteUseCase: RemoveFavoriteUseCase
    ) {
        self.getFavoritesUseCase = getFavoritesUseCase
        self.removeFavoriteUseCase = removeFavoriteUseCase
    }

    // MARK: - Public Methods
    /// Load favorite list
    func loadFavorites() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                favorites = try await getFavoritesUseCase.execute()
                isEmpty = favorites.isEmpty
            } catch {
                errorMessage = error.localizedDescription
                favorites = []
                isEmpty = true
            }

            isLoading = false
        }
    }

    /// remove one favorite
    func removeFavorite(_ follower: Follower) async throws {
        isLoading = true
        errorMessage = nil

        do {
            try await removeFavoriteUseCase.execute(follower: follower)
            favorites.removeAll { $0.login == follower.login }
            isEmpty = favorites.isEmpty
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }

        isLoading = false
    }
}
