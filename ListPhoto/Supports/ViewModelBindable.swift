//
//  ViewModelBindable.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit

public protocol ViewModelBindable: AnyObject {
    associatedtype ViewModel

    var viewModel: ViewModel! { get set }

    func setupBindings()
}

public extension ViewModelBindable where Self: UIViewController {
    func attachViewModel(to model: Self.ViewModel) {
        viewModel = model
        loadViewIfNeeded()
        setupBindings()
    }
}
