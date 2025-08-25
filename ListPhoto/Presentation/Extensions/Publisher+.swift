//
//  Publisher+.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Combine
import Foundation

extension Publisher where Self.Failure == Never {
    func sinkOnMain(_ receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        self
            .receive(on: RunLoop.main)
            .sink(receiveValue: receiveValue)
    }
}

