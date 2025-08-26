//
//  PhotoDTO.swift
//  Data
//
//  Created by TaiTruong on 26/8/25.
//

import Foundation

struct PhotoDTO: Codable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let download_url: String
}
