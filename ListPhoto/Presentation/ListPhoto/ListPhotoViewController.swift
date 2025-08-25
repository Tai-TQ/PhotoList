//
//  ListPhotoViewController.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit
import Combine

class ListPhotoViewController: UIViewController, ViewModelBindable {
    var viewModel: ListPhotoViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    private var loadData = PassthroughSubject<String, Never>()
    private var reloadData = PassthroughSubject<String, Never>()
    private var loadMoreData = PassthroughSubject<String, Never>()
    
    private var listPhoto: [Photo] = []
    private var filteredPhotos: [Photo] = []
    
    // UI
    private lazy var searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search by id or author"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindSearch()
        bindPullToRefresh()
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
            reloadData: reloadData.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input, cancellables: &cancellables)
        loadData.send("")
        
        output.$photos
            .dropFirst()
            .sinkOnMain({ [weak self] data in
                self?.listPhoto = data
                self?.filterPhotos(with: "")
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Bindings
    private func bindSearch() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.filterPhotos(with: text)
            }
            .store(in: &cancellables)
    }
    
    private func bindPullToRefresh() {
        reloadData.sink { [weak self] _ in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc
    private func didPullToRefresh() {
        reloadData.send("")
    }
    
    private func filterPhotos(with query: String) {
        if query.isEmpty {
            filteredPhotos = listPhoto
        } else {
            let lower = query.lowercased()
            filteredPhotos = listPhoto.filter { $0.id.lowercased().contains(lower) || $0.author.lowercased().contains(lower) }
        }
        tableView.reloadData()
    }
    
}

// MARK: - UITableView Delegate & DataSource
extension ListPhotoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        let photo = filteredPhotos[indexPath.row]
        cell.configure(with: photo)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchTextField.text?.isEmpty ?? true else { return } // not load if searching
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height - 50 {
            loadMoreData.send("")
        }
    }
}

extension ListPhotoViewController: StoryboardScreen {
    static var storyboard: UIStoryboard = Storyboards.photo
}
