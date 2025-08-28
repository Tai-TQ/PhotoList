//
//  UIViewController+.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

private var loadingViewTag = 999_999

extension UIViewController {
    func showLoading() {
        LoadingManager.shared.show()
    }

    func hideLoading() {
        LoadingManager.shared.hide()
    }

    func showError(title: String = "Error", message: String, completion: (() -> Void)? = nil) {
        LoadingManager.shared.hideIfShowing()
        let ac = UIAlertController(title: title,
                                   message: title.isEmpty ? "\(message)" : "\n\(message)",
                                   preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            completion?()
        }
        if !title.isEmpty {
            let titleAtt = NSAttributedString(
                string: title,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.redE26161,
                             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
            )
            ac.setValue(titleAtt, forKey: "attributedTitle")
        }

        let messageAtt = NSAttributedString(
            string: title.isEmpty ? "\(message)" : "\n\(message)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black22,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        )

        ac.setValue(messageAtt, forKey: "attributedMessage")
        ac.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(ac, animated: true, completion: nil)
        }
    }
}
