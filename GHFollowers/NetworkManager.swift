//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingFailed
}

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://api.github.com"

    private init() {
    }

    func getFollowers(
        for userName: String,
        page: Int,
        completion: @escaping (Result<[Follower], Error>) -> Void
    ) {
        let urlString =
            "\(baseURL)/users/\(userName)/followers?page=\(page)&per_page=100"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {
            data,
            response,
            error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completion(.success(followers))
            } catch {
                completion(.failure(NetworkError.decodingFailed))
            }
        }

        task.resume()

    }
}

