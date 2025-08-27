//
//  File.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import Domain
import Foundation

extension APIService {
    func fetchImageData(urlString: String) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: APIServiceError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
