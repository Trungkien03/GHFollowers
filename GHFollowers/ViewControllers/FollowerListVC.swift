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

    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureSpinner()
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
            collectionViewLayout: createThreeColumnFlowLayout()
        )
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBlue
        collectionView
            .register(
                FollowerCell.self,
                forCellWithReuseIdentifier: FollowerCell
                    .reuseIdentifier
            )
    }

    // configure layout by 3 columns
    func createThreeColumnFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width  // width of the device
        let padding: CGFloat = 12  // padding right side and left side of the collection view
        let minimumItemSpacing: CGFloat = 8  // spacing between items
        let availableWidth = width - 2 * padding - minimumItemSpacing  // width of the collection viewq
        let itemWidth = availableWidth / 3  // three column so we need to devide by 3

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: padding,
            left: padding,
            bottom: padding,
            right: padding
        )
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        return layout
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
