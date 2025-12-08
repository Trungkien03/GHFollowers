//
//  User.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import Foundation

struct User: Codable {
    let login: String
    let avatarUrl: String
    var name: String?
    var location: String?
    var bio: String?
    var publicRepos: Int?
    var publicGists: Int?
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: String

    static var placeholder: User {
        let exampleUser = User(
            login: "applefanboy",
            avatarUrl: "https://avatars.githubusercontent.com/u/1000000?v=4",
            name: "Steve Wozniak",
            location: "Cupertino, CA",
            bio: "Co-founder of Apple Inc.",
            publicRepos: 15,
            publicGists: 2,
            htmlUrl: "https://github.com/applefanboy",
            following: 50,
            followers: 12345,
            createdAt: "2010-04-14T09:00:00Z"
        )
        return exampleUser
    }
}

struct GitHubUser: Codable {
    let login: String
    let id: Int
    let nodeId: String
    let gravatarId: String
    let url: String
    let htmlUrl: String
    let followersUrl: String
    let followingUrl: String
    let gistsUrl: String
    let starredUrl: String
    let subscriptionsUrl: String
    let organizationsUrl: String
    let reposUrl: String
    let eventsUrl: String
    let receivedEventsUrl: String
    let type: String
    let siteAdmin: Bool
    let avatarUrl: String

}
struct GithubUserSearchResponse: Codable {
    var totalCount: Int
    var incompleteResults: Bool
    var items: [GitHubUser]
}
