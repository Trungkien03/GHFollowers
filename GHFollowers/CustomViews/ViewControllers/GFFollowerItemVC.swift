//
//  GFFollowerItemVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import UIKit

class GFFollowerItemVC: GFItemInfoVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }

    private func configureItems() {
        itemInfoViewOne
            .setItemInfoType(.followers, with: user?.followers ?? 0)
        itemInfoViewTwo
            .setItemInfoType(.following, with: user?.following ?? 0)
        actionButton.set(
            backgroundColor: .systemGreen,
            title: "Get Followers"
        )
    }
}
