//
//  UIHelper.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 3/12/25.
//

import UIKit

struct UIHelper {

    // configure layout by 3 columns
    static func createThreeColumnFlowLayout(in view: UIView)
        -> UICollectionViewFlowLayout
    {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = width - (2 * padding) - (minimumItemSpacing * 2)  // width of the collection viewq
        let itemWidth = availableWidth / 3  // three column so we need to devide by 3

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: padding,
            left: padding,
            bottom: padding,
            right: padding
        )
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 36)

        return layout
    }
}
