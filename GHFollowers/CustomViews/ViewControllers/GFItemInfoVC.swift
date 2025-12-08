//
//  GFItemInfoVCViewController.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import SnapKit
import UIKit

class GFItemInfoVC: UIViewController {

    let stackView = UIStackView()
    let itemInfoViewOne = GFItemInfoView()
    let itemInfoViewTwo = GFItemInfoView()
    let actionButton = GFButton()

    var user: User?
    var delegate: UserInfoVCDelegate?

    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStackView()
        configureBackgroundview()
        layoutUI()
        configureActionButton()
    }

    private func configureBackgroundview() {
        view.layer.cornerRadius = 16
        view.backgroundColor = .secondarySystemBackground
    }

    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing

        [itemInfoViewOne, itemInfoViewTwo].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func configureActionButton() {
        actionButton.addTarget(
            self,
            action: #selector(actionButtonTapped),
            for: .touchUpInside
        )
    }

    @objc func actionButtonTapped() {}

    private func layoutUI() {
        view.addSubview(stackView)
        view.addSubview(actionButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let padding = 20

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(50)
        }

        actionButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(44)
        }
    }

}
