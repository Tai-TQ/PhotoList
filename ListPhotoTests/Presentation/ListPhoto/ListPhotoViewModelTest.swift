//
//  ListPhotoViewModelTest.swift
//  ListPhotoTests
//
//  Created by TaiTruong on 27/8/25.
//

import XCTest
import Combine
@testable import ListPhoto
import Domain

class ListPhotoViewModelTest: XCTestCase {
    var viewModel: ListPhotoViewModel!
    var navigator: ListPhotoNavigatorMock!
    var useCase: ListPhotoUseCaseMock!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        navigator = ListPhotoNavigatorMock()
        useCase = ListPhotoUseCaseMock()
        viewModel = ListPhotoViewModel(navigator: navigator, useCase: useCase)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        viewModel = nil
        useCase = nil
        navigator = nil
        super.tearDown()
    }

    func test_transform_loadData_success() {
        let expectation = XCTestExpectation(description: "Load data success")
        let loadData = PassthroughSubject<Void, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: loadData.eraseToAnyPublisher(),
            loadMoreData: Empty<Void, Never>().eraseToAnyPublisher(),
            reloadData: Empty<Void, Never>().eraseToAnyPublisher(),
            searchData: Empty<String, Never>().eraseToAnyPublisher(),
            toPhotoDetail: Empty<String, Never>().eraseToAnyPublisher()
        )
        let output = viewModel.transform(input, cancellables: &cancellables)
        var photos: [Photo]?
        
        output.$photos
            .dropFirst()
            .sink { receivedPhotos in
                photos = receivedPhotos
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        let expectedPhotos = [Photo.mock()]
        useCase.getPhotosResponse = expectedPhotos
        loadData.send(())

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertEqual(photos?.count, 1)
        XCTAssertEqual(photos?.first?.id, "1")
    }

    func test_transform_loadData_failure() {
        let expectation = XCTestExpectation(description: "Load data failure")
        let loadData = PassthroughSubject<Void, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: loadData.eraseToAnyPublisher(),
            loadMoreData: Empty<Void, Never>().eraseToAnyPublisher(),
            reloadData: Empty<Void, Never>().eraseToAnyPublisher(),
            searchData: Empty<String, Never>().eraseToAnyPublisher(),
            toPhotoDetail: Empty<String, Never>().eraseToAnyPublisher()
        )
        let output = viewModel.transform(input, cancellables: &cancellables)
        var error: Error?
        
        output.$error
            .compactMap { $0 }
            .sink { receivedError in
                error = receivedError
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        useCase.getPhotosError = TestError.test
        loadData.send(())

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertNotNil(error)
    }
    
    func test_transform_reloadData_success() {
        let expectation = XCTestExpectation(description: "Reload data success")
        let reloadData = PassthroughSubject<Void, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: Empty<Void, Never>().eraseToAnyPublisher(),
            loadMoreData: Empty<Void, Never>().eraseToAnyPublisher(),
            reloadData: reloadData.eraseToAnyPublisher(),
            searchData: Empty<String, Never>().eraseToAnyPublisher(),
            toPhotoDetail: Empty<String, Never>().eraseToAnyPublisher()
        )
        let output = viewModel.transform(input, cancellables: &cancellables)
        var photos: [Photo]?
        
        output.$photos
            .dropFirst()
            .sink { receivedPhotos in
                photos = receivedPhotos
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        let expectedPhotos = [Photo.mock()]
        useCase.getPhotosResponse = expectedPhotos
        reloadData.send(())

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertEqual(photos?.count, 1)
        XCTAssertEqual(photos?.first?.id, "1")
    }

    func test_transform_reloadData_failure() {
        let expectation = XCTestExpectation(description: "Reoad data failure")
        let reloadData = PassthroughSubject<Void, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: Empty<Void, Never>().eraseToAnyPublisher(),
            loadMoreData: Empty<Void, Never>().eraseToAnyPublisher(),
            reloadData: reloadData.eraseToAnyPublisher(),
            searchData: Empty<String, Never>().eraseToAnyPublisher(),
            toPhotoDetail: Empty<String, Never>().eraseToAnyPublisher()
        )
        let output = viewModel.transform(input, cancellables: &cancellables)
        var error: Error?
        
        output.$error
            .compactMap { $0 }
            .sink { receivedError in
                error = receivedError
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        useCase.getPhotosError = TestError.test
        reloadData.send(())

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertNotNil(error)
    }

    func test_transform_loadMoreData_success() {
        let expectationInitial = XCTestExpectation(description: "Initial load success")
        let expectationLoadMore = XCTestExpectation(description: "Load more success")
        let loadData = PassthroughSubject<Void, Never>()
        let loadMoreData = PassthroughSubject<Void, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: loadData.eraseToAnyPublisher(),
            loadMoreData: loadMoreData.eraseToAnyPublisher(),
            reloadData: Empty<Void, Never>().eraseToAnyPublisher(),
            searchData: Empty<String, Never>().eraseToAnyPublisher(),
            toPhotoDetail: Empty<String, Never>().eraseToAnyPublisher()
        )
        let output = viewModel.transform(input, cancellables: &cancellables)
        var photos: [Photo]?
        var photoUpdateCount = 0
        
        output.$photos
            .dropFirst()
            .sink { receivedPhotos in
                print("\(photoUpdateCount) | \(receivedPhotos.count)")
                photos = receivedPhotos
                photoUpdateCount += 1
                if photoUpdateCount == 1 {
                    expectationInitial.fulfill()
                } else if photoUpdateCount == 2 {
                    expectationLoadMore.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        let initialPhotos = Array(repeating: Photo.mock(), count: 100)
        useCase.getPhotosResponse = initialPhotos
        
        loadData.send(())
        wait(for: [expectationInitial], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertEqual(photos?.count, 100)
        XCTAssertEqual(photos?.last?.id, "1")
        
        useCase.getPhotosCalled = false
        
        let morePhotos = [Photo.mock(id: "2")]
        useCase.getPhotosResponse = morePhotos
        loadMoreData.send(())
        
        // Then
        wait(for: [expectationLoadMore], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertEqual(photos?.count, 101)
        XCTAssertEqual(photos?.last?.id, "2")
    }
    
    func test_transform_loadMoreData_failure() {
        let expectationInitial = XCTestExpectation(description: "Initial load success")
        let expectationLoadMore = XCTestExpectation(description: "Load more failure")
        let loadData = PassthroughSubject<Void, Never>()
        let loadMoreData = PassthroughSubject<Void, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: loadData.eraseToAnyPublisher(),
            loadMoreData: loadMoreData.eraseToAnyPublisher(),
            reloadData: Empty<Void, Never>().eraseToAnyPublisher(),
            searchData: Empty<String, Never>().eraseToAnyPublisher(),
            toPhotoDetail: Empty<String, Never>().eraseToAnyPublisher()
        )
        let output = viewModel.transform(input, cancellables: &cancellables)
        var photos: [Photo]?
        var photoUpdateCount = 0
        var error: Error?
        
        output.$photos
            .dropFirst()
            .sink { receivedPhotos in
                print("\(photoUpdateCount) | \(receivedPhotos.count)")
                photos = receivedPhotos
                photoUpdateCount += 1
                if photoUpdateCount == 1 {
                    expectationInitial.fulfill()
                }
            }
            .store(in: &cancellables)
        
        output.$error
            .compactMap { $0 }
            .sink { receivedError in
                error = receivedError
                expectationLoadMore.fulfill()
            }
            .store(in: &cancellables)

        // When
        let initialPhotos = Array(repeating: Photo.mock(), count: 100)
        useCase.getPhotosResponse = initialPhotos
        loadData.send(())
        
        // Then
        wait(for: [expectationInitial], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertEqual(photos?.count, 100)
        XCTAssertEqual(photos?.first?.id, "1")
        
        // When
        useCase.getPhotosCalled = false
        useCase.getPhotosError = TestError.test
        loadMoreData.send(())
        
        // Then
        wait(for: [expectationLoadMore], timeout: 1.0)
        XCTAssertTrue(useCase.getPhotosCalled)
        XCTAssertEqual(photos?.count, 100)
        XCTAssertEqual(photos?.first?.id, "1")
        XCTAssertNotNil(error)
    }

    func test_transform_toPhotoDetail() {
        let expectation = XCTestExpectation(description: "Navigate to photo detail")
        let toPhotoDetail = PassthroughSubject<String, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: Empty<Void, Never>().eraseToAnyPublisher(),
            loadMoreData: Empty<Void, Never>().eraseToAnyPublisher(),
            reloadData: Empty<Void, Never>().eraseToAnyPublisher(),
            searchData: Empty<String, Never>().eraseToAnyPublisher(),
            toPhotoDetail: toPhotoDetail.eraseToAnyPublisher()
        )
        _ = viewModel.transform(input, cancellables: &cancellables)

        // When
        toPhotoDetail.send("1")

        // delay to allow throttling to process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(navigator.toPhotoDetailCalled)
        XCTAssertEqual(navigator.toPhotoDetailPhotoId, "1")
    }
    
    func test_transform_searchData_success() {
        let expectationInitialLoad = XCTestExpectation(description: "Initial data loaded")
        let expectationSearch1 = XCTestExpectation(description: "Search for Tai")
        let expectationSearch2 = XCTestExpectation(description: "Search for Truong")  
        let expectationSearch3 = XCTestExpectation(description: "Search for 1")
        let expectationSearch4 = XCTestExpectation(description: "Search for 2")
        let expectationSearchEmpty = XCTestExpectation(description: "Empty search")
        
        let loadData = PassthroughSubject<Void, Never>()
        let searchData = PassthroughSubject<String, Never>()
        let input = ListPhotoViewModel.Input(
            loadData: loadData.eraseToAnyPublisher(),
            loadMoreData: Empty<Void, Never>().eraseToAnyPublisher(),
            reloadData: Empty<Void, Never>().eraseToAnyPublisher(),
            searchData: searchData.eraseToAnyPublisher(),
            toPhotoDetail: Empty<String, Never>().eraseToAnyPublisher()
        )
        let output = viewModel.transform(input, cancellables: &cancellables)
        var photos: [Photo]?
        var searchStepCount = 0

        output.$photos
            .dropFirst()
            .sink { receivedPhotos in
                photos = receivedPhotos
                searchStepCount += 1
                
                switch searchStepCount {
                case 1:
                    expectationInitialLoad.fulfill()
                case 2:
                    expectationSearch1.fulfill()
                case 3:
                    expectationSearch2.fulfill()
                case 4:
                    expectationSearch3.fulfill()
                case 5:
                    expectationSearch4.fulfill()
                case 6:
                    expectationSearchEmpty.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)

        let initialPhotos = [
            Photo.mock(author: "Tai"),
            Photo.mock(id: "2", author: "Truong")
        ]
        useCase.getPhotosResponse = initialPhotos
        loadData.send(())

        wait(for: [expectationInitialLoad], timeout: 1.0)
        XCTAssertEqual(photos?.count, 2)

        searchData.send("Tai")
        wait(for: [expectationSearch1], timeout: 1.0)
        XCTAssertEqual(photos?.count, 1)
        XCTAssertEqual(photos?.first?.author, "Tai")
        
        searchData.send("Truong")
        wait(for: [expectationSearch2], timeout: 1.0)
        XCTAssertEqual(photos?.count, 1)
        XCTAssertEqual(photos?.first?.author, "Truong")
        
        searchData.send("1")
        wait(for: [expectationSearch3], timeout: 1.0)
        XCTAssertEqual(photos?.count, 1)
        XCTAssertEqual(photos?.first?.author, "Tai")
        
        searchData.send("2")
        wait(for: [expectationSearch4], timeout: 1.0)
        XCTAssertEqual(photos?.count, 1)
        XCTAssertEqual(photos?.first?.author, "Truong")
        
        searchData.send("")
        wait(for: [expectationSearchEmpty], timeout: 1.0)
        XCTAssertEqual(photos?.count, 2)
    }
}

enum TestError: Error {
    case test
}

