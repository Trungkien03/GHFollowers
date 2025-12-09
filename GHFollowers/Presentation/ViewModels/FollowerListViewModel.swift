//
//  FollowerListViewModel.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation
import Combine

/// ViewModel cho FollowerListVC - quản lý logic hiển thị danh sách followers
@MainActor
final class FollowerListViewModel {
    // MARK: - Published Properties
    @Published var followers: [Follower] = []
    @Published var filteredFollowers: [Follower] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isEmpty: Bool = false
    
    // MARK: - Properties
    private(set) var username: String
    private var currentPage = 1
    private var hasMoreFollowers = true
    private var isSearching = false
    
    // MARK: - Dependencies
    private let getFollowersUseCase: GetFollowersUseCase
    private let getUserInfoUseCase: GetUserInfoUseCase
    private let addFavoriteUseCase: AddFavoriteUseCase
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(
        username: String,
        getFollowersUseCase: GetFollowersUseCase,
        getUserInfoUseCase: GetUserInfoUseCase,
        addFavoriteUseCase: AddFavoriteUseCase
    ) {
        self.username = username
        self.getFollowersUseCase = getFollowersUseCase
        self.getUserInfoUseCase = getUserInfoUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
    }
    
    // MARK: - Public Methods
    /// Load followers từ đầu
    func loadFollowers() {
        fetchTask?.cancel()
        currentPage = 1
        followers = []
        filteredFollowers = []
        hasMoreFollowers = true
        fetchFollowers(page: 1)
    }
    
    /// Load thêm followers (pagination)
    func loadMoreFollowers() {
        guard !isLoading && hasMoreFollowers else { return }
        fetchFollowers(page: currentPage)
    }
    
    /// Update username và reload
    func updateUsername(_ newUsername: String) {
        username = newUsername
        loadFollowers()
    }
    
    /// Filter followers theo search text
    func filterFollowers(searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            isSearching = false
            filteredFollowers = followers
        } else {
            isSearching = true
            filteredFollowers = followers.filter {
                $0.login.lowercased().contains(trimmed.lowercased())
            }
        }
    }
    
    /// Clear search filter
    func clearSearch() {
        isSearching = false
        filteredFollowers = followers
    }
    
    /// Get active followers list (filtered hoặc all)
    func getActiveFollowers() -> [Follower] {
        return isSearching ? filteredFollowers : followers
    }
    
    /// Add user to favorites
    func addToFavorites() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await getUserInfoUseCase.execute(username: username)
            let favorite = Follower(
                login: user.login,
                id: user.id,
                avatarUrl: user.avatarUrl
            )
            try await addFavoriteUseCase.execute(follower: favorite)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func fetchFollowers(page: Int) {
        fetchTask?.cancel()
        
        fetchTask = Task { [weak self] in
            guard let self = self else { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let newFollowers = try await getFollowersUseCase.execute(
                    username: username,
                    page: page
                )
                
                if page == 1 {
                    followers = newFollowers
                } else {
                    followers.append(contentsOf: newFollowers)
                }
                
                if !isSearching {
                    filteredFollowers = followers
                }
                
                currentPage = page + 1
                hasMoreFollowers = newFollowers.count >= 100
                isEmpty = followers.isEmpty
                
            } catch {
                errorMessage = error.localizedDescription
                if page == 1 {
                    followers = []
                    filteredFollowers = []
                }
            }
            
            isLoading = false
        }
    }
    
    deinit {
        fetchTask?.cancel()
    }
}

