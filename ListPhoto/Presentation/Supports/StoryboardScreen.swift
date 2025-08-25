//
//  StoryboardScreen.swift
//  ListPhoto
//
//  Created by TaiTruong on 25/8/25.
//

import UIKit
public protocol StoryboardScreen: AnyObject {
  static var storyboard: UIStoryboard { get }
  static var screenIdentifier: String { get }
}

public extension StoryboardScreen {
  static var screenIdentifier: String {
    return String(describing: self)
  }
}

// MARK: Support for instantiation from Storyboard

public extension StoryboardScreen where Self: UIViewController {
  static func instantiate() -> Self {
    let viewController = Self.storyboard.instantiateViewController(withIdentifier: self.screenIdentifier)
    guard let typedVC = viewController as? Self else {
      fatalError("The viewController '\(self.screenIdentifier)' of '\(Self.storyboard)' is not of class '\(self)'")
    }
    return typedVC
  }
}
