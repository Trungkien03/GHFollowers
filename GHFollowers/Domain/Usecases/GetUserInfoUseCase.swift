//
//  GetUserInfoUseCase.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Use Case để lấy thông tin chi tiết của một user
final class GetUserInfoUseCase {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(username: String) async throws -> User {
        return try await repository.getUserInfo(for: username)
    }
}

