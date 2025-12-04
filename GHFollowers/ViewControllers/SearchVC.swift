//
//  SearchVC.swift
//  GHFollowers
//
//  Created by Nguyen Trung Kien on 29/11/25.
//

import UIKit

class SearchVC: UIViewController {
    let logoImageView = UIImageView()
    let usernameTextField = GFTextField()
    let callToActionButton = GFButton(
        backgroundColor: .systemGreen,
        title: "Get Followers"
    )

    private let suggestionTableView = UITableView()
    private var suggestions: [GitHubUser] = []
    private var searchDebounceTimer: Timer?
    private let debounceInterval: TimeInterval = 0.3  // 300 ms

    var isUserNameEntered: Bool {
        return !usernameTextField.text!.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        /// order of these calling functions are crucial
        configureLogoImageView()
        configureTextField()
        configureCallToActionButton()
        createDismissKeyboardTapGesture()
        configureSuggestionTable()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(
            target: self.view,
            action: #selector(UIView.endEditing(_:))
        )
        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }

    /// event to put in call to action button
    @objc func pushFollowerListVC() {
        guard isUserNameEntered else {
            presentGFAlertOnMainThread(
                title: "Empty Username",
                message: "Please enter a username to search for",
                buttonTitle: "Ok"
            )
            return
        }
        let followerListVC = FollowerListVC()
        followerListVC.userName = usernameTextField.text ?? ""
        followerListVC.title = usernameTextField.text ?? "Followers"
        navigationController?.pushViewController(followerListVC, animated: true)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let raw = textField.text ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        suggestions = []

        // nếu rỗng thì ẩn suggestions
        if trimmed.isEmpty {
            searchDebounceTimer?.invalidate()
            searchDebounceTimer = nil
            suggestions = []
            updateSuggestionsTableHeight()
            return
        }

        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(
            withTimeInterval: debounceInterval,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { [weak self] in
                guard let self = self else { return }
                let results = try await NetworkManager.shared.searchUsers(
                    for: trimmed,
                    page: 1
                )

                /// update data UI in Main thread
                await MainActor.run {
                    self.suggestions = results.items
                    self.updateSuggestionsTableHeight()
                }
            }
        }

        // cập nhật table: set chiều cao, reload và hiển thị
        updateSuggestionsTableHeight()
    }

    private func updateSuggestionsTableHeight() {
        let maxVisible = 5
        let rowHeight: CGFloat = 56
        let count = min(suggestions.count, maxVisible)
        let height = count > 0 ? CGFloat(count) * rowHeight : 0

        if let heightConstraint = suggestionTableView.constraints.first(
            where: { $0.firstAttribute == .height })
        {
            heightConstraint.constant = height
        }
        suggestionTableView.isHidden = suggestions.isEmpty
        suggestionTableView.reloadData()

    }

    /// configuring LOGO github
    func configureLogoImageView() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(resource: .ghLogo)
        /// the name of image in Assets

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 80
            ),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
        ])
    }

    /// configuring Search Text Field
    func configureTextField() {
        view.addSubview(usernameTextField)
        usernameTextField.delegate = self
        /// delegate use to modify behavior on the textField (end editing, start editing, etc...)

        usernameTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )

        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(
                equalTo: logoImageView.bottomAnchor,
                constant: 48
            ),
            usernameTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 50
            ),
            usernameTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -50
            ),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    /// configuring search button
    func configureCallToActionButton() {
        view.addSubview(callToActionButton)

        callToActionButton
            .addTarget(
                self,
                action: #selector(pushFollowerListVC),
                for: .touchDown
            )

        NSLayoutConstraint.activate([
            callToActionButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -10
            ),
            callToActionButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 50
            ),
            callToActionButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -50
            ),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    /// configureSuggestionTable
    func configureSuggestionTable() {
        view.addSubview(suggestionTableView)
        suggestionTableView.translatesAutoresizingMaskIntoConstraints = false
        suggestionTableView.isHidden = true
        /// not showing in the first time
        suggestionTableView.layer.cornerRadius = 10
        suggestionTableView.tableFooterView = UIView()

        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self

        suggestionTableView.register(
            SuggestionCell.self,
            forCellReuseIdentifier: SuggestionCell.reuseID
        )

        NSLayoutConstraint.activate([
            suggestionTableView.topAnchor
                .constraint(
                    equalTo: usernameTextField.bottomAnchor,
                    constant: 8
                ),
            suggestionTableView.leadingAnchor
                .constraint(equalTo: usernameTextField.leadingAnchor),
            suggestionTableView.trailingAnchor
                .constraint(equalTo: usernameTextField.trailingAnchor),
            suggestionTableView.heightAnchor.constraint(equalToConstant: 0),
        ])
    }

}

/// after user pressed return or ok or whatever the submit key of the keyboard, navigate to followerList view
extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFollowerListVC()
        return true
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        // Trả về số lượng suggestions thực tế
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard indexPath.row < suggestions.count else {
            return UITableViewCell()
        }
        // 1. Dequeue SuggestionCell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SuggestionCell.reuseID,
            for: indexPath
        )
        // 2. get user information
        let user = suggestions[indexPath.row]
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

        guard indexPath.row < suggestions.count else { return }
        let selected = suggestions[indexPath.row]
        usernameTextField.text = selected.login

        // clear suggestions and update UI
        suggestions = []
        updateSuggestionsTableHeight()
        usernameTextField.resignFirstResponder()

        // navigate
        pushFollowerListVC()
    }
}
