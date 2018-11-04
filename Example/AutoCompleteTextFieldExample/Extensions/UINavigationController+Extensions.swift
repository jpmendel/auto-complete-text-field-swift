//
//  UINavigationController+Extensions.swift
//  AutoCompleteTextFieldExample
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit

extension UINavigationController {
    func setTransparentNavigationBar(withTint tintColor: UIColor) {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = .clear
        navigationBar.tintColor = tintColor
    }
}
