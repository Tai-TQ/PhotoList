//
//  UIViewController+.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

private var loadingViewTag = 999999

extension UIViewController {
    func showLoading() {
        LoadingManager.shared.show()
    }
    
    func hideLoading() {
        LoadingManager.shared.hide()
    }
    
    func showError(title: String = "Error", message: String, completion: (() -> Void)? = nil) {
        LoadingManager.shared.hideIfShowing()
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
}
