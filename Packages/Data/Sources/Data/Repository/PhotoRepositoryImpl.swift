//
//  PhotoRepositoryImpl.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Domain

public final class PhotoRepositoryImpl: PhotoRepository {
    private let apiService: APIService

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[Photo], Error> {
        apiService.getPhotosDTO(page: page, perPage: perPage)
            .map { dtoList in
                dtoList.map { dto in
                    Photo(
                        id: dto.id,
                        author: dto.author,
                        width: dto.width,
                        height: dto.height,
                        url: dto.download_url
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
