//
//  PersistenceManager.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 8/12/25.
//

import Foundation

enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    static private let defaults = UserDefaults.standard

    enum Keys {
        static let favorites = "favorites"
    }

    static func updateWith(
        favorite: Follower,
        actionType: PersistenceActionType,
        completion: @escaping (Error?) -> Void
    ) {
        retrieveFavorites { result in
            switch result {
            case .success(let favorites):
                var retrievedFavorites = favorites

                switch actionType {
                case .add:
                    guard !retrievedFavorites.contains(favorite) else {
                        completion(PersistenceError.alreadyExists)
                        return
                    }
                    retrievedFavorites.append(favorite)
                    break
                case .remove:
                    retrievedFavorites.removeAll { $0.login == favorite.login }
                    break
                }

                completion(save(favorites: retrievedFavorites))

            case .failure(let error):
                completion(error)
            }
        }
    }

    /// retreive favorites
    static func retrieveFavorites(
        completion: @escaping (Result<[Follower], Error>) -> Void
    ) {
        guard
            let favouritesData = defaults.object(forKey: Keys.favorites)
                as? Data
        else {
            completion(.success([]))
            return
        }

        do {
            let decoder = JSONDecoder()
            let favourites = try decoder.decode(
                [Follower].self,
                from: favouritesData
            )
            completion(.success(favourites))

        } catch let error as DecodingError {
            completion(.failure(PersistenceError.decodingFailed(error)))
        } catch {
            completion(.failure(error))
        }
    }

    /// save favorites
    static func save(favorites: [Follower]) -> Error? {
        do {
            let encoder = JSONEncoder()
            let favouritesData = try encoder.encode(favorites)
            defaults.set(favouritesData, forKey: Keys.favorites)
            return nil
        } catch {
            return PersistenceError.encodingFailed(error)
        }
    }
}
