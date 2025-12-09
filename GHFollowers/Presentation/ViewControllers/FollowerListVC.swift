//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import Combine
import UIKit

protocol FollowerListVCDelegate: AnyObject {
    func didRequestFollower(for username: String)
}

@MainActor
final class FollowerListVC: UIViewController {
    // MARK: - UI Components
    var collectionView: UICollectionView!

    // MARK: - Properties
    private let viewModel: FollowerListViewModel
    private weak var coordinator: FollowerListCoordinator?
    private var cancellables = Set<AnyCancellable>()

    private enum FollowerListSection: Int {
        case main
    }
    private var followerDataSource:
        UICollectionViewDiffableDataSource<FollowerListSection, Follower.ID>!

    // MARK: - Initialization
    init(viewModel: FollowerListViewModel, coordinator: FollowerListCoordinator)
    {
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
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        bindViewModel()
        viewModel.loadFollowers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Public Methods
    /// Update username và reload (được gọi từ coordinator)
    func updateUsername(_ username: String) {
        viewModel.updateUsername(username)
        title = username
    }

    // MARK: - Setup
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

    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view)
        )
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            FollowerCell.self,
            forCellWithReuseIdentifier: FollowerCell.reuseIdentifier
        )
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
    }

    private func configureDataSource() {
        followerDataSource = UICollectionViewDiffableDataSource<
            FollowerListSection, Follower.ID
        >(
            collectionView: collectionView,
            cellProvider: {
                [weak self] collectionView, indexPath, itemIdentifier in
                guard let self = self,
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: FollowerCell.reuseIdentifier,
                        for: indexPath
                    ) as? FollowerCell
                else {
                    return UICollectionViewCell()
                }

                let activeFollowers = self.viewModel.getActiveFollowers()
                guard indexPath.item < activeFollowers.count else {
                    return UICollectionViewCell()
                }

                let follower = activeFollowers[indexPath.item]
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

    private func bindViewModel() {
        // Bind followers list
        viewModel.$followers
            .combineLatest(viewModel.$filteredFollowers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.updateCollectionView()
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
                    title: "Error",
                    message: errorMessage,
                    buttonTitle: "OK"
                )
            }
            .store(in: &cancellables)

        // Bind empty state
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    let message =
                        "This user doesn't have any followers. Go follow them"
                    self?.showEmptyStateView(
                        with: message,
                        in: self?.view ?? UIView()
                    )
                }
            }
            .store(in: &cancellables)
    }

    private func updateCollectionView() {
        let activeFollowers = viewModel.getActiveFollowers()
        var snapshot = NSDiffableDataSourceSnapshot<
            FollowerListSection, Follower.ID
        >()
        snapshot.appendSections([.main])
        snapshot.appendItems(activeFollowers.map { $0.id })
        followerDataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Actions
    @objc private func addButtonTapped() {
        Task {
            do {
                try await viewModel.addToFavorites()
                presentGFAlertOnMainThread(
                    title: "Success",
                    message: "You have successfully favorited this user!",
                    buttonTitle: "OK"
                )
            } catch {
                presentGFAlertOnMainThread(
                    title: "Something went wrong!",
                    message: error.localizedDescription,
                    buttonTitle: "OK"
                )
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FollowerListVC: UICollectionViewDelegate {
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offSetY > contentHeight - height {
            viewModel.loadMoreFollowers()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let activeFollowers = viewModel.getActiveFollowers()
        guard indexPath.item < activeFollowers.count else { return }

        let follower = activeFollowers[indexPath.item]
        coordinator?.showUserInfo(for: follower.login, delegate: self)
    }
}

// MARK: - UISearchResultsUpdating & UISearchBarDelegate
extension FollowerListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text else {
            viewModel.clearSearch()
            return
        }
        viewModel.filterFollowers(searchText: filter)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.clearSearch()
    }
}

// MARK: - FollowerListVCDelegate
extension FollowerListVC: FollowerListVCDelegate {
    func didRequestFollower(for username: String) {
        updateUsername(username)
    }
}
