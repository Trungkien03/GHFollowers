//
//  GFAvatarImageView.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 2/12/25.
//

import UIKit

class GFAvatarImageView: UIImageView {

    let placeHolderImage = UIImage(resource: .avatarPlaceholder)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeHolderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
}
