//
//  LoadingManager.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

final class LoadingManager {
    static let shared = LoadingManager()
    private var overlayWindow: UIWindow?

    private init() {}

    func show() {
        guard overlayWindow == nil else { return }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert - 1
        window.backgroundColor = .clear
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.isUserInteractionEnabled = true

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = overlay.center
        indicator.startAnimating()
        overlay.addSubview(indicator)

        window.addSubview(overlay)
        window.makeKeyAndVisible()

        overlayWindow = window
    }

    func hide() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    func hideIfShowing() {
        if overlayWindow != nil {
            hide()
        }
    }
}
