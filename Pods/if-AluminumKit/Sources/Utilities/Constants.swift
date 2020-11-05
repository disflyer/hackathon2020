//
//  Constants.swift
//  AluminumKit-iOS
//
//  Created by Xuyang Wang on 2019/11/12.
//  Copyright © 2019 iftech.io. All rights reserved.
//

import UIKit

enum ScreenFamily {
    // checkout this for variations https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
    case iPhone4         // 2G, 3G, 3GS, 4, 4S
    case iPhone5         // 5, 5S, 5C, SE
    case iPhone8         // 6, 6S, 7, 8
    case iPhone8Plus     // 6+, 6S+, 7+, 8+
    case iPhone11Pro     // 11 Pro, X, Xs
    case iPhone11ProMax  // 11, XR, 11 Pro Max, Xs Max
    case iPhone12mini    // 12 mini
    case iPhone12Pro     // 12, 12 Pro
    case iPhone12ProMax  // 12 Pro Max
    case unknown

    static func getCurrentScreenFamily() -> ScreenFamily {
        let deviceModel = UIDevice.current.model

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        // Simulators
        if identifier == "i386" || identifier == "x86_64" {
            if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                if let simModel = deviceModelMap[String.init(validatingUTF8: simModelCode)!] {
                    return simModel
                }
            }
        }

        return deviceModelMap[identifier] ?? .unknown
    }

    var hasNotch: Bool {
        switch self {
        case .iPhone4, .iPhone5, .iPhone8, .iPhone8Plus:
            return false
        case .iPhone11Pro, .iPhone11ProMax, .iPhone12mini, .iPhone12Pro, .iPhone12ProMax:
            return true
        case .unknown:
            return false
        }
    }

    var topDangerMargin: CGFloat {
        switch self {
        case .iPhone4, .iPhone5, .iPhone8, .iPhone8Plus:
            return 20
        case .iPhone11Pro, .iPhone11ProMax:
            return 44
        case .iPhone12mini:
            return 50
        case .iPhone12Pro, .iPhone12ProMax:
            return 47
        case .unknown:
            return 0
        }
    }

    var bottomDangerMargin: CGFloat {
        switch self {
        case .iPhone4, .iPhone5, .iPhone8, .iPhone8Plus:
            return 0
        case .iPhone11Pro, .iPhone11ProMax, .iPhone12mini, .iPhone12Pro, .iPhone12ProMax:
            return 34
        case .unknown:
            return 0
        }
    }
}

public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height
public let hairlineWidth = 1 / UIScreen.main.scale

fileprivate var currentScreenFamily = {
    ScreenFamily.getCurrentScreenFamily()
}()

public var haveNotch: Bool = {
    currentScreenFamily.hasNotch
}()
public let isSmallScreen: Bool = ScreenWidth <= 320 // smaller than iPhone 6 (375)

public var topDangerMargin: CGFloat = {
    currentScreenFamily.topDangerMargin
}()

public var bottomDangerMargin: CGFloat = {
    currentScreenFamily.bottomDangerMargin
}()

public var statusBarHeight: CGFloat = { topDangerMargin }()
public var navBarHeight: CGFloat = { 44 + statusBarHeight }()
public var tabBarButtonHeight: CGFloat = { 49 }()
public var tabBarHeight: CGFloat = { bottomDangerMargin + tabBarButtonHeight }()


// MARK: - fileprivate constants

fileprivate let deviceModelMap: [String: ScreenFamily] = [
    "iPod1,1":    .iPhone4,          // "iPod Touch" (Original)
    "iPod2,1":    .iPhone4,          // "iPod Touch" (Second Generation)
    "iPod3,1":    .iPhone4,          // "iPod Touch" (Third Generation)
    "iPod4,1":    .iPhone4,          // "iPod Touch" (Fourth Generation)
    "iPod5,1":    .iPhone5,          // "iPod Touch" (Fifth Generation)
    "iPod7,1":    .iPhone5,          // "iPod Touch" (Sixth Generation)
    "iPod9,1":    .iPhone5,          // "iPod Touch" (Seventh Generation)
    "iPhone1,1":  .iPhone4,          // "iPhone" (Original)
    "iPhone1,2":  .iPhone4,          // "iPhone 3G" (3G)
    "iPhone2,1":  .iPhone4,          // "iPhone 3GS" (3GS)
    "iPhone3,1":  .iPhone4,          // "iPhone 4" (GSM)
    "iPhone3,2":  .iPhone4,          // "iPhone 4" iPhone 4
    "iPhone3,3":  .iPhone4,          // "iPhone 4" (CDMA/Verizon/Sprint)
    "iPhone4,1":  .iPhone4,          // "iPhone 4S"
    "iPhone5,1":  .iPhone5,          // "iPhone 5" (model A1428, AT&T/Canada)
    "iPhone5,2":  .iPhone5,          // "iPhone 5" (model A1429, everything else)
    "iPhone5,3":  .iPhone5,          // "iPhone 5c" (model A1456, A1532 | GSM)
    "iPhone5,4":  .iPhone5,          // "iPhone 5c" (model A1507, A1516, A1526 (China), A1529 | Global)
    "iPhone6,1":  .iPhone5,          // "iPhone 5s" (model A1433, A1533 | GSM)
    "iPhone6,2":  .iPhone5,          // "iPhone 5s" (model A1457, A1518, A1528 (China), A1530 | Global)
    "iPhone7,1":  .iPhone8Plus,      // "iPhone 6 Plus"
    "iPhone7,2":  .iPhone8,          // "iPhone 6"
    "iPhone8,1":  .iPhone8,          // "iPhone 6s"
    "iPhone8,2":  .iPhone8Plus,      // "iPhone 6s Plus"
    "iPhone8,4":  .iPhone5,          // "iPhone SE"
    "iPhone9,1":  .iPhone8,          // "iPhone 7" (model A1660 | CDMA)
    "iPhone9,3":  .iPhone8,          // "iPhone 7" (model A1778 | Global)
    "iPhone9,2":  .iPhone8Plus,      // "iPhone 7 Plus" (model A1661 | CDMA)
    "iPhone9,4":  .iPhone8Plus,      // "iPhone 7 Plus" (model A1784 | Global)
    "iPhone10,3": .iPhone11Pro,      // "iPhone X" (model A1865, A1902)
    "iPhone10,6": .iPhone11Pro,      // "iPhone X" (model A1901)
    "iPhone10,1": .iPhone8,          // "iPhone 8" (model A1863, A1906, A1907)
    "iPhone10,4": .iPhone8,          // "iPhone 8" (model A1905)
    "iPhone10,2": .iPhone8Plus,      // "iPhone 8 Plus" (model A1864, A1898, A1899)
    "iPhone10,5": .iPhone8Plus,      // "iPhone 8 Plus" (model A1897)
    "iPhone11,2": .iPhone11Pro,      // "iPhone XS" (model A2097, A2098)
    "iPhone11,4": .iPhone11ProMax,   // "iPhone XS Max" (model A1921, A2103)
    "iPhone11,6": .iPhone11ProMax,   // "iPhone XS Max" (model A2104)
    "iPhone11,8": .iPhone11ProMax,   // "iPhone XR" (model A1882, A1719, A2105)
    "iPhone12,1": .iPhone11ProMax,   // "iPhone 11"
    "iPhone12,3": .iPhone11Pro,      // "iPhone 11 Pro"
    "iPhone12,5": .iPhone11ProMax,   // "iPhone 11 Pro Max"
    "iPhone12,8": .iPhone8,          // "iPhone SE" (2nd Generation iPhone SE)
    "iPhone13,1": .iPhone12mini,     // "iPhone 12 mini"
    "iPhone13,2": .iPhone12Pro,      // "iPhone 12"
    "iPhone13,3": .iPhone12Pro,      // "iPhone 12 Pro"
    "iPhone13,4": .iPhone12ProMax,   // "iPhone 12 Pro Max"
]
