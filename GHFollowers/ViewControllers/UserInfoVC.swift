//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import SafariServices
import SnapKit
import UIKit

protocol UserInfoVCDelegate {
    func didTapGithubProfile(with url: URL)
    func didTapFollowerProfile()
}

class UserInfoVC: UIViewController {

    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    var itemViews: [UIView] = []
    let dateLabel = GFBodyLabel(textAlignment: .center)

    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
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
                self.configureUIElements(with: user)
            } catch {
                presentGFAlertOnMainThread(
                    title: "Error",
                    message: error.localizedDescription,
                    buttonTitle: "Ok"
                )
            }
        }
    }

    private func configureUIElements(with user: User) {
        let infoHeaderItem = GFUserInfoHeaderVC(user: user)
        let repoItemVC = GFReposItemVC(user: user)
        repoItemVC.delegate = self
        let followerItemVC = GFFollowerItemVC(user: user)
        followerItemVC.delegate = self

        self.add(childVC: infoHeaderItem, to: self.headerView)
        self.add(childVC: repoItemVC, to: self.itemViewOne)
        self.add(childVC: followerItemVC, to: self.itemViewTwo)
        self.dateLabel.text =
            "Github Since \(user.createdAt.convertToDisplayDateFormat())"
    }

    private func configureVC() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissVC)
        )
        navigationItem.rightBarButtonItem = doneButton
    }

    private func layoutUI() {
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140

        // add header
        view.addSubview(headerView)
        view.addSubview(dateLabel)

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(180)
        }

        itemViews = [itemViewOne, itemViewTwo]
        // add & layout item views in one loop, chaining to previous
        var previous: UIView = headerView
        for itemView in itemViews {
            view.addSubview(itemView)
            // common styling
            itemView.layer.cornerRadius = 10
            itemView.clipsToBounds = true

            itemView.snp.makeConstraints { make in
                make.top.equalTo(previous.snp.bottom).offset(padding)
                make.leading.equalToSuperview().offset(padding)
                make.trailing.equalToSuperview().inset(padding)
                make.height.equalTo(itemHeight)
            }

            previous = itemView
        }

        // optional: add bottom constraint to last item so content size is explicit
        if let last = itemViews.last {
            last.snp.makeConstraints { make in
                make.bottom.lessThanOrEqualTo(
                    view.safeAreaLayoutGuide.snp.bottom
                ).inset(padding)
            }
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(itemViewTwo.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        dateLabel.font = UIFont.preferredFont(forTextStyle: .headline)

    }

    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }

}

extension UserInfoVC: UserInfoVCDelegate {
    func didTapGithubProfile(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    func didTapFollowerProfile() {
        /// dismissVC
        /// tell follower list screen the new user
    }

}
