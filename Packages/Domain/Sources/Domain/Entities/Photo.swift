//
//  Photo.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation

public struct Photo: Equatable {
    public let id: String
    public let author: String
    public let width: Int
    public let height: Int
    public let url: String

    public init(id: String, author: String, width: Int, height: Int, url: String) {
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.url = url
    }

    public func displayedSize(for displayWidth: CGFloat) -> CGSize {
        guard width > 0, height > 0 else { return .zero }
        let ratio = CGFloat(height) / CGFloat(width)
        return CGSize(width: displayWidth, height: displayWidth * ratio)
    }
}

public extension Photo {
    static func mock(id: String = "1", author: String = "TQT" ) -> Photo {
        return Photo(
            id: id,
            author: author,
            width: 4320,
            height: 3240,
            url: "https://unsplash.com/photos/pJILiyPdrXI"
        )
    }
}
