//
//  SceneDelegate.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit
import os.signpost

//let launchLog = OSLog(subsystem: "com.taitruong.ListPhoto", category: .pointsOfInterest)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let assembler: Assembler = DefaultAssembler()
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
//        os_signpost(.begin, log: launchLog, name: "AppLaunchToFirstFrame")
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
