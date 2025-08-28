//
//  ListPhotoNavigatorMock.swift
//  ListPhotoTests
//
//  Created by TaiTruong on 27/8/25.
//

import Foundation
@testable import ListPhoto

final class ListPhotoNavigatorMock: ListPhotoNavigatorType {
    var toPhotoDetailCalled = false
    var toPhotoDetailPhotoId: String?
    func toPhotoDetail(id: String) {
        toPhotoDetailCalled = true
        toPhotoDetailPhotoId = id
    }
}
