//
//  PagingInfo.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Foundation

public struct PagingInfo {
    public var page: Int
    public var itemsPerPage: Int
    
    public init(page: Int = 1,
                itemsPerPage: Int = 0) {
        self.page = page
        self.itemsPerPage = itemsPerPage
    }
}
