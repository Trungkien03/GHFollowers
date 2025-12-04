//
//  UIViewController+Ext.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import UIKit

private var loadingView: LoadingView?

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

    func showLoadingView() {
        DispatchQueue.main.async {
            guard loadingView == nil else { return }

            let lv = LoadingView(frame: self.view.bounds)
            loadingView = lv
            lv.alpha = 0

            self.view.addSubview(lv)

            UIView.animate(withDuration: 0.25) {
                lv.alpha = 1
            }
        }
    }

    func dismissLoadingView() {
        DispatchQueue.main.async {
            guard let lv = loadingView else { return }

            UIView.animate(
                withDuration: 0.25,
                animations: {
                    lv.alpha = 0
                }
            ) { _ in
                lv.removeFromSuperview()
                loadingView = nil
            }
        }
    }

    func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = GFEmptyView(message: message)
        view.addSubview(emptyStateView)
        emptyStateView.frame = view.bounds
    }
}
