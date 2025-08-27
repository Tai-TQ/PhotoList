//
//  ViewModel.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Combine

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input, cancellables: inout Set<AnyCancellable>) -> Output
}

extension ViewModel {
    func bindPublisher<T, U>(
            trigger: AnyPublisher<U, Never>,
            isLoading: LoadingProperty<Bool>,
            errorSubject: PassthroughSubject<Error, Never>,
            cancellables: inout Set<AnyCancellable>,
            action: @escaping (U) -> AnyPublisher<T, Error>,
            onValue: @escaping (T) -> Void
        ) {
            trigger
                .filter { _ in !isLoading.load() }
                .handleEvents(receiveOutput: { _ in isLoading.store(true) })
                .flatMap { input in
                    return action(input)
                        .retry(1)
                        .catch { error -> Empty<T, Never> in
                            print("Receive error: \(error)")
                            errorSubject.send(error)
                            return .init()
                        }
                        .handleEvents(receiveCompletion: { _ in isLoading.store(false) })
                }
                .sinkOnMain { value in
                    isLoading.store(false)
                    onValue(value)
                }
                .store(in: &cancellables)
        }
}
