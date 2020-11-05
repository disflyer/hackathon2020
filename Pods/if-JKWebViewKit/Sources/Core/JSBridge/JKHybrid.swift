//
//  JKHybrid.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/4/22.
//  Copyright © 2020 iftech. All rights reserved.
//

import WebKit
import ObjectMapper
import RxSwift

public protocol JKHybridCallbackHandlerProtocol {
}

public class JKHybrid {
    public static let shared = JKHybrid()

    func installJikeHybridMessageHandler(_ scriptMessageHandler: WKScriptMessageHandler, toWebView webView: WKWebView) {
        self.installHybrid(domain: .jike, messageHandler: scriptMessageHandler, toWebView: webView)
    }

    fileprivate func installHybrid(domain: JKHybridDomain, messageHandler: WKScriptMessageHandler, toWebView webView: WKWebView) {
        webView.configuration.userContentController.add(WKScriptMessageHandlerLeakAvoider(delegate: messageHandler),
                                                        name: domain.messageHandlerName)

        let jikeScript = WKUserScript(source: domain.nativeDispatchJavascriptForInjection, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(jikeScript)
    }

    func uninstallHybridMessageHandler(toWebView webView: WKWebView) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: JKHybridDomain.jike.messageHandlerName)
        webView.configuration.userContentController.removeAllUserScripts()
    }

    public func handleHybridWebAction(actionJson: String,
                                      fromWebViewController webViewController: JKWebViewController,
                                      withHandlerName handlerName: String,
                                      andCallbackDelegate callbackDelegate: JKHybridCallbackHandlerProtocol) {

        guard let action = Mapper<Action>().map(JSONString: actionJson) else { return }
        let domain = JKHybridDomain.valueFrom(messageHandlerName: handlerName)
        domain.handle(webAction: action, fromWebViewController: webViewController, andCallbackDelegate: callbackDelegate)
    }
}
