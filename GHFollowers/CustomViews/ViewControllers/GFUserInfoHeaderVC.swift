//
//  GFUserInfoHeaderVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import SnapKit
import UIKit

class GFUserInfoHeaderVC: UIViewController {

    let avatarImageView = GFAvatarImageView(frame: .zero)
    let userNameLabel = GFTitleLabel(textAlignment: .left, size: 34)
    let nameLabel = GFSecondaryLabel(fontSize: 18)

    let locationImageView = UIImageView()
    let locationLabel = GFSecondaryLabel(fontSize: 18)
    let bioLabel = GFBodyLabel(textAlignment: .left)

    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    init(user: User?) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        addSubviews()
        layoutUI()
        configureUIElements()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUIElements() {
        if let avatarUrl = user?.avatarUrl {
            avatarImageView.setImage(from: avatarUrl)
        }
        userNameLabel.text = user?.login ?? ""
        nameLabel.text = user?.name ?? ""
        locationLabel.text = user?.location ?? "No Location"
        bioLabel.text = user?.bio ?? "No Bio Available"
        bioLabel.numberOfLines = 4

        locationImageView.image = UIImage(systemName: SFSymbols.location)
        locationImageView.tintColor = .secondaryLabel

    }

    private func addSubviews() {
        [
            avatarImageView, userNameLabel, nameLabel, locationImageView,
            locationLabel, bioLabel,
        ].forEach {
            view.addSubview($0)
        }
    }

    private func layoutUI() {
        let textImagePadding: CGFloat = 12
        locationImageView.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(90)
        }

        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top)
            make.leading
                .equalTo(avatarImageView.snp.trailing)
                .offset(textImagePadding)
            make.trailing.equalToSuperview()
            make.height.equalTo(38)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView.snp.centerY).offset(8)
            make.leading
                .equalTo(avatarImageView.snp.trailing)
                .offset(textImagePadding)
            make.trailing.equalToSuperview()
            make.height.equalTo(24)
        }

        locationImageView.snp.makeConstraints { make in
            make.bottom.equalTo(avatarImageView.snp.bottom)
            make.leading
                .equalTo(avatarImageView.snp.trailing)
                .offset(textImagePadding)
            make.width.height.equalTo(20)
        }

        locationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(locationImageView.snp.centerY)
            make.leading.equalTo(locationImageView.snp.trailing).offset(5)
            make.trailing.equalToSuperview()
        }

        bioLabel.snp.makeConstraints { make in
            make.top
                .equalTo(avatarImageView.snp.bottom)
                .offset(textImagePadding)
            make.leading.equalTo(avatarImageView.snp.leading)
            make.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
    }

}
