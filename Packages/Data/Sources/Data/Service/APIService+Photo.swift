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
        
        var request = URLRequest(url: url, timeoutInterval: 30)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .timeout(.seconds(30), scheduler: DispatchQueue.main)
            .map(\.data)
            .decode(type: [PhotoDTO].self, decoder: JSONDecoder())
            .mapError { error in
                 if let urlError = error as? URLError {
                    switch urlError.code {
                    case .timedOut:
                        return APIServiceError.timeout
                    case .notConnectedToInternet, .networkConnectionLost:
                        return APIServiceError.noInternetConnection
                    case .cannotFindHost, .cannotConnectToHost:
                        return APIServiceError.serverUnavailable
                    default:
                        return APIServiceError.networkError(urlError.localizedDescription)
                    }
                } else if error is DecodingError {
                    return APIServiceError.decodingError
                } else {
                    return APIServiceError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}
