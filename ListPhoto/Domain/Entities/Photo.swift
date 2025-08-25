//
//  Photo.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation

struct Photo: Codable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadURL: String // Currently not used

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url
        case downloadURL = "download_url"
    }
}

extension Photo {
    static func mock() -> Photo {
        return Photo(
            id: "102",
            author: "Ben Moore",
            width: 4320,
            height: 3240,
            url: "https://unsplash.com/photos/pJILiyPdrXI",
            downloadURL: "https://picsum.photos/id/102/4320/3240"
        )
    }
}
