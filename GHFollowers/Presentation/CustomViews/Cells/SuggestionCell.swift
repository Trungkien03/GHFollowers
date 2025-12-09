//
//  SuggestionCell.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 4/12/25.
//

import SnapKit
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

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(44)
        }

        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
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
