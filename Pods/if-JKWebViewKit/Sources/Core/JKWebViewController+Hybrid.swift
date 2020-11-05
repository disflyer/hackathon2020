//
//  JKWebViewController+Hybrid.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/4/22.
//  Copyright © 2020 iftech. All rights reserved.
//

import UIKit
import WebKit
import JasonKit

extension JKWebViewController: WKScriptMessageHandler {
    @objc public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let actionJson = message.body as? String else { return }

        JKHybrid.shared.handleHybridWebAction(actionJson: actionJson,
                                              fromWebViewController: self,
                                              withHandlerName: message.name,
                                              andCallbackDelegate: self)
    }
}
