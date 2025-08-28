//
//  SplashNavigatorMock.swift
//  ListPhotoTests
//
//  Created by TaiTruong on 28/8/25.
//

import Foundation
@testable import ListPhoto

final class SplashNavigatorMock: SplashNavigatorType {
	var toListPhotoCalled = false
	var toListPhotoCallCount = 0
	var onToListPhoto: (() -> Void)?

	func toListPhoto() {
		toListPhotoCalled = true
		toListPhotoCallCount += 1
		onToListPhoto?()
	}
}
