//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 2/12/25.
//

import SnapKit
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
        avatarImageView.setImage(from: follower.avatarUrl)
    }

    private func configure() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userNameLabel)

        let padding: CGFloat = 8

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(avatarImageView.snp.width)
        }

        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(20)
        }

    }
}
