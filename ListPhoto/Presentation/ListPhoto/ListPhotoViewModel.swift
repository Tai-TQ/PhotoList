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
        var pageInfo = PagingInfo(page: 1, itemsPerPage: 10)
        errorCombine
            .sinkOnMain(output.$error.send)
            .store(in: &cancellables)

        bindPublisher(
            trigger: input.loadData,
            isLoading: output.$isLoading,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: { _ in
                print("Start load data at \(Date())")
                pageInfo.page = 1
                return useCase.getPhotos(pageInfo: pageInfo)
            },
            onValue: { value in
                print("Load data success at \(Date())")
                output.$photos.send(value)
                photos = value
            }
        )
        
        let loadMoreTrigger = input.loadMoreData
            .filter { !output.$isLoading.load() && !output.$isReloading.load() && !photos.isEmpty }
            .eraseToAnyPublisher()
        bindPublisher(
            trigger: loadMoreTrigger,
            isLoading: output.$isLoadingMore,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: { _ in
                print("Start loadMore data at \(Date())")
                pageInfo.page += 1
                return useCase.getPhotos(pageInfo: pageInfo)
            },
            onValue: { value in
                print("LoadMore data success at \(Date())")
                output.$photos.send(output.photos + value)
                photos = output.photos + value
            }
        )
        
        bindPublisher(
            trigger: input.reloadData,
            isLoading: output.$isReloading,
            errorSubject: errorCombine,
            cancellables: &cancellables,
            action: { _ in
                print("Start reload data at \(Date())")
                pageInfo.page = 1
                return useCase.getPhotos(pageInfo: pageInfo)
            },
            onValue: { value in
                print("Reload data success at \(Date())")
                output.$photos.send(value)
                photos = value
            }
        )
        
        input.searchData
            .subscribe(on: DispatchQueue.global())
            .map { searchText -> [Photo] in
                print("Start Search with \(searchText) at \(Date())")
                if searchText.isEmpty {
                    return photos
                }
                let lower = searchText.lowercased()
                return photos.filter { $0.id.lowercased().contains(lower) || $0.author.lowercased().contains(lower) }
            }
            .handleEvents(receiveOutput: { _ in print("Search success at \(Date())") })
            .sinkOnMain(output.$photos.send)
            .store(in: &cancellables)
        
        return output
    }
}
