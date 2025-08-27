//
//  PhotoRepository.swift
//  Domain
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Foundation

public protocol PhotoRepository {
    func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[Photo], Error>
}
