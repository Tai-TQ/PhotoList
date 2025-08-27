//
//  ListPhotoViewController.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Combine
import Domain
import UIKit

class ListPhotoViewController: UIViewController, ViewModelBindable {
    var viewModel: ListPhotoViewModel!

    private var cancellables = Set<AnyCancellable>()
    private var loadData = PassthroughSubject<Void, Never>()
    private var reloadData = PassthroughSubject<Void, Never>()
    private var loadMoreData = PassthroughSubject<Void, Never>()
    private var toPhotoDetail = PassthroughSubject<String, Never>()

    private var listPhoto: [Photo] = []
    private var isLoadingMore: Bool = false

    private lazy var searchTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Search by Id or Author"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
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
            activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
        ])
        return footerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
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
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func setupBindings() {
        let searchDataTrigger = searchTextField.textPublisher
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
        let input = ListPhotoViewModel.Input(
            loadData: loadData.eraseToAnyPublisher(),
            loadMoreData: loadMoreData.eraseToAnyPublisher(),
            reloadData: reloadData.eraseToAnyPublisher(),
            searchData: searchDataTrigger,
            toPhotoDetail: toPhotoDetail.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input, cancellables: &cancellables)

        output.$photos
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self = self else { return }

                let oldCount = self.listPhoto.count
                let newCount = data.count

                if oldCount == 0 || newCount <= oldCount { // load or reload
                    self.listPhoto = data
                    self.tableView.reloadData()
                } else { // loadmore
                    let startIndex = oldCount
                    let endIndex = newCount - 1

                    self.listPhoto = data

                    var indexPaths: [IndexPath] = []
                    for i in startIndex ... endIndex {
                        indexPaths.append(IndexPath(row: i, section: 0))
                    }

                    self.tableView.insertRows(at: indexPaths, with: .none)
                }
            }
            .store(in: &cancellables)
        
        output.$searchData
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.listPhoto = data
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        output.$isLoading
            .subject
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)

        output.$isReloading
            .subject
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    self?.refreshControl.beginRefreshing()
                } else {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        output.$isLoadingMore
            .subject
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.isLoadingMore = value
                if value {
                    self?.tableView.tableFooterView = self?.loadingFooterView
                } else {
                    self?.tableView.tableFooterView = nil
                }
            }
            .store(in: &cancellables)

        output.$error
            .filter { $0 != nil }
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.showError(message: error?.localizedDescription ?? "")
            }
            .store(in: &cancellables)

        loadData.send()
    }

    // MARK: - Actions

    @objc
    private func didPullToRefresh() {
        reloadData.send()
    }
}

// MARK: - UITableView Delegate & DataSource

extension ListPhotoViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return listPhoto.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        cell.configure(with: listPhoto[indexPath.row])
        return cell
    }
}

extension ListPhotoViewController: UITableViewDelegate {
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Ensure image is loaded when cell becomes visible
        guard let photoCell = cell as? PhotoCell,
              indexPath.row < listPhoto.count else { return }

        let photo = listPhoto[indexPath.row]
        let targetSize = photo.displayedSize(for: UIScreen.main.bounds.width)

        photoCell.loadImage(urlString: photo.url, imageUseCase: viewModel.useCase, targetSize: targetSize)

        if !isLoadingMore,
           indexPath.row >= listPhoto.count - 10,
           searchTextField.textPublisher.value.isEmpty
        {
            isLoadingMore = true
            loadMoreData.send()
        }
    }

    func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath) {
        guard let photoCell = cell as? PhotoCell else { return }
        photoCell.cancelImageLoad()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toPhotoDetail.send(listPhoto[indexPath.row].id)
    }
}
