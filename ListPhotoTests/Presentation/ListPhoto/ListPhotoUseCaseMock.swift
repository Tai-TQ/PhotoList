//
//  ListPhotoUseCaseMock.swift
//  ListPhotoTests
//
//  Created by TaiTruong on 27/8/25.
//

import Combine
import Domain
@testable import ListPhoto
import UIKit

final class ListPhotoUseCaseMock: ListPhotoUseCaseType {
    var getPhotosCalled = false
    var getPhotosResponse: [Photo] = []
    var getPhotosError: Error?

    func getPhotos(pageInfo _: PagingInfo) -> AnyPublisher<[Photo], Error> {
        getPhotosCalled = true
        let response = getPhotosResponse
        let error = getPhotosError
        let queue = DispatchQueue(label: "ListPhotoUseCaseMock.queue")

        if let error {
            return Deferred {
                Future<[Photo], Error> { promise in
                    queue.asyncAfter(deadline: .now() + 0.01) {
                        promise(.failure(error))
                    }
                }
            }.eraseToAnyPublisher()
        }

        return Deferred {
            Future<[Photo], Error> { promise in
                queue.asyncAfter(deadline: .now() + 0.01) {
                    promise(.success(response))
                }
            }
        }.eraseToAnyPublisher()
    }

    var imageCalled = false
    var imageReturnValue = PassthroughSubject<UIImage, Error>()

    func fetchImageData(urlString _: String,
                        targetSize _: CGSize,
                        scale _: CGFloat) -> AnyPublisher<UIImage, any Error>
    {
        imageCalled = true
        return imageReturnValue.eraseToAnyPublisher()
    }
}
