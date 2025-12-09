//
//  FlowRouting.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation
import SafariServices

/// Common navigation contract for feature coordinators (Search & Favorites)
protocol FlowRouting: AnyObject {
    func showFollowerList(for username: String)
    func showUserInfo(for username: String, delegate: FollowerListVCDelegate?)
    func showGitHubProfile(url: URL)
    func showFollowerListFromUserInfo(for username: String)
    func dismissUserInfo()
}

