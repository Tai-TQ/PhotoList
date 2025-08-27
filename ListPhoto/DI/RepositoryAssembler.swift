//
//  RepositoryAssembler.swift
//  ListPhoto
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Data
import Domain

protocol RepositoryAssembler: ServiceAssembler {
    func resolvePhotoRepository() -> PhotoRepository
    func resolveImageRepository() -> ImageRepository
}

extension RepositoryAssembler where Self: DefaultAssembler {
    func resolvePhotoRepository() -> PhotoRepository {
        let apiService = resolveAPIService()
        return PhotoRepositoryImpl(apiService: apiService)
    }

    func resolveImageRepository() -> ImageRepository {
        let apiService = resolveAPIService()
        return ImageRepositoryImpl(apiService: apiService)
    }
}
