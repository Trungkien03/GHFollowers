//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 2/12/25.
//

import UIKit

class FollowerCell: UICollectionViewCell {
    static let reuseIdentifier: String = "FollowerCell"
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let userNameLabel = GFTitleLabel(textAlignment: .center, size: 16)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFollower(follower: Follower) {
        userNameLabel.text = follower.login
        avatarImageView.downloadImage(from: follower.avatarUrl)
    }

    private func configure() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userNameLabel)

        let padding: CGFloat = 8

        NSLayoutConstraint.activate(
            [
                avatarImageView.topAnchor
                    .constraint(
                        equalTo: contentView.topAnchor,
                        constant: padding
                    ),
                avatarImageView.leadingAnchor
                    .constraint(
                        equalTo: contentView.leadingAnchor,
                        constant: padding
                    ),
                avatarImageView.trailingAnchor
                    .constraint(
                        equalTo: contentView.trailingAnchor,
                        constant: -padding
                    ),
                avatarImageView.heightAnchor
                    .constraint(equalTo: avatarImageView.widthAnchor),

                userNameLabel.topAnchor
                    .constraint(
                        equalTo: avatarImageView.bottomAnchor,
                        constant: 12
                    ),
                userNameLabel.leadingAnchor
                    .constraint(
                        equalTo: contentView.leadingAnchor,
                        constant: padding
                    ),
                userNameLabel.trailingAnchor
                    .constraint(
                        equalTo: contentView.trailingAnchor,
                        constant: -padding
                    ),
                userNameLabel.heightAnchor.constraint(equalToConstant: 20),

            ]
        )
    }
}
