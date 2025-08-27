//
//  Assembler.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

protocol Assembler: AnyObject,
    ServiceAssembler,
    RepositoryAssembler,
    ListPhotoAssembler {}

final class DefaultAssembler: Assembler {}
