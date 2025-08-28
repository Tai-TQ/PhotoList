//
//  SceneDelegate.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import os.signpost
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let assembler: Assembler = DefaultAssembler()
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        if NSClassFromString("XCTest") != nil {
            window.rootViewController = UnitTestViewController()
        } else {
            let vc: SplashViewController = assembler.resolve(window: window)
            window.rootViewController = vc
        }

        self.window = window
        window.makeKeyAndVisible()
    }
}
