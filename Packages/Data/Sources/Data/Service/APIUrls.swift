//
//  File.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import Foundation

extension APIService {
    enum Urls {
        private static let host = "https://picsum.photos/"
        private static let apiv2 = "v2/"

        static let getImages = host + apiv2 + "list"
    }
}
