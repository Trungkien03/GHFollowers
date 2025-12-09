//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import Foundation
import UIKit


// MARK: - Network Manager
/// the class UI will interact with
/// keeps the API extremely easy to use

final class NetworkManager {
    static let shared = NetworkManager()
    var baseURL: URL = URL(string: "https://api.github.com")!
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService()) {
        self.service = service
    }

    /// Fetch GitHub followers using async/await.
    func getFollowers(for username: String, page: Int) async throws
        -> [Follower]
    {
        let endpoint = GitHubFollowersEndpoint(username: username, page: page)
        return try await service.fetch(endpoint, baseURL)
    }

    /// fetch github users
    func searchUsers(for userName: String, page: Int) async throws
        -> GithubUserSearchResponse
    {
        let endpoint = GithubUsersEndpoint(username: userName, page: page)
        return try await service.fetch(endpoint, baseURL)
    }

    /// fetch userInfo
    func getUserInfo(in userName: String) async throws -> User {
        let endpoint = GetUserInfo(username: userName)
        return try await service.fetch(endpoint, baseURL)
    }

    /// Old-style callback version, internally powered by async/await.
    func getFollowers(
        for username: String,
        page: Int,
        completion: @escaping (Result<[Follower], NetworkError>) -> Void
    ) {
        Task {
            do {
                let list = try await getFollowers(for: username, page: page)
                completion(.success(list))
            } catch let netErr as NetworkError {
                completion(.failure(netErr))
            } catch {
                completion(.failure(.transport(error)))
            }
        }
    }

    /// if the image is in the cache then get it out
    func downloadImage(from urlString: String) async throws -> UIImage {
        if let image = ImageCacheManager.shared.getImage(forKey: urlString) {
            return image
        }

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await service.session.data(from: url)

            guard let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else {
                throw NetworkError.server(
                    statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1
                )
            }

            guard let image = UIImage(data: data) else {
                throw NetworkError.noData
            }

            /// store the image cache
            ImageCacheManager.shared.save(image: image, forKey: urlString)
            return image
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.transport(error)
        }
    }

}

//
//enum GFError: String, Error {
//    case invalidUsername = "This username created an invalid request."
//    case unableToComplete =
//        "Unable to complete your request. Check your internet."
//    case invalidResponse = "Invalid response from the server."
//    case invalidData = "The data received from the server is invalid."
//    case decodeError = "Failed to load data. Please try again later."
//}
//
//class NetworkManager {
//    static let shared = NetworkManager()
//    let baseURL = "https://api.github.com"
//
//    private init() {
//    }
//
//    /*
//     -@escape mean function will be execute later after the main function has been called -> Result return
//     -Result<[Follower], Error> mean it will return Follower list otherwise return Error
//     */
//    func getFollowers(
//        for userName: String,
//        page: Int,
//        completion: @escaping (Result<[Follower], GFError>) -> Void
//    ) {
//        let urlString =
//            "\(baseURL)/users/\(userName)/followers?page=\(page)&per_page=100"
//        guard let url = URL(string: urlString) else {
//            completion(.failure(.invalidUsername))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) {
//            data,
//            response,
//            error in
//
//            if let error = error {
//                completion(.failure(.unableToComplete))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse,
//                response.statusCode == 200
//            else {
//                completion(.failure(.invalidResponse))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(.invalidData))
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase  // convert login_name to loginName
//                let followers = try decoder.decode([Follower].self, from: data)  // decode JSON data - class Follower must be a decode class
//                completion(.success(followers))
//            } catch {
//                completion(.failure(.decodeError))
//            }
//        }
//
//        task.resume()
//
//    }
//
//}
