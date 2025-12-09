//
//  UserInfoViewModel.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Combine
import Foundation

/// ViewModel cho UserInfoVC - quản lý logic hiển thị thông tin user
@MainActor
final class UserInfoViewModel {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Properties
    private(set) var username: String

    // MARK: - Dependencies
    private let getUserInfoUseCase: GetUserInfoUseCase
    private var fetchTask: Task<Void, Never>?

    // MARK: - Initialization
    init(
        username: String,
        getUserInfoUseCase: GetUserInfoUseCase
    ) {
        self.username = username
        self.getUserInfoUseCase = getUserInfoUseCase
    }

    // MARK: - Public Methods
    /// Load thông tin user
    func loadUserInfo() {
        fetchTask?.cancel()

        fetchTask = Task { [weak self] in
            guard let self = self else { return }

            isLoading = true
            errorMessage = nil

            do {
                user = try await getUserInfoUseCase.execute(username: username)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    deinit {
        fetchTask?.cancel()
    }
}
