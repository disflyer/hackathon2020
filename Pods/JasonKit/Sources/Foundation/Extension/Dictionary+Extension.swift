//
//  DictionaryExtension.swift
//  AppCore
//
//  Created by 陆俊杰 on 2017/11/10.
//  Copyright © 2017年 若友网络科技有限公司. All rights reserved.
//

import Foundation

public extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }

    func merging(dict: [Key: Value]) -> [Key: Value] {
        var newDict: [Key: Value] = self
        newDict.merge(dict: dict)
        return newDict
    }
}
