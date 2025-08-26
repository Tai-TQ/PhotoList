//
//  File.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import Foundation
import Combine
import Domain

extension APIService {
    func getPhotosDTO(page: Int, perPage: Int) -> AnyPublisher<[PhotoDTO], Error> {
        guard var components = URLComponents(string: APIService.Urls.getImages) else {
            return Fail(error: APIServiceError.invalidURL).eraseToAnyPublisher()
        }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(perPage)")
        ]
        
        guard let url = components.url else {
            return Fail(error: APIServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [PhotoDTO].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
