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

    override func tearDownWithError() throws {}

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testPerformance() {
        let app = XCUIApplication()
        app.launch()

        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 10), "Table must exist")

        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
        ]) {
            for _ in 0 ..< 10 {
                if app.state == .runningForeground {
                    table.swipeUp()
                    RunLoop.current.run(until: Date().addingTimeInterval(0.2))
                }
            }
        }
    }
}
