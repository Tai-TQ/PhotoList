//
//  SplashViewController.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Combine
import Domain
import os.signpost
import UIKit

class SplashViewController: UIViewController, ViewModelBindable {
    var viewModel: SplashViewModel!

    private var cancellables = Set<AnyCancellable>()
    private var loadData = PassthroughSubject<Void, Never>()

    // MARK: - UI

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Photo List"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData.send(())
    }

    deinit {
        debugPrint("SplashViewController deinit")
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    func setupBindings() {
        let input = SplashViewModel.Input(
            loadData: loadData.eraseToAnyPublisher()
        )

        _ = viewModel.transform(input, cancellables: &cancellables)
    }
}
