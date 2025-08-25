//
//  PhotoCell.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(idLabel)
        contentView.addSubview(authorLabel)
        NSLayoutConstraint.activate([
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            authorLabel.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            authorLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    func configure(with photo: Photo) {
        idLabel.text = "ID: \(photo.id)"
        authorLabel.text = "Author: \(photo.author)"
    }
}
