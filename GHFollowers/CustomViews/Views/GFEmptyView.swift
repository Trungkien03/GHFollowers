//
//  GFEmptyView.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 4/12/25.
//

import SnapKit
import UIKit

class GFEmptyView: UIView {

    let messageLabel = GFTitleLabel(textAlignment: .center, size: 28)
    let logoImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(message: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        configure()
    }

    private func configure() {
        addSubview(messageLabel)
        addSubview(logoImageView)

        messageLabel.numberOfLines = 3
        messageLabel.textColor = .secondaryLabel

        logoImageView.image = UIImage(resource: .emptyStateLogo)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-150)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(200)
        }

        logoImageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(1.3)
            make.height.equalToSuperview().multipliedBy(0.7)
            make.trailing.equalToSuperview().offset(200)
            make.bottom.equalToSuperview().offset(140)
        }

    }

}
