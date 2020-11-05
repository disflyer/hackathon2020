//
//  JKAlHybridHandler.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/5/12.
//  Copyright © 2020 iftech. All rights reserved.
//

import RxSwift
import AluminumKit

open class JKAlHybridHandler: JKHybridHandler {
    open override func requestHeaders(context: JKHybridHandlerManager.ActionContext) {
        let (action, controller, _, domain) = context
        if let actionType = action.callback?.actionType {
            let payload: [String: String] = ["hybrid-handler": "jk-al-hybrid-handler"]
            domain.dispatch(action: Action(type: actionType,
                                           payload: payload,
                                           meta: action.meta,
                                           callback: Callback(context: action.callback?.context ?? [:])),
                            toWebViewController: controller)
        }
    }

    open override func close(context: JKHybridHandlerManager.ActionContext) {
        let (_, controller, _, _) = context
        if controller.presentingViewController != nil {
            controller.dismiss(animated: true, completion: nil)
        } else if let jkNav = (controller as? UIViewController & JKNavigationBarContainer)?.jkNavigationController {
            _ = jkNav.popViewController(animated: true)
        } else {
            controller.navigationController?.popViewController(animated: true)
        }
    }

    open override func toast(context: JKHybridHandlerManager.ActionContext) {
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

    open override func openWebView(context: JKHybridHandlerManager.ActionContext) {
        let (action, controller, _, _) = context
        guard let urlStr = action.payload["url"] as? String,
            let url = URL(string: urlStr) else {
                return
        }
        let newWebViewCon = JKAlWebViewController(url: url)
        if let jkNav = (controller as? UIViewController & JKNavigationBarContainer)?.jkNavigationController {
            jkNav.pushViewController(newWebViewCon, animated: true)
        } else if let nav = controller.navigationController {
            nav.pushViewController(newWebViewCon, animated: true)
        } else {
            controller.present(newWebViewCon, animated: true, completion: nil)
        }
    }
}
