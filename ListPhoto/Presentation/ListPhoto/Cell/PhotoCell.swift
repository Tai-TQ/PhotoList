//
//  PhotoCell.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit
import Domain

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"
    
    private lazy var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var imageHeightConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(idLabel)
        contentView.addSubview(authorLabel)
        
        let padding: CGFloat = 16
        let spacing: CGFloat = 4
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            idLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: spacing),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            authorLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: spacing),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
        imageHeightConstraint = photoImageView.heightAnchor.constraint(equalToConstant: 200)
        imageHeightConstraint?.priority = UILayoutPriority(rawValue: 999)
        imageHeightConstraint?.isActive = true
        selectionStyle = .none
    }
    
    func configure(with photo: Photo, imageUseCase: ImageUseCase) {
        let targetSize = photo.displayedSize(for: UIScreen.main.bounds.width)
        imageHeightConstraint?.constant = targetSize.height
        
        idLabel.text = "ID: \(photo.id)"
        authorLabel.text = "Author: \(photo.author)"
    }
    
    func loadImage(urlString: String, imageUseCase: ImageUseCase, targetSize: CGSize) {
        photoImageView.setImage(urlString: urlString, imageUseCase: imageUseCase, targetSize: targetSize)
    }
    
    func cancelImageLoad() {
        photoImageView.cancelImageLoad()
    }
}

