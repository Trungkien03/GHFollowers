//
//  GFItemInfoView.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import SnapKit
import UIKit

enum ItemInfoType {
    case repos, gists, following, followers
}

class GFItemInfoView: UIView {
    let symbolImageView = UIImageView()
    let titleLabel = GFTitleLabel(textAlignment: .left, size: 14)
    let countLabel = GFTitleLabel(textAlignment: .center, size: 14)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(symbolImageView)
        addSubview(titleLabel)
        addSubview(countLabel)

        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.contentMode = .scaleAspectFit
        symbolImageView.tintColor = .label

        symbolImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(symbolImageView.snp.centerY)
            make.leading.equalTo(symbolImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }

        countLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolImageView.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
    }

    func setItemInfoType(_ type: ItemInfoType, with count: Int) {
        countLabel.text = String(count)
        switch type {
        case .repos:
            symbolImageView.image = UIImage(systemName: SFSymbols.repos)
            titleLabel.text = "Repositories"
        case .gists:
            symbolImageView.image = UIImage(systemName: SFSymbols.gists)
            titleLabel.text = "Gists"
        case .followers:
            symbolImageView.image = UIImage(systemName: SFSymbols.followers)
            titleLabel.text = "Followers"
        case .following:
            symbolImageView.image = UIImage(systemName: SFSymbols.following)
            titleLabel.text = "Following"
        }
    }

}
