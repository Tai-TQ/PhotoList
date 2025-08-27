//
//  ListPhotoUseCase.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Combine
import Domain
import Foundation
import UIKit

protocol ListPhotoUseCaseType {
    func getPhotos(pageInfo: PagingInfo) -> AnyPublisher<[Photo], Error>
    func fetchImageData(urlString: String,
                        targetSize: CGSize,
                        scale: CGFloat) -> AnyPublisher<UIImage, Error>
}

struct ListPhotoUseCase: ListPhotoUseCaseType, GetPhotosUseCase, ImageUseCase {
    var imageRepository: Domain.ImageRepository
    var photoRepository: Domain.PhotoRepository
}
