//
//  GFTitleLabel.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

class GFTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(textAlignment: NSTextAlignment, size: CGFloat) {
        super.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = UIFont.systemFont(ofSize: size, weight: .bold)
        configure()
    }

    private func configure() {
        textColor = .label
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.9
        lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
    }
}
