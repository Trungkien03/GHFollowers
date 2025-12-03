//
//  ImageCacheManager.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 3/12/25.
//

import Foundation
import UIKit

/// class to manage cache image
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func clear() {
        cache.removeAllObjects()
    }
}
