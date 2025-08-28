//
//  SplashViewModel.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Combine
import Domain
import Foundation

struct SplashViewModel {
    let navigator: SplashNavigatorType
    let useCase: SplashUseCaseType

    init(navigator: SplashNavigatorType, useCase: SplashUseCaseType) {
        self.navigator = navigator
        self.useCase = useCase
    }
}

extension SplashViewModel: ViewModel {
    struct Input {
        var loadData: AnyPublisher<Void, Never>
    }

    struct Output {}

    func transform(_ input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output()
        input.loadData
            .first()
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .sink { _ in
                navigator.toListPhoto()
            }
            .store(in: &cancellables)

        return output
    }
}
