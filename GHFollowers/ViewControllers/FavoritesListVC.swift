//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Nguyen Trung Kien on 29/11/25.
//

import UIKit

class FavoritesListVC: UIViewController {
    let tableView = UITableView()
    var favorites: [Follower] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configuretableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }

    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func getFavorites() {
        PersistenceManager.retrieveFavorites { [weak self] resuls in
            guard let self = self else { return }
            switch resuls {
            case .success(let favorites):
                if favorites.isEmpty {
                    showEmptyStateView(
                        with: "No Favorites\nAdd one on the follower screen",
                        in: self.view
                    )
                } else {
                    self.favorites = favorites
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.view.bringSubviewToFront(self.tableView)
                    }
                }

            case .failure(let error):
                self.presentGFAlertOnMainThread(
                    title: "Something went wrong !",
                    message: error.localizedDescription,
                    buttonTitle: "Ok"
                )
            }
        }
    }

    func configuretableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self

        tableView
            .register(
                FavoriteCell.self,
                forCellReuseIdentifier: FavoriteCell.reuseID
            )
    }

}

extension FavoritesListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: FavoriteCell.reuseID
            ) as! FavoriteCell

        let favorites = favorites[indexPath.row]
        cell.set(favorite: favorites)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let favorite = favorites[indexPath.row]
        let destinationVC = FollowerListVC()
        destinationVC.userName = favorite.login
        destinationVC.title = favorite.login
        navigationController?.pushViewController(destinationVC, animated: true)
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
            let favoriteToRemove = favorites[indexPath.row]

            self.presentConfirmationAlert(
                title: "Delete Favorite?",
                message:
                    "Are you sure you want to remove \(favoriteToRemove.login)?",
                confirmTitle: "Delete",
                confirmStyle: .destructive
            ) {
                PersistenceManager.updateWith(
                    favorite: favoriteToRemove,
                    actionType: .remove
                ) { [weak self] error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        if let error = error {
                            self.presentGFAlertOnMainThread(
                                title: "Unable to remove",
                                message: error.localizedDescription,
                                buttonTitle: "OK"
                            )
                            return
                        }

                        self.favorites.remove(at: indexPath.row)
                        self.tableView.deleteRows(
                            at: [indexPath],
                            with: .automatic
                        )

                        if self.favorites.isEmpty {
                            self.showEmptyStateView(
                                with:
                                    "No Favorites\nAdd one on the follower screen",
                                in: self.view
                            )
                        }
                    }
                }
            }
        }
    }

}
