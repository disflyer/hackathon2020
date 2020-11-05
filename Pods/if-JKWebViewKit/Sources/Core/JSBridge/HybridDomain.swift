//
//  JKHybridDomain.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/4/22.
//  Copyright © 2020 iftech. All rights reserved.
//

import ObjectMapper

public struct JKHybridDomain {
    public static let jike = JKHybridDomain(messageHandlerName: "JikeHybridMessageHandlerName",
                                            javascriptObjectName: "JikeHybrid")

    var messageHandlerName: String
    var javascriptObjectName: String

    static func valueFrom(messageHandlerName: String) -> JKHybridDomain {
        if messageHandlerName == JKHybridDomain.jike.messageHandlerName {
            return JKHybridDomain.jike
        }
        return JKHybridDomain.jike // fallback to jike
    }

    var nativeDispatchJavascriptForInjection: String {
        return "window.\(javascriptObjectName)=window.\(javascriptObjectName)||{};window.\(javascriptObjectName).nativeDispatch=function(actionJson){window.webkit.messageHandlers.\(messageHandlerName).postMessage(actionJson);console.log('\(messageHandlerName) nativeDispatch: ', actionJson);};var jkhEvent = new Event('JikeHybridBridgeReady');document.dispatchEvent(jkhEvent);console.log('\(messageHandlerName) nativeDispatch injected');"
    }

    func webDispatchJavascriptForDispatching(action: String) -> String {
        return "if(window.\(javascriptObjectName)&&window.\(javascriptObjectName).webDispatch){window.\(javascriptObjectName).webDispatch(\(action));};"
    }

    public func dispatch(action: Action, toWebViewController webViewController: JKWebViewController) {
        guard let actionJson = Mapper().toJSONString(action) else { return }
        let jsCode = webDispatchJavascriptForDispatching(action: actionJson)
        webViewController.webView.evaluateJavaScript(jsCode) { (result: Any?, error: Error?) in
            if let error = error { return print(error) }
            print(result ?? "no result")
        }
    }

    func handle(webAction action: Action,
                fromWebViewController webViewController: JKWebViewController,
                andCallbackDelegate callbackDelegate: JKHybridCallbackHandlerProtocol) {

        if let subject = JKHybridHandlerManager.shared.subject(in: self, for: action.type) {
            subject.onNext((action, webViewController, callbackDelegate, self))
        }
    }
}

extension JKHybridDomain: Hashable {

}
