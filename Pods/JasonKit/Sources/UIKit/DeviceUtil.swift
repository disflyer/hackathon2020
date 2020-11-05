//
//  DeviceUtil.swift
//  Example
//
//  Created by Luminoid on 2020/7/10.
//  Copyright © 2020 iftech. All rights reserved.
//

import Foundation
import UIKit

public class DeviceUtil {
    public static let appDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Unknown"
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    public static let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    public static let bundleId = Bundle.main.bundleIdentifier ?? "Unknown"
    public static let idfv = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"

    #if targetEnvironment(simulator)
    public static let osVersion = ProcessInfo.processInfo.operatingSystemVersionString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
    #else
    public static let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
    #endif
}

