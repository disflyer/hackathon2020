//
//  JKAlHybridHandler.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/5/11.
//  Copyright © 2020 iftech. All rights reserved.
//

import UIKit
import RxSwift

open class JKHybridActionTypes {
    static let request_headers = "request_headers"
    static let close = "rg_close"
    static let toast = "rg_toast"
    static let open_webview = "rg_open_webview"
}

/// The center registry for all common actions
open class JKHybridHandler {
    public let disposeBag = DisposeBag()

    public init() {
        
    }

    open func register() {
        _ = JKHybridHandlerManager.shared.register(actionType: JKHybridActionTypes.request_headers, in: [.jike])
        _ = JKHybridHandlerManager.shared.register(actionType: JKHybridActionTypes.close, in: [.jike])
        _ = JKHybridHandlerManager.shared.register(actionType: JKHybridActionTypes.toast, in: [.jike])
        _ = JKHybridHandlerManager.shared.register(actionType: JKHybridActionTypes.open_webview, in: [.jike])
    }

    open func enableHybridHandlers() {
        JKHybridHandlerManager.shared
            .subject(in: .jike, for: JKHybridActionTypes.request_headers)?
            .asObservable()
            .subscribe(onNext: { [weak self] context in
                self?.requestHeaders(context: context)
            }).disposed(by: self.disposeBag)

        JKHybridHandlerManager.shared
            .subject(in: .jike, for: JKHybridActionTypes.close)?
            .asObservable()
            .subscribe(onNext: { [weak self] context in
                self?.close(context: context)
            }).disposed(by: self.disposeBag)

        JKHybridHandlerManager.shared
            .subject(in: .jike, for: JKHybridActionTypes.toast)?
            .asObservable()
            .subscribe(onNext: { [weak self] context in
                self?.toast(context: context)
            }).disposed(by: self.disposeBag)

        JKHybridHandlerManager.shared
            .subject(in: .jike, for: JKHybridActionTypes.open_webview)?
            .asObservable()
            .subscribe(onNext: { [weak self] context in
                self?.openWebView(context: context)
            }).disposed(by: self.disposeBag)
    }

    open func requestHeaders(context: JKHybridHandlerManager.ActionContext) {
        let (action, controller, _, domain) = context
        if let actionType = action.callback?.actionType {
            let payload: [String: String] = ["hybrid-handler": "jk-hybrid-handler"]
            domain.dispatch(action: Action(type: actionType,
                                           payload: payload,
                                           meta: action.meta,
                                           callback: Callback(context: action.callback?.context ?? [:])),
                            toWebViewController: controller)
        }
    }

    open func close(context: JKHybridHandlerManager.ActionContext) {
        let (_, controller, _, _) = context
        if controller.presentingViewController != nil {
            controller.dismiss(animated: true, completion: nil)
        } else {
            controller.navigationController?.popViewController(animated: true)
        }
    }

    open func toast(context: JKHybridHandlerManager.ActionContext) {
        let (action, controller, _, _) = context
        guard action.isError == false else {
            return
        }
        let alert = UIAlertController(title: controller.webView.url?.host ?? "",
                                      message: action.payload["message"] as? String,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }

    open func openWebView(context: JKHybridHandlerManager.ActionContext) {
        let (action, controller, _, _) = context
        guard let urlStr = action.payload["url"] as? String,
            let url = URL(string: urlStr) else {
                return
        }
        let newWebViewCon = JKWebViewController(url: url)
        if let nav = controller.navigationController {
            nav.pushViewController(newWebViewCon, animated: true)
        } else {
            controller.present(newWebViewCon, animated: true, completion: nil)
        }
    }
}
