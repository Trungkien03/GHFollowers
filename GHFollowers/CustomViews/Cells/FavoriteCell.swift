//
//  FavoriteCell.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import SnapKit
import UIKit

class FavoriteCell: UITableViewCell {
    static let reuseID = "FavoriteCell"
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let userNameLabel = GFTitleLabel(textAlignment: .left, size: 18)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(avatarImageView)
        addSubview(userNameLabel)

        accessoryType = .disclosureIndicator
        let padding = 12

        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(padding)
            make.width.height.equalTo(60)
        }

        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(40)
        }
    }

    func set(favorite: Follower) {
        userNameLabel.text = favorite.login
        avatarImageView.setImage(from: favorite.avatarUrl)
    }

}
