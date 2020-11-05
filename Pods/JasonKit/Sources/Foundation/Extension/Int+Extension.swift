//
//  IntExtension.swift
//  Ruguo
//
//  Created by Jason Yu on 12/8/15.
//  Copyright © 2015 若友网络科技有限公司. All rights reserved.
//

import Foundation

public extension Int {
    /// Invokes the block n times, returning an array of the results of each invocation. The block is invoked with index.
    func times<T>(_ block: (Int) -> T) -> [T] {
        var result: [T] = []
        for index in 0..<self {
            let t = block(index)
            result.append(t)
        }
        return result
    }
}
