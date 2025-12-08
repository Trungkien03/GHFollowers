//
//  GFReposItemVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import UIKit

class GFReposItemVC: GFItemInfoVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }

    private func configureItems() {
        itemInfoViewOne.setItemInfoType(.repos, with: user?.publicRepos ?? 0)
        itemInfoViewTwo.setItemInfoType(.gists, with: user?.publicGists ?? 0)
        actionButton.set(
            backgroundColor: .systemPurple,
            title: "Github Profile"
        )
    }
}
