//
//  ListPhotoUITests.swift
//  ListPhotoUITests
//
//  Created by TaiTruong on 27/8/25.
//

import XCTest

final class ListPhotoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    
}
