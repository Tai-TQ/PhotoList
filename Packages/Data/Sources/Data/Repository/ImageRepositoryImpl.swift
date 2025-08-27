//
//  ImageRepositoryImpl.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Domain
import Foundation
import UIKit

public final class ImageRepositoryImpl: ImageRepository {
    private let apiService: APIService
    private let imageCache = ImageCache.shared

    private var cancellables = Set<AnyCancellable>()

    public init(apiService: APIService) {
        self.apiService = apiService
    }

    public func fetchImageData(urlString: String,
                               targetSize: CGSize,
                               scale: CGFloat) -> AnyPublisher<UIImage, Error>
    {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        // 1. Check cache first
        return Future<UIImage, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(URLError(.unknown)))
                return
            }

            // Try cache first
            self.imageCache.getCachedImage(for: url, targetSize: targetSize) { cachedImage in
                if let cachedImage = cachedImage {
                    // Cache hit - return immediately
                    promise(.success(cachedImage))
                } else {
                    // Cache miss - fetch from network
                    self.fetchFromNetwork(url: url, targetSize: targetSize, scale: scale, promise: promise)
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func fetchFromNetwork(url: URL,
                                  targetSize: CGSize,
                                  scale: CGFloat,
                                  promise: @escaping (Result<UIImage, Error>) -> Void)
    {
        apiService
            .fetchImageData(urlString: url.absoluteString)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                },
                receiveValue: { [weak self] data in
                    guard let self = self,
                          let image = UIImage(data: data)
                    else {
                        promise(.failure(URLError(.cannotDecodeContentData)))
                        return
                    }

                    // Save to cache (async - không block)
                    self.imageCache.saveImage(image, for: url, targetSize: targetSize, scale: scale)

                    // Return image immediately (không cần đợi cache save)
                    promise(.success(image))
                }
            )
            .store(in: &cancellables)
    }
}
