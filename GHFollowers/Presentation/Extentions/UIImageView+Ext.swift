//
//  UIImageView+Ext.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 3/12/25.
//

import UIKit

extension UIImageView {

    /// download image from link and set it to UIImageView
    func setImage(from urlString: String) {
        Task { [weak self] in
            guard let self = self else { return }

            do {
                let image = try await NetworkManager.shared.downloadImage(
                    from: urlString
                )
                await MainActor.run {
                    self.image = image
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
