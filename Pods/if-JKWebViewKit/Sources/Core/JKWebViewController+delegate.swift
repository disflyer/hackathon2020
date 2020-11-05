//
//  JKWebViewController+delegate.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/4/22.
//  Copyright © 2020 iftech. All rights reserved.
//

import Foundation
import WebKit

extension JKWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    #if DEBUG
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default, handler: { _ in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
            let textfield: UITextField? = alert.textFields?[0]
            completionHandler(textfield?.text)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    #endif
}

extension JKWebViewController: WKNavigationDelegate {

    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Config.loggerProxy?.log("didStartProvisionalNavigation url \(webView.url == nil ? "UNKNOWN!" : webView.url!.absoluteString)")

        JKHybrid.shared.uninstallHybridMessageHandler(toWebView: self.webView)
        if shouldInjectHybridNativeDispatch() {
            JKHybrid.shared.installJikeHybridMessageHandler(self, toWebView: self.webView)
        }

#if DEBUG
        webView.evaluateJavaScript("console.log('webView(_:didStartProvisionalNavigation:)')", completionHandler: nil)
#endif
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Config.loggerProxy?.log("didCommit url \(webView.url == nil ? "UNKNOWN!" : webView.url!.absoluteString)")

        //self.bottomToolBar?.navBackButton.isEnabled = webView.canGoBack

#if DEBUG
        webView.evaluateJavaScript("console.log('webView(_:didCommit:)')", completionHandler: nil)
#endif
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain, nsError.code != -999 else {
            return
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
#if DEBUG
        webView.evaluateJavaScript("console.log('webView(_:didFinish:)')", completionHandler: nil)
#endif
        self.providerHost = webView.url?.host ?? ""
    }
}
