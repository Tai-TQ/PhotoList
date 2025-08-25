//
//  AppNavigator.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

protocol AppNavigatorType {
    func toListPhoto()
}

struct AppNavigator: AppNavigatorType {
    unowned let assembler: Assembler
    unowned let window: UIWindow

    func toListPhoto() {
        let navigation = UINavigationController()
        let vc: ListPhotoViewController = assembler.resolve(navigation: navigation)
        window.rootViewController = vc
    }
}
