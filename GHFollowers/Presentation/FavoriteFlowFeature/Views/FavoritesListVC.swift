//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Nguyen Trung Kien on 29/11/25.
//

import Combine
import UIKit

@MainActor
final class FavoritesListVC: UIViewController {
    // MARK: - UI Components
    private let tableView = UITableView()

    // MARK: - Properties
    private let viewModel: FavoritesListViewModel
    private weak var coordinator: FlowRouting?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(viewModel: FavoritesListViewModel, coordinator: FlowRouting) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }

    // MARK: - Setup
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            FavoriteCell.self,
            forCellReuseIdentifier: FavoriteCell.reuseID
        )
    }

    private func bindViewModel() {
        // Bind favorites list
        viewModel.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        // Bind loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingView()
                } else {
                    self?.dismissLoadingView()
                }
            }
            .store(in: &cancellables)

        // Bind error messages
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.presentGFAlertOnMainThread(
                    title: "Something went wrong!",
                    message: errorMessage,
                    buttonTitle: "Ok"
                )
            }
            .store(in: &cancellables)

        // Bind empty state
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.showEmptyStateView(
                        with: "No Favorites\nAdd one on the follower screen",
                        in: self?.view ?? UIView()
                    )
                } else {
                    self?.view.bringSubviewToFront(self?.tableView ?? UIView())
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FavoritesListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return viewModel.favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: FavoriteCell.reuseID
            ) as! FavoriteCell

        let favorite = viewModel.favorites[indexPath.row]
        cell.set(favorite: favorite)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let favorite = viewModel.favorites[indexPath.row]
        coordinator?.showFollowerList(for: favorite.login)
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let favoriteToRemove = viewModel.favorites[indexPath.row]

            presentConfirmationAlert(
                title: "Delete Favorite?",
                message:
                    "Are you sure you want to remove \(favoriteToRemove.login)?",
                confirmTitle: "Delete",
                confirmStyle: .destructive
            ) { [weak self] in
                Task {
                    do {
                        try await self?.viewModel.removeFavorite(
                            favoriteToRemove
                        )
                    } catch {
                        self?.presentGFAlertOnMainThread(
                            title: "Unable to remove",
                            message: error.localizedDescription,
                            buttonTitle: "OK"
                        )
                    }
                }
            }
        }
    }
}
