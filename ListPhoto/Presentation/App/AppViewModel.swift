//
//  AppViewModel.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation
import Combine

final class AppViewModel {
    let navigator: AppNavigatorType
    let useCase: AppUseCaseType
    
    init(navigator: AppNavigatorType, useCase: AppUseCaseType) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
    func loadApp() {
        navigator.toListPhoto()
    }
}
