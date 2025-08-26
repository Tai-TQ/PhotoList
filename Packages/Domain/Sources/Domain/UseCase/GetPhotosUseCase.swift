//
//  GetPhotosUseCase.swift
//  Domain
//
//  Created by TaiTruong on 26/8/25.
//

import Foundation
import Combine

public protocol GetPhotosUseCase {
    var photoRepository: PhotoRepository { get }
}

public extension GetPhotosUseCase {
    public func getPhotos(pageInfo: PagingInfo) -> AnyPublisher<[Photo], Error> {
        photoRepository.fetchPhotos(page: pageInfo.page, perPage: pageInfo.itemsPerPage)
    }
}
