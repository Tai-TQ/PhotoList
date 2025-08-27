//
//  ListPhotoNavigator.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

protocol ListPhotoNavigatorType {
    func toPhotoDetail()
}

struct ListPhotoNavigator: ListPhotoNavigatorType {
    unowned let assembler: Assembler
    unowned let navigation: UINavigationController

    func toPhotoDetail() {}
}
