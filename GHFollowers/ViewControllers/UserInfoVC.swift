//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import SnapKit
import UIKit

class UserInfoVC: UIViewController {

    let headerView = UIView()

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
        layoutUI()
        fetchUserInfo()
    }

    @objc func dismissVC() {
        dismiss(animated: true)
    }

    private func fetchUserInfo() {
        guard let login = userName else { return }

        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(
                    in: login
                )

                self.add(
                    childVC: GFUserInfoHeaderVC(user: user),
                    to: self.headerView
                )

            } catch {
                presentGFAlertOnMainThread(
                    title: "Error",
                    message: error.localizedDescription,
                    buttonTitle: "Ok"
                )
            }
        }
    }

    func layoutUI() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let padding = 5

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(200)
        }
    }

    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }

}
