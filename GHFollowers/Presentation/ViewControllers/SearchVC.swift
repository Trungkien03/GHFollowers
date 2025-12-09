//
//  SearchVC.swift
//  GHFollowers
//
//  Created by Nguyen Trung Kien on 29/11/25.
//

import Combine
import SnapKit
import UIKit

final class SearchVC: UIViewController {
    // MARK: - UI Components
    private let logoImageView = UIImageView()
    private let usernameTextField = GFTextField()
    private let callToActionButton = GFButton(
        backgroundColor: .systemGreen,
        title: "Get Followers"
    )
    private let suggestionTableView = UITableView()

    // MARK: - Properties
    private let viewModel: SearchViewModel
    private weak var coordinator: SearchCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Initialization
    init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
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
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Setup
    private func setupUI() {
        configureLogoImageView()
        configureTextField()
        configureCallToActionButton()
        createDismissKeyboardTapGesture()
        configureSuggestionTable()
    }

    private func bindViewModel() {
        // Bind suggestions
        viewModel.$suggestions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSuggestionsTableHeight()
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
    }

    // MARK: - Actions
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(
            target: self.view,
            action: #selector(UIView.endEditing(_:))
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func pushFollowerListVC() {
        guard
            let username = usernameTextField.text?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            !username.isEmpty
        else {
            presentGFAlertOnMainThread(
                title: "Empty Username",
                message: "Please enter a username to search for",
                buttonTitle: "Ok"
            )
            return
        }

        coordinator?.showFollowerList(for: username)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        let query = textField.text ?? ""
        viewModel.searchUsers(query: query)
    }

    // MARK: - UI Configuration
    private func configureLogoImageView() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(resource: .ghLogo)

        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
    }

    private func configureTextField() {
        view.addSubview(usernameTextField)
        usernameTextField.delegate = self
        usernameTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )

        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(48)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
    }

    private func configureCallToActionButton() {
        view.addSubview(callToActionButton)
        callToActionButton.addTarget(
            self,
            action: #selector(pushFollowerListVC),
            for: .touchDown
        )

        callToActionButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
    }

    private func configureSuggestionTable() {
        view.addSubview(suggestionTableView)
        suggestionTableView.translatesAutoresizingMaskIntoConstraints = false
        suggestionTableView.isHidden = true
        suggestionTableView.layer.cornerRadius = 10
        suggestionTableView.tableFooterView = UIView()
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self

        suggestionTableView.register(
            SuggestionCell.self,
            forCellReuseIdentifier: SuggestionCell.reuseID
        )

        // Setup constraints - chỉ dùng SnapKit cho top, leading, trailing
        suggestionTableView.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom)
            make.leading.equalTo(usernameTextField.snp.leading)
            make.trailing.equalTo(usernameTextField.snp.trailing)
        }

        // Tạo height constraint riêng để có thể update sau
        heightConstraint = suggestionTableView.heightAnchor.constraint(
            equalToConstant: 0
        )
        heightConstraint?.isActive = true
    }

    private func updateSuggestionsTableHeight() {
        let maxVisible = 5
        let rowHeight: CGFloat = 56
        let count = min(viewModel.suggestions.count, maxVisible)
        let height = count > 0 ? CGFloat(count) * rowHeight : 0

        // Update constraint
        heightConstraint?.constant = height

        // Show/hide table view based on suggestions
        let shouldShow = !viewModel.suggestions.isEmpty
        suggestionTableView.isHidden = !shouldShow

        // Reload data
        suggestionTableView.reloadData()

        // Force layout update để constraint được apply ngay
        view.layoutIfNeeded()
    }
}

// MARK: - UITextFieldDelegate
extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFollowerListVC()
        return true
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return viewModel.suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard indexPath.row < viewModel.suggestions.count else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: SuggestionCell.reuseID,
            for: indexPath
        )

        let user = viewModel.suggestions[indexPath.row]
        if let suggestionCell = cell as? SuggestionCell {
            suggestionCell.set(username: user.login, avatarUrl: user.avatarUrl)
        }
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row < viewModel.suggestions.count else { return }
        let selected = viewModel.suggestions[indexPath.row]
        usernameTextField.text = selected.login
        usernameTextField.resignFirstResponder()

        // Navigate to follower list
        coordinator?.showFollowerList(for: selected.login)
    }
}
