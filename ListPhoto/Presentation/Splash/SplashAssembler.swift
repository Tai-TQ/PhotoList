//
//  SplashAssembler.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

protocol SplashAssembler {
    func resolve(window: UIWindow) -> SplashViewController
    func resolve(window: UIWindow) -> SplashViewModel
    func resolve(window: UIWindow) -> SplashNavigatorType
    func resolve() -> SplashUseCaseType
}

extension SplashAssembler {
    func resolve(window: UIWindow) -> SplashViewController {
        let vc = SplashViewController()
        let vm: SplashViewModel = resolve(window: window)
        vc.attachViewModel(to: vm)
        return vc
    }

    func resolve(window: UIWindow) -> SplashViewModel {
        SplashViewModel(
            navigator: resolve(window: window),
            useCase: resolve()
        )
    }
}

extension ListPhotoAssembler where Self: DefaultAssembler {
    func resolve(window: UIWindow) -> SplashNavigatorType {
        SplashNavigator(assembler: self, window: window)
    }

    func resolve() -> SplashUseCaseType {
        SplashUseCase()
    }
}
