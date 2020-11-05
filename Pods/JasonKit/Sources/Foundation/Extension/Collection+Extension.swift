//
//  CollectionExtension.swift
//  AppCore
//
//  Created by Kael Yang on 2019/6/17.
//  Copyright © 2019 若友网络科技有限公司. All rights reserved.
//

import Foundation

public extension Optional where Wrapped: Collection {
    var isBlank: Bool {
        switch self {
        case .some(let wrapped):
            return wrapped.isEmpty
        case .none:
            return true
        }
    }
    
    var treatingEmptyAsNil: Wrapped? {
        switch self {
        case .some(let wrapped):
            return wrapped.isEmpty ? nil : wrapped
        case .none:
            return nil
        }
    }
}


public extension Collection {
    /// Accessing element with subscript like `[self: 1]` to get optional result
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    /// Accessing element by getting optional result
    func safeGet(_ index: Index) -> Element? {
        return self[safe: index]
    }

    var treatingEmptyAsNil: Self? {
        return self.isEmpty ? nil : self
    }
}
