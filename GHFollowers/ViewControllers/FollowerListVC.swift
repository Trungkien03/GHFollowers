//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

protocol FollowerListVCDelegate: AnyObject {
    func didRequestFollower(for username: String)
}

@MainActor class FollowerListVC: UIViewController {
    var userName: String!  // set before presenting this VC
    private var followers: [Follower] = []
    private var filteredFollowers: [Follower] = []
    private var page = 1
    private var isLoading = false
    private var hasMoreFollowers = true  // simple pagination flag
    private var fetchTask: Task<Void, Never>?  // keep reference to cancel if needed
    private var isSearching = false

    var collectionView: UICollectionView!

    private enum FollowerListSection: Int {
        case main
    }
    private var followerDataSource:
        UICollectionViewDiffableDataSource<FollowerListSection, Follower.ID>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        configureDataSource()
        startInitialFetch()
        configureSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
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

        if requestedPage == 1 {
            showLoadingView()
        }

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

            updateTableData(on: followers)

        } catch {
            // show friendly error using localizedDescription
            presentGFAlertOnMainThread(
                title: "Error",
                message: error.localizedDescription,
                buttonTitle: "OK"
            )
        }

        if requestedPage == 1 {
            dismissLoadingView()
        }

        isLoading = false
    }

    private func updateTableData(on followers: [Follower]) {
        // Apply snapshot to update collection view
        var snapshot = NSDiffableDataSourceSnapshot<
            FollowerListSection, Follower.ID
        >()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers.map { $0.id })

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Update DataSource và UI
            self.followerDataSource.apply(
                snapshot,
                animatingDifferences: true
            )

            // check và show Empty State
            if self.followers.isEmpty {
                let message =
                    "This user doesn't have any followers. Go follow them"
                self.showEmptyStateView(with: message, in: self.view)
            }
        }

    }

    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view)
        )
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView
            .register(
                FollowerCell.self,
                forCellWithReuseIdentifier: FollowerCell
                    .reuseIdentifier
            )

        collectionView.delegate = self
    }

    private func configureDataSource() {
        followerDataSource = UICollectionViewDiffableDataSource<
            FollowerListSection, Follower.ID
        >(
            collectionView: collectionView,
            cellProvider: {
                [weak self] collectionView, indexPath, itemIdentifier in
                guard
                    let self = self,
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: FollowerCell.reuseIdentifier,
                        for: indexPath
                    ) as? FollowerCell
                else {
                    return UICollectionViewCell()
                }

                let follower = self.followers[indexPath.item]
                cell.setFollower(follower: follower)
                return cell
            }
        )

        var snapshot = NSDiffableDataSourceSnapshot<
            FollowerListSection, Follower.ID
        >()
        snapshot.appendSections([.main])
        followerDataSource.apply(snapshot, animatingDifferences: false)
    }

    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Followers"
        navigationItem.searchController = searchController
    }

    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationItem.hidesSearchBarWhenScrolling = false

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }

    @objc func addButtonTapped() {
        print("Add button tapped")
    }

    deinit {
        // cancel any running task when the VC is deallocated
        fetchTask?.cancel()
    }
}

extension FollowerListVC: UICollectionViewDelegate {

    /// tracking scroll height to load next page - perform infinite scroll
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offSetY > contentHeight - height {
            loadNextPageIfNeeded()
        }
    }

    /// delegate function use when user tap the item in the collection
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]

        let userInfoVC = UserInfoVC()
        userInfoVC.delegate = self
        userInfoVC.userName = follower.login
        let navController = UINavigationController(
            rootViewController: userInfoVC
        )
        present(navController, animated: true)
    }
}

extension FollowerListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty
        else {
            filteredFollowers = followers
            updateTableData(on: followers)
            return
        }

        isSearching = true

        filteredFollowers =
            followers
            .filter { $0.login.lowercased().contains(filter.lowercased()) }

        updateTableData(on: filteredFollowers)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateTableData(on: followers)
    }
}

extension FollowerListVC: FollowerListVCDelegate {
    func didRequestFollower(for username: String) {
        self.userName = username
        page = 1
        title = username
        followers.removeAll()
        filteredFollowers.removeAll()
        collectionView.setContentOffset(.zero, animated: true)
        Task { [weak self] in
            await self?.fetchFollowersAsync(page: 1)
        }
    }
}
