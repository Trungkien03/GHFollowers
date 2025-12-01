//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

class FollowerListVC: UIViewController {
    var userName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        NetworkManager.shared.getFollowers(for: userName, page: 1) { result in
            switch result {
            case .success(let followers):
                // TODO: Update UI with followers
                print("Fetched followers count: \(followers.count)")
            case .failure(let error):
                // TODO: Present an error alert to the user
                self.presentGFAlertOnMainThread(
                    title: "Error",
                    message:
                        "Failed to fetch followers: \(error.localizedDescription)",
                    buttonTitle: "Ok"
                )
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}
