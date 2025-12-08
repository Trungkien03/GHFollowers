//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import UIKit

class UserInfoVC: UIViewController {

    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissVC)
        )
        navigationItem.rightBarButtonItem = doneButton
        Task {
            await fetchUserInfo()
        }
    }

    @objc func dismissVC() {
        dismiss(animated: true)
    }

    private func fetchUserInfo() async {
        guard let login = userName else { return }

        do {
            let user = try await NetworkManager.shared.getUserInfo(
                in: login
            )

            print(user)

        } catch {
            presentGFAlertOnMainThread(
                title: "Error",
                message: error.localizedDescription,
                buttonTitle: "Ok"
            )
        }
    }

}
