//
//  ListPhotoViewModel.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation
import Combine

struct ListPhotoViewModel {
    let navigator: ListPhotoNavigatorType
    let useCase: ListPhotoUseCaseType
    
    init(navigator: ListPhotoNavigatorType, useCase: ListPhotoUseCaseType) {
        self.navigator = navigator
        self.useCase = useCase
    }
}

extension ListPhotoViewModel: ViewModel {
    struct Input {
        var loadData: AnyPublisher<String, Never>
        var loadMoreData: AnyPublisher<String, Never>
        var reloadData: AnyPublisher<String, Never>
    }
    
    struct Output {
        @Property var photos: [Photo] = []
        @Property var error: Error?
        @LoadingProperty var isLoading: Bool = false
        @LoadingProperty var isLoadingMore: Bool = false
        @LoadingProperty var isReloading: Bool = false
    }
    
    func transform(_ input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output()
        let errorCombine = PassthroughSubject<Error, Never>()
        var pageInfo = PagingInfo(page: 1, itemsPerPage: 100)
        errorCombine
            .sinkOnMain(output.$error.send)
            .store(in: &cancellables)

        bindPublisher(
            trigger: input.loadData,
            isLoading: output.$isLoading,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: {_ in
                print("Action")
                pageInfo.page = 1
                return useCase.getListPhoto(pageInfo: pageInfo)
            },
            onValue: { value in
                output.$photos.send(value)
            }
        )
        
        bindPublisher(
            trigger: input.loadMoreData,
            isLoading: output.$isLoadingMore,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: {_ in 
                pageInfo.page += 1
                return useCase.getListPhoto(pageInfo: pageInfo)
            },
            onValue: { output.$photos.send(output.photos + $0) }
        )
        
        bindPublisher(
            trigger: input.reloadData,
            isLoading: output.$isReloading,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: {_ in 
                pageInfo.page = 1
                return useCase.getListPhoto(pageInfo: pageInfo)
            },
            onValue: { output.$photos.send($0) }
        )
        
        return output
    }
}
