//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

@MainActor class FollowerListVC: UIViewController {
    var userName: String!  // set before presenting this VC
    private var followers: [Follower] = []
    private var filteredFollowers: [Follower] = []
    private var page = 1
    private var isLoading = false
    private var hasMoreFollowers = true  // simple pagination flag
    private var fetchTask: Task<Void, Never>?  // keep reference to cancel if needed

    var collectionView: UICollectionView!

    private enum FollowerListSection: Int {
        case main
    }
    private var followerDataSource:
        UICollectionViewDiffableDataSource<FollowerListSection, Follower.ID>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesSearchBarWhenScrolling = false
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

    func configureCollectionView() {
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

    func configureDataSource() {
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

    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Followers"
        navigationItem.searchController = searchController
    }

    deinit {
        // cancel any running task when the VC is deallocated
        fetchTask?.cancel()
    }
}

extension FollowerListVC: UICollectionViewDelegate {

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
}

extension FollowerListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty
        else {
            filteredFollowers = followers
            updateTableData(on: followers)
            return
        }

        filteredFollowers =
            followers
            .filter { $0.login.lowercased().contains(filter.lowercased()) }

        updateTableData(on: filteredFollowers)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateTableData(on: followers)
    }
}
