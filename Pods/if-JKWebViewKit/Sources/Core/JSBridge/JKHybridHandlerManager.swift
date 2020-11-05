//
//  JKHybridHandlerManager.swift
//  JKWebViewKit-iOS
//
//  Created by Xuyang Wang on 2020/4/22.
//  Copyright © 2020 iftech. All rights reserved.
//

import RxSwift

public class JKHybridHandlerManager {

    private init() { }
    public typealias ActionContext = (Action, JKWebViewController, JKHybridCallbackHandlerProtocol, JKHybridDomain)

    private var registeredActions: [JKHybridDomain: [String: PublishSubject<ActionContext>]] = [:]

    public static let shared: JKHybridHandlerManager = {
        return JKHybridHandlerManager()
    }()

    public func register(actionType: String, in domains: [JKHybridDomain]) -> PublishSubject<ActionContext> {
        let subject = PublishSubject<ActionContext>()
        for domain in domains {
            if var dict = registeredActions[domain] {
                if dict[actionType] == nil {
                    dict[actionType] = subject
                }
                registeredActions[domain] = dict
            } else {
                registeredActions[domain] = [actionType: subject]
            }
        }
        return subject
    }

    public func subject(in domain: JKHybridDomain, for type: String) -> PublishSubject<ActionContext>? {
        return registeredActions[domain]?[type]
    }

}
