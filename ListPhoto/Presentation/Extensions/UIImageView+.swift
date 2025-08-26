//
//  UIImageView+.swift
//  ListPhoto
//
//  Created by TaiTruong on 26/8/25.
//

import UIKit
import Combine
import Domain

private class CancellableBag {
    var set: Set<AnyCancellable> = []
}

private var cancellablesKey: UInt8 = 0

extension UIImageView {
    private var cancellables: CancellableBag {
        get {
            if let bag = objc_getAssociatedObject(self, &cancellablesKey) as? CancellableBag {
                return bag
            }
            let bag = CancellableBag()
            objc_setAssociatedObject(self, &cancellablesKey, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
        set {
            objc_setAssociatedObject(self, &cancellablesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setImage(urlString: String, placeholder: UIImage? = nil, imageUseCase: ImageUseCase, targetSize: CGSize) {
        self.image = placeholder
        
        // Cancel previous requests
        cancelImageLoad()
        
        let scale = UIScreen.main.scale
        
        imageUseCase.fetchImageData(urlString: urlString, targetSize: targetSize, scale: scale)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load image from \(urlString): \(error)")
                    }
                },
                receiveValue: { [weak self] image in
                    self?.image = image
                }
            )
            .store(in: &cancellables.set)
    }
    
    func cancelImageLoad() {
        cancellables.set.forEach { $0.cancel() }
        cancellables.set.removeAll()
    }
}
