//
//  UIViewController+Ext.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

extension UIViewController {
    func presentGFAlertOnMainThread(
        title: String,
        message: String,
        buttonTitle: String
    ) {
        DispatchQueue.main.async { [weak self] in
            let alertVC = GFAlertVC(
                alertTitle: title,
                message: message,
                buttonTitle: buttonTitle
            )

            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self?.present(alertVC, animated: true)
        }
    }
}
