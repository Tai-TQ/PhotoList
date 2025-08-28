//
//  ImageUseCase.swift
//  Domain
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Foundation
import UIKit

public protocol ImageUseCase {
    var imageRepository: ImageRepository { get }
}

public extension ImageUseCase {
    func fetchImageData(urlString: String,
                        targetSize: CGSize,
                        scale: CGFloat) -> AnyPublisher<UIImage, Error>
    {
        imageRepository.fetchImageData(urlString: urlString,
                                       targetSize: targetSize,
                                       scale: scale)
    }
}
