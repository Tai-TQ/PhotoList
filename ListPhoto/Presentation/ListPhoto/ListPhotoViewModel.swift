//
//  ListPhotoViewModel.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation
import Combine
import Domain

struct ListPhotoViewModel {
    let navigator: ListPhotoNavigatorType
    let useCase: ListPhotoUseCaseType
    
    var imageUseCase: ImageUseCase {
        guard let uc = useCase as? ImageUseCase else {
            fatalError("useCase must conform to ImageUseCase")
        }
        return uc
    }
    
    init(navigator: ListPhotoNavigatorType, useCase: ListPhotoUseCaseType) {
        self.navigator = navigator
        self.useCase = useCase
    }
}

extension ListPhotoViewModel: ViewModel {
    struct Input {
        var loadData: AnyPublisher<Void, Never>
        var loadMoreData: AnyPublisher<Void, Never>
        var reloadData: AnyPublisher<Void, Never>
        var searchData: AnyPublisher<String, Never>
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
        var photos: [Photo] = []
        let errorCombine = PassthroughSubject<Error, Never>()
        var pageInfo = PagingInfo(page: 1, itemsPerPage: 30)
        var hasMoreData = true
        errorCombine
            .sinkOnMain(output.$error.send)
            .store(in: &cancellables)

        bindPublisher(
            trigger: input.loadData,
            isLoading: output.$isLoading,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: { _ in
                pageInfo.page = 1
                hasMoreData = true
                return useCase.getPhotos(pageInfo: pageInfo)
            },
            onValue: { value in
                output.$photos.send(value)
                photos = value
                if value.count < pageInfo.itemsPerPage {
                    hasMoreData = false
                }
            }
        )
        
        let loadMoreTrigger = input.loadMoreData
            .filter {
                !photos.isEmpty
                && !output.$isLoading.load()
                && !output.$isReloading.load()
                && hasMoreData
            }
            .eraseToAnyPublisher()
        
        bindPublisher(
            trigger: loadMoreTrigger,
            isLoading: output.$isLoadingMore,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: { _ in
                var pageInfo = pageInfo
                pageInfo.page += 1
                return useCase.getPhotos(pageInfo: pageInfo)
            },
            onValue: { value in
                pageInfo.page += 1
                let newPhotos = output.photos + value
                output.$photos.send(newPhotos)
                photos = newPhotos
                if value.count < pageInfo.itemsPerPage {
                    hasMoreData = false
                }
            }
        )
        
        bindPublisher(
            trigger: input.reloadData,
            isLoading: output.$isReloading,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: { _ in
                pageInfo.page = 1
                hasMoreData = true
                return useCase.getPhotos(pageInfo: pageInfo)
            },
            onValue: { value in
                output.$photos.send(value)
                photos = value
                if value.count < pageInfo.itemsPerPage {
                    hasMoreData = false
                }
            }
        )
        
        input.searchData
            .subscribe(on: DispatchQueue.global())
            .map { searchText -> [Photo] in
                if searchText.isEmpty {
                    return photos
                }
                let lower = searchText.lowercased()
                return photos.filter { $0.id.lowercased().contains(lower) || $0.author.lowercased().contains(lower) }
            }
            .sinkOnMain(output.$photos.send)
            .store(in: &cancellables)
        
        return output
    }
}
