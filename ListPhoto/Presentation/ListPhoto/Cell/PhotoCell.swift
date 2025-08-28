//
//  PhotoCell.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import Domain
import UIKit

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"

    private lazy var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var imageHeightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        // Clear text
        authorLabel.text = nil
        sizeLabel.text = nil
    }

    private func setupUI() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(sizeLabel)

        let padding: CGFloat = 16
        let spacing: CGFloat = 2

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            authorLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: spacing),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            sizeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: spacing),
            sizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            sizeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
        ])

        imageHeightConstraint = photoImageView.heightAnchor.constraint(equalToConstant: 200)
        imageHeightConstraint?.priority = UILayoutPriority(rawValue: 999) // for disable log warning
        imageHeightConstraint?.isActive = true
        selectionStyle = .none
    }

    func configure(with photo: Photo) {
        let targetSize = photo.displayedSize(for: UIScreen.main.bounds.width)
        imageHeightConstraint?.constant = targetSize.height

        authorLabel.text = photo.author
        sizeLabel.text = "Size: \(Int(targetSize.width)) x \(Int(targetSize.height.rounded()))"
    }

    func loadImage(urlString: String, imageUseCase: ListPhotoUseCaseType, targetSize: CGSize) {
        photoImageView.setImage(urlString: urlString, imageUseCase: imageUseCase, targetSize: targetSize)
    }

    func cancelImageLoad() {
        photoImageView.cancelImageLoad()
    }
}
