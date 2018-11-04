//
//  CALayer+Extensions.swift
//  AutoCompleteTextFieldExample
//
//  Created by JJacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit

extension CALayer {
    func addBorder(to edges: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in edges {
            let border = CALayer()
            switch edge {
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: width)
            case .bottom:
                border.frame = CGRect(x: 0, y: frame.height - width, width: frame.width, height: width)
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.width - width, y: 0, width: width, height: frame.height)
            default:
                continue
            }
            border.backgroundColor = color.cgColor
            addSublayer(border)
        }
    }
}
