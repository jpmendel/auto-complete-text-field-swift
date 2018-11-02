//
//  AutoCompletable.swift
//  AutoCompleteTextField
//
//  Created by Jacob Mendelowitz on 10/19/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit

public protocol AutoCompletable {
    var autoCompleteString: String { get }
}

extension String: AutoCompletable {
    public var autoCompleteString: String {
        return self
    }
}
