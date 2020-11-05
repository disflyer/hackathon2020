//
//  LeakAvoider.swift
//  Ruguo
//
//  Created by Xuyang Wang on 2018/7/26.
//  Copyright © 2018 若友网络科技有限公司. All rights reserved.
//

import WebKit

// Rationale: MessageHandler retains self, and hard to decide when to remove it,
// Introduce this LeakAvoider to solve the leading problem. Refer to: https://stackoverflow.com/a/26383032
class WKScriptMessageHandlerLeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
