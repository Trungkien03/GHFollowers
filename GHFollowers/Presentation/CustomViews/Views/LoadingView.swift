//
//  LoadingView.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 4/12/25.
//

import SnapKit
import UIKit

final class LoadingView: UIView {

    private let spinner = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)

        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        spinner.startAnimating()
    }
}
