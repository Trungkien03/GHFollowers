//
//  SearchViewModel.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation
import Combine

/// ViewModel cho SearchVC - quản lý logic tìm kiếm users
@MainActor
final class SearchViewModel {
    // MARK: - Published Properties
    @Published var suggestions: [GitHubUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let searchUsersUseCase: SearchUsersUseCase
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(searchUsersUseCase: SearchUsersUseCase) {
        self.searchUsersUseCase = searchUsersUseCase
    }
    
    // MARK: - Public Methods
    /// Tìm kiếm users với debounce
    func searchUsers(query: String, debounceInterval: TimeInterval = 0.3) {
        // Cancel previous search
        searchTask?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Nếu query rỗng, clear suggestions
        guard !trimmed.isEmpty else {
            suggestions = []
            return
        }
        
        // Debounce search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await searchUsersUseCase.execute(query: trimmed, page: 1)
                suggestions = response.items
            } catch {
                errorMessage = error.localizedDescription
                suggestions = []
            }
            
            isLoading = false
        }
    }
    
    /// Cancel current search
    func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
        suggestions = []
    }
    
    deinit {
        searchTask?.cancel()
    }
}

