//
//  SplashNavigator.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

protocol SplashNavigatorType {
    func toListPhoto()
}

struct SplashNavigator: SplashNavigatorType {
    unowned let assembler: Assembler
    unowned let window: UIWindow

    func toListPhoto() {
        let nvc = UINavigationController()
        let vc: ListPhotoViewController = assembler.resolve(navigation: nvc)
        nvc.viewControllers = [vc]
        window.rootViewController = nvc
        window.makeKeyAndVisible()
    }
}
