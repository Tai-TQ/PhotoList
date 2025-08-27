//
//  UIImage+Placeholder.swift
//  ListPhoto
//
//  Created by TaiTruong on 26/8/25.
//

import UIKit

extension UIImage {
    static func placeholder(size: CGSize, backgroundColor: UIColor = .systemGray6) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Add loading indicator style
            let iconSize: CGFloat = min(size.width, size.height) * 0.3
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )

            UIColor.systemGray3.setFill()
            context.cgContext.fillEllipse(in: iconRect)
        }
    }
}
