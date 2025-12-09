//
//  UIViewController+Ext.swift
//  GHFollowers
//
//  Created by Kain Nguyen on 1/12/25.
//

import SafariServices
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

    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    func presentConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        confirmStyle: UIAlertAction.Style = .destructive,
        onConfirm: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(
                title: cancelTitle,
                style: .cancel,
                handler: nil
            )

            let confirmAction = UIAlertAction(
                title: confirmTitle,
                style: confirmStyle
            ) { _ in
                onConfirm()
            }

            alert.addAction(cancelAction)
            alert.addAction(confirmAction)

            self.present(alert, animated: true)
        }
    }

}
