//
//  FavoritesListViewModel.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation
import Combine

/// ViewModel cho FavoritesListVC - quản lý logic hiển thị danh sách favorites
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
    /// Load danh sách favorites
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
    
    /// Xóa một favorite
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

