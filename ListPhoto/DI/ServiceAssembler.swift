//
//  ServiceAssembler.swift
//  ListPhoto
//
//  Created by TaiTruong on 26/8/25.
//

import Data
import Foundation

protocol ServiceAssembler {
    func resolveAPIService() -> APIService
}

extension ServiceAssembler where Self: DefaultAssembler {
    func resolveAPIService() -> APIService {
        return APIService.shared
    }
}
