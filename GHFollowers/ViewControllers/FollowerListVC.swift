//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

class FollowerListVC: UIViewController {
    var userName: String!  // set before presenting this VC
    private var followers: [Follower] = []
    private var page = 1
    private var isLoading = false
    private var hasMoreFollowers = true  // simple pagination flag
    private var fetchTask: Task<Void, Never>?  // keep reference to cancel if needed

    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSpinner()
        startInitialFetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureSpinner() {
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func startInitialFetch() {
        // cancel any previous fetch (defensive)
        fetchTask?.cancel()

        page = 1
        followers.removeAll()
        hasMoreFollowers = true

        // create a Task we can cancel later if the VC is dismissed
        fetchTask = Task { [weak self] in
            await self?.fetchFollowersAsync(page: 1)
        }
    }

    // Call this to fetch more pages (e.g. when user scrolls near bottom)
    func loadNextPageIfNeeded() {
        guard !isLoading, hasMoreFollowers else { return }
        fetchTask = Task { [weak self] in
            await self?.fetchFollowersAsync(page: self?.page ?? 1)
        }
    }

    // MARK: - Networking (async/await)
    @MainActor
    private func fetchFollowersAsync(page requestedPage: Int) async {
        guard let username = userName, !username.isEmpty else {
            presentGFAlertOnMainThread(
                title: "No Username",
                message: "Username not set.",
                buttonTitle: "OK"
            )
            return
        }

        isLoading = true
        spinner.startAnimating()

        do {
            // network call — uses your NetworkManager.getFollowers(for:page:) async method
            let newFollowers = try await NetworkManager.shared.getFollowers(
                for: username,
                page: requestedPage
            )

            // update local state and UI on main actor
            followers.append(contentsOf: newFollowers)
            self.page = requestedPage + 1
            if newFollowers.count < 100 {
                // GitHub returns up to per_page (100) — less means last page
                hasMoreFollowers = false
            }

            // TODO: update your collection/table view here, e.g. collectionView.reloadData()
            print("Fetched followers: total = \(followers.count)")

        } catch {
            // show friendly error using localizedDescription
            presentGFAlertOnMainThread(
                title: "Error",
                message: error.localizedDescription,
                buttonTitle: "OK"
            )
        }

        spinner.stopAnimating()
        isLoading = false
    }

    deinit {
        // cancel any running task when the VC is deallocated
        fetchTask?.cancel()
    }
}
