//
//  ListPhotoAssembler.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit
import Data

protocol ListPhotoAssembler {
    func resolve(navigation: UINavigationController) -> ListPhotoViewController
    func resolve(navigation: UINavigationController) -> ListPhotoViewModel
    func resolve(navigation: UINavigationController) -> ListPhotoNavigatorType
    func resolve() -> ListPhotoUseCaseType
}

extension ListPhotoAssembler {
    func resolve(navigation: UINavigationController) -> ListPhotoViewController {
        let vc = ListPhotoViewController()
        let vm: ListPhotoViewModel = resolve(navigation: navigation)
        vc.attachViewModel(to: vm)
        return vc
    }

    func resolve(navigation: UINavigationController) -> ListPhotoViewModel {
        ListPhotoViewModel(
            navigator: resolve(navigation: navigation),
            useCase: resolve()
        )
    }
}

extension ListPhotoAssembler where Self: DefaultAssembler {
    func resolve(navigation: UINavigationController) -> ListPhotoNavigatorType {
        ListPhotoNavigator(assembler: self, navigation: navigation)
    }

    func resolve() -> ListPhotoUseCaseType {
        ListPhotoUseCase(
            imageRepository: resolveImageRepository(),
            photoRepository: resolvePhotoRepository()
        )
    }
}
