//
//  TimeIntervalExtension.swift
//  Ruguo
//
//  Created by 杨学思 on 2019/2/14.
//  Copyright © 2019 若友网络科技有限公司. All rights reserved.
//

import Foundation

public extension TimeInterval {
    static func minutes(_ number: Int) -> TimeInterval {
        return TimeInterval(60 * number)
    }
    static func hours(_ number: Int) -> TimeInterval {
        return 60 * minutes(number)
    }
    static func days(_ number: Int) -> TimeInterval {
        return 24 * hours(number)
    }
}
