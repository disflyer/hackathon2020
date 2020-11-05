//
//  ArrayExtension.swift
//  Ruguo
//
//  Created by 杨学思 on 2018/11/15.
//  Copyright © 2018 若友网络科技有限公司. All rights reserved.
//

import Foundation

public extension Array {
    /// A shortcut to get second element.
    var second: Element? { return self[safe: 1] }
    /// A shortcut to get third element.
    var third: Element? { return self[safe: 2] }
    /// A shortcut to get fourth element.
    var fourth: Element? { return self[safe: 3] }
    
    /// Split array to subsequences by length of each subsequence
    func splitBy(maxSubSequenceLength: Int) -> [[Element]] {
        guard !isEmpty else {
            return []
        }
        // divide round up
        // 9 / 2 result will be 5
        let arrCount = Int(ceil(Double(count) / Double(maxSubSequenceLength)))
        var result: [[Element]] = []
        for i in 0 ..< arrCount {
            let sliceStartIndex = i * maxSubSequenceLength
            let sliceEndIndex = Swift.min(sliceStartIndex + maxSubSequenceLength, endIndex)
            result.append(Array(self[sliceStartIndex ..< sliceEndIndex]))
        }
        return result
    }
}
