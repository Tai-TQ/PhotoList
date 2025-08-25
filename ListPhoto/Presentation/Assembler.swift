//
//  Assembler.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

protocol Assembler: AnyObject,
AppAssembler,
ListPhotoAssembler {}

final class DefaultAssembler: Assembler {}
