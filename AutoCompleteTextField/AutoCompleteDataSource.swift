//
//  AutoCompleteDataSource.swift
//  AutoCompleteTextField
//
//  Created by Jacob Mendelowitz on 11/3/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import Foundation

public class AutoCompleteDataSource {
    public var data: [AutoCompletable]
    public var autoCompleteTrie: AutoCompleteTrie?

    public init(data: [AutoCompletable]) {
        self.data = data
    }

    public func constructTrie(isCaseSensitive: Bool = false) {
        autoCompleteTrie = AutoCompleteTrie(dataSource: data, isCaseSensitive: false)
    }

    public func insert(autoCompletable: AutoCompletable) {
        data.append(autoCompletable)
        if let autoCompleteTrie = autoCompleteTrie {
            autoCompleteTrie.insert(autoCompletable: autoCompletable)
        }
    }
}
