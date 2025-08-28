//
//  UnitTestViewController.swift
//  ListPhoto
//
//  Created by TaiTruong on 27/8/25.
//

import UIKit

final class UnitTestViewController: UIViewController {
    lazy var testingLabel: UILabel = {
        let label = UILabel()
        label.text = "Testing..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.tintColor = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.addSubview(testingLabel)
        view.addSubview(indicator)
        indicator.startAnimating()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            testingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: testingLabel.bottomAnchor, constant: 18),
        ])
    }
}
