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

        guard let windowScene = currentWindowScene() else { return }
        let window = UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
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
    
    private func currentWindowScene() -> UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}
