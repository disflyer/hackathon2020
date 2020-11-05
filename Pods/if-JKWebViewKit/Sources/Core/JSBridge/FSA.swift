//
//  FSA.swift
//  AppCore
//
//  Created by Xuyang Wang on 16/03/2018.
//  Copyright © 2018 若友网络科技有限公司. All rights reserved.
//  Inspired by https://github.com/aikoven/typescript-fsa
//

import ObjectMapper

public struct HybridError: Mappable {
    var code: Int = 0
    var description: String = ""

    public init?(map: Map) {

    }

    public init(code: Int, description: String) {
        self.code = code
        self.description = description
    }

    public static func generic() -> HybridError {
        return HybridError(code: -1, description: "")
    }

    public mutating func mapping(map: Map) {
        code <- map["code"]
        description <- map["description"]
    }
}

public class Callback: Mappable {
    public var actionType: String = ""
    public var context: [String: Any] = [:]

    public required init?(map: Map) {
    }

    public func mapping(map: Map) {
        actionType <- map["actionType"]
        context <- map["context"]
    }

    public init(actionType: String = "", context: [String: Any] = [:]) {
        self.actionType = actionType
        self.context = context
    }
}

public class Action: Mappable {
    public typealias Payload = [String: Any]

    public var type: String = ""
    public var payload: Payload = [:]
    public var meta: [String: String] = [:]
    public var error: Bool = false
    public var callback: Callback?

    public required init?(map: Map) {

    }

    public func mapping(map: Map) {
        type <- map["type"]
        meta <- map["meta"]
        error <- map["error"]
        callback <- map["callback"]
        payload <- map["payload"]
    }

    var isError: Bool {
        error
    }

    public init(type: String, payload: Payload, isError: Bool = false, meta: [String: String] = [:], callback: Callback? = nil) {
        self.type = type
        self.payload = payload
        self.error = isError
        self.meta = meta
        self.callback = callback
    }

    public init(type: String, error: HybridError = HybridError.generic(), meta: [String: String] = [:], callback: Callback? = nil) {
        self.type = type
        self.payload = error.toJSON()
        self.error = true
        self.meta = meta
        self.callback = callback
    }
}
