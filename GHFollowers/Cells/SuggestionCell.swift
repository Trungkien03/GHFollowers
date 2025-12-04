//
//  SuggestionCell.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 4/12/25.
//

import UIKit

class SuggestionCell: UITableViewCell {
    static let reuseID = "SuggestionCell"

    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        accessoryType = .disclosureIndicator
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 22
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = .systemFont(ofSize: 16, weight: .medium)

        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 8
            ),
            avatarImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),

            usernameLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: 12
            ),
            usernameLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            usernameLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -8
            ),
        ])
    }

    func set(username: String, avatarUrl: String?) {
        usernameLabel.text = username
        if let urlString = avatarUrl {
            avatarImageView.setImage(from: urlString)
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
