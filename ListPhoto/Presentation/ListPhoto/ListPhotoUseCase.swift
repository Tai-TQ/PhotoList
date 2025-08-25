//
//  ListPhotoUseCase.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation
import Combine

protocol ListPhotoUseCaseType {
    func getListPhoto(pageInfo: PagingInfo) -> AnyPublisher<[Photo], Error>
}

struct ListPhotoUseCase: ListPhotoUseCaseType {
    func getListPhoto(pageInfo: PagingInfo) -> AnyPublisher<[Photo], Error> {
        Deferred {
            return Just(Array(repeating: Photo.mock(), count: 100))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
