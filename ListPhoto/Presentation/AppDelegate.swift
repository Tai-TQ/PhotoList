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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let vm: AppViewModel = assembler.resolve(window: window)
        vm.loadApp()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        endBackgroundUpdateTask()
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(backgroundUpdateTask)
        backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
}
