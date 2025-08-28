//
//  GetPhotosUseCase.swift
//  Domain
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Foundation

public protocol GetPhotosUseCase {
    var photoRepository: PhotoRepository { get }
}

public extension GetPhotosUseCase {
    func getPhotos(pageInfo: PagingInfo) -> AnyPublisher<[Photo], Error> {
        photoRepository.fetchPhotos(page: pageInfo.page, perPage: pageInfo.itemsPerPage)
    }
}
