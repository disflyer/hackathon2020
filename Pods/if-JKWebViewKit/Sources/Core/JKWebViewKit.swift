//
//  JKWebViewKit.swift
//  JKWebViewKit
//
//  Created by Arthur Wang on Apr 17, 2020.
//  Copyright © 2020 iftech. All rights reserved.
//

// Include Foundation
@_exported import Foundation

public protocol JKWebViewLogProxy: class {
    static func log(_ message: @autoclosure @escaping () -> String)
}
