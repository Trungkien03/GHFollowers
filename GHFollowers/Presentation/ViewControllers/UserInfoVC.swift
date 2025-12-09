//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import Combine
import SnapKit
import UIKit

/// Protocol để handle các actions từ UserInfoVC
protocol UserInfoVCDelegate: AnyObject {
    func didTapGithubProfile(with url: URL)
    func didTapFollowerProfile(with username: String)
}

@MainActor
final class UserInfoVC: UIViewController {
    // MARK: - UI Components
    private let headerView = UIView()
    private let itemViewOne = UIView()
    private let itemViewTwo = UIView()
    private var itemViews: [UIView] = []
    private let dateLabel = GFBodyLabel(textAlignment: .center)

    // MARK: - Properties
    private let viewModel: UserInfoViewModel
    private weak var coordinator: UserInfoCoordinator?
    private weak var followerListDelegate: FollowerListVCDelegate?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        viewModel: UserInfoViewModel,
        coordinator: UserInfoCoordinator,
        followerListDelegate: FollowerListVCDelegate?
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.followerListDelegate = followerListDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        layoutUI()
        bindViewModel()
        viewModel.loadUserInfo()
    }

    // MARK: - Setup
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

        view.addSubview(headerView)
        view.addSubview(dateLabel)

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(180)
        }

        itemViews = [itemViewOne, itemViewTwo]
        var previous: UIView = headerView
        for itemView in itemViews {
            view.addSubview(itemView)
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

    private func bindViewModel() {
        // Bind user data
        viewModel.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.configureUIElements(with: user)
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
                    buttonTitle: "Ok"
                )
            }
            .store(in: &cancellables)
    }

    private func configureUIElements(with user: User) {
        let infoHeaderItem = GFUserInfoHeaderVC(user: user)
        let repoItemVC = GFReposItemVC(user: user)
        repoItemVC.delegate = self
        let followerItemVC = GFFollowerItemVC(user: user)
        followerItemVC.delegate = self

        add(childVC: infoHeaderItem, to: headerView)
        add(childVC: repoItemVC, to: itemViewOne)
        add(childVC: followerItemVC, to: itemViewTwo)
        dateLabel.text =
            "Github Since \(user.createdAt.convertToDisplayDateFormat())"
    }

    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }

    // MARK: - Actions
    @objc private func dismissVC() {
        coordinator?.dismiss()
    }
}

// MARK: - UserInfoVCDelegate
extension UserInfoVC: UserInfoVCDelegate {
    func didTapGithubProfile(with url: URL) {
        coordinator?.showGitHubProfile(url: url)
    }

    func didTapFollowerProfile(with login: String) {
        coordinator?.showFollowerList(for: login)
    }
}
