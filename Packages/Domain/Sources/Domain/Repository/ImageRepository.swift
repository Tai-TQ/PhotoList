//
//  ImageRepository.swift
//  Domain
//
//  Created by TaiTruong on 26/8/25.
//

import Foundation
import Combine
import UIKit

public protocol ImageRepository {
//    func fetchImageData(urlString: String) -> AnyPublisher<Data, Error>
    func fetchImageData(urlString: String,
                   targetSize: CGSize,
                   scale: CGFloat) -> AnyPublisher<UIImage, Error>
}
