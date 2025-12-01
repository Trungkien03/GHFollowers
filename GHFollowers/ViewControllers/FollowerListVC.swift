//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

class FollowerListVC: UIViewController {
    var userName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}
