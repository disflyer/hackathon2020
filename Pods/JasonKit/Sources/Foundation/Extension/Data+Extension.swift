//
//  DataExtension.swift
//  Ruguo
//
//  Created by 陆俊杰 on 2017/9/12.
//  Copyright © 2017年 若友网络科技有限公司. All rights reserved.
//

import Foundation

public extension Data {
    /// Get size in Kb
    var sizeInKb: Int {
        return self.count / 1000
    }

    /// Get size in MB
    var sizeInMb: Double {
        return ceil((Double(self.count) / (1000 * 1000)) * 10000) / 10000
    }

    /// Get size in Kib
    var sizeInKib: Int {
        return self.count / 1024
    }

    /// Get size in Mib
    var sizeInMib: Double {
        return ceil((Double(self.count) / (1024 * 1024)) * 10000) / 10000
    }
}
