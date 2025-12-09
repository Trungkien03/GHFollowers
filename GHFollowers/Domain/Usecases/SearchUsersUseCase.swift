//
//  SearchUsersUseCase.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Use Case để tìm kiếm users
final class SearchUsersUseCase {
    private let repository: FollowerRepositoryProtocol
    
    init(repository: FollowerRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String, page: Int) async throws -> GithubUserSearchResponse {
        return try await repository.searchUsers(for: query, page: page)
    }
}

