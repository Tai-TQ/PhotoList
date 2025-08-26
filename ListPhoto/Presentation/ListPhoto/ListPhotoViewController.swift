//
//  ListPhotoViewController.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit
import Combine
import Domain

class ListPhotoViewController: UIViewController, ViewModelBindable {
    var viewModel: ListPhotoViewModel!
    
    private var cancellables = Set<AnyCancellable>()    
    private var loadData = PassthroughSubject<Void, Never>()
    private var reloadData = PassthroughSubject<Void, Never>()
    private var loadMoreData = PassthroughSubject<Void, Never>()
    private var searchData = PassthroughSubject<String, Never>()
    
    private var listPhoto: [Photo] = []
    
    // UI
    private lazy var searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search by id or author"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.prefetchDataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var loadingFooterView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        footerView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        return footerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindSearch()
    }
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        let navView = UIView()
        navView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navView)
        navView.addSubview(searchTextField)
        view.addSubview(tableView)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        NSLayoutConstraint.activate([
            navView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navView.heightAnchor.constraint(equalToConstant: 60),
            searchTextField.leadingAnchor.constraint(equalTo: navView.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: navView.trailingAnchor, constant: -16),
            searchTextField.centerYAnchor.constraint(equalTo: navView.centerYAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            tableView.topAnchor.constraint(equalTo: navView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupBindings() {
        let input = ListPhotoViewModel.Input(
            loadData: loadData.eraseToAnyPublisher(),
            loadMoreData: loadMoreData.eraseToAnyPublisher(),
            reloadData: reloadData.eraseToAnyPublisher(),
            searchData: searchData.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input, cancellables: &cancellables)
//        loadData.send()
        
        output.$photos
            .dropFirst()
            .sinkOnMain({ [weak self] data in
                print("Load data success at \(Date())")
                self?.listPhoto = data
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
        
        output.$isLoading
            .subject
            .sinkOnMain({ [weak self] value in
                if value {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .store(in: &cancellables)
        
        output.$isReloading
            .subject
            .sinkOnMain({ [weak self] value in
                if value {
                    self?.refreshControl.beginRefreshing()
                } else {
                    self?.refreshControl.endRefreshing()
                }
            })
            .store(in: &cancellables)
        
        output.$isLoadingMore
            .subject
            .sinkOnMain({ [weak self] value in
                if value {
                    self?.tableView.tableFooterView = self?.loadingFooterView
                } else {
                    self?.tableView.tableFooterView = nil
                }
            })
            .store(in: &cancellables)
        
        output.$error
            .filter { $0 != nil }
            .sinkOnMain { [weak self] error in
                self?.showError(message: error?.localizedDescription ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Bindings
    private func bindSearch() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.searchData.send(text)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc
    private func didPullToRefresh() {
        reloadData.send()
    }
}

// MARK: - UITableView Delegate & DataSource
extension ListPhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPhoto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        let photo = listPhoto[indexPath.row]
        cell.configure(with: photo, imageUseCase: viewModel.imageUseCase)
        return cell
    }
}

extension ListPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Ensure image is loaded when cell becomes visible
        guard let photoCell = cell as? PhotoCell,
              indexPath.row < listPhoto.count else { return }
        
        let photo = listPhoto[indexPath.row]
        let targetSize = photo.displayedSize(for: UIScreen.main.bounds.width)
        
        photoCell.loadImage(urlString: photo.url, imageUseCase: viewModel.imageUseCase, targetSize: targetSize)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Cancel image loading for cells that are no longer visible
        guard let photoCell = cell as? PhotoCell else { return }
        photoCell.cancelImageLoad()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchTextField.text?.isEmpty ?? true else { return } // not load if searching
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height - 150 {
            loadMoreData.send()
        }
    }
}

//extension ListPhotoViewController: UITableViewDataSourcePrefetching {
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//            guard indexPath.row < filteredPhotos.count else { continue }
//            if prefetchCancellables[indexPath] != nil { continue } // Avoid duplicates
//            
//            let photo = filteredPhotos[indexPath.row]
//            let screenWidth = UIScreen.main.bounds.width
//            let padding: CGFloat = 16
//            let maxWidth = screenWidth - 2 * padding
//            let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
//            let height = maxWidth * aspectRatio
//            let targetSize = CGSize(width: maxWidth, height: height)
//            let scale = UIScreen.main.scale
//            
//            // Prefetch image to cache
//            let publisher = viewModel.imageUseCase.fetchImageData(
//                urlString: photo.url,
//                targetSize: targetSize,
//                scale: scale
//            )
//            
//            let cancellable = publisher
//                .sink(
//                    receiveCompletion: { [weak self] _ in
//                        self?.prefetchCancellables.removeValue(forKey: indexPath)
//                    },
//                    receiveValue: { _ in
//                        // Image is now cached, no need to do anything
//                    }
//                )
//            
//            prefetchCancellables[indexPath] = cancellable
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//            prefetchCancellables[indexPath]?.cancel()
//            prefetchCancellables.removeValue(forKey: indexPath)
//        }
//    }
//}

extension ListPhotoViewController: StoryboardScreen {
    static var storyboard: UIStoryboard = Storyboards.photo
}
