//
//  AppDelegate.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var assembler: Assembler = DefaultAssembler()
    var window: UIWindow?
    var backgroundUpdateTask: UIBackgroundTaskIdentifier = .init(rawValue: 0)

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        if NSClassFromString("XCTest") != nil { // test
            window.rootViewController = UnitTestViewController()
            window.makeKeyAndVisible()
        } else {
            let vc: ListPhotoViewController = assembler.resolve(navigation: UINavigationController())
            window.rootViewController = vc
        }
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }

    func applicationDidBecomeActive(_: UIApplication) {
        endBackgroundUpdateTask()
    }

    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(backgroundUpdateTask)
        backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
}
