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
    private var page = 1
    private var isLoading = false
    private var hasMoreFollowers = true  // simple pagination flag
    private var fetchTask: Task<Void, Never>?  // keep reference to cancel if needed

    private let spinner = UIActivityIndicatorView(style: .large)

    var collectionView: UICollectionView!

    private enum FollowerListSection: Int {
        case main
    }
    private var followerDataSource:
        UICollectionViewDiffableDataSource<FollowerListSection, Follower.ID>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureSpinner()
        configureDataSource()
        startInitialFetch()
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

            // Apply snapshot to update collection view
            var snapshot = NSDiffableDataSourceSnapshot<
                FollowerListSection, Follower.ID
            >()
            snapshot.appendSections([.main])
            snapshot.appendItems(followers.map { $0.id })
            DispatchQueue.main.async {
                self.followerDataSource.apply(
                    snapshot,
                    animatingDifferences: true
                )
            }

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
