//
//  SplashViewModelTest.swift
//  ListPhotoTests
//
//  Created by TaiTruong on 28/8/25.
//

import Combine
@testable import ListPhoto
import XCTest

final class SplashViewModelTest: XCTestCase {
    private var viewModel: SplashViewModel!
    private var navigator: SplashNavigatorMock!
    private var useCase: SplashUseCaseMock!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        navigator = SplashNavigatorMock()
        useCase = SplashUseCaseMock()
        viewModel = SplashViewModel(navigator: navigator, useCase: useCase)
        cancellables = []
    }

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        viewModel = nil
        navigator = nil
        useCase = nil
        super.tearDown()
    }

    func test_transform_loadData_triggersNavigationAfterDelay() {
        let expectation = expectation(description: "Navigate to list photo after delay")
        navigator.onToListPhoto = { expectation.fulfill() }

        let loadData = PassthroughSubject<Void, Never>()
        let input = SplashViewModel.Input(loadData: loadData.eraseToAnyPublisher())
        _ = viewModel.transform(input, cancellables: &cancellables)

        // When
        loadData.send(())

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(navigator.toListPhotoCalled)
        XCTAssertEqual(navigator.toListPhotoCallCount, 1)
    }

    func test_transform_multipleLoadData_onlyFirstTriggersNavigation() {
        let expectation = expectation(description: "Only first load triggers navigation")
        navigator.onToListPhoto = { expectation.fulfill() }

        let loadData = PassthroughSubject<Void, Never>()
        let input = SplashViewModel.Input(loadData: loadData.eraseToAnyPublisher())
        _ = viewModel.transform(input, cancellables: &cancellables)

        // When
        loadData.send(())
        loadData.send(())
        loadData.send(())

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(navigator.toListPhotoCalled)
        XCTAssertEqual(navigator.toListPhotoCallCount, 1)
    }
}
