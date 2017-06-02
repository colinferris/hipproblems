//
//  JSON.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/1/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

enum JSONSerializationError: Error {
    case stringifyFailure
    case missingAttribute(key: String)
    case invalidType(key: String, expected: Any.Type, actual: Any)
}

func jsonStringify(_ obj: [AnyHashable: Any]) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: obj, options: [])
    guard let json = String(data: data, encoding: .utf8) else {
        throw JSONSerializationError.stringifyFailure
    }
    return json
}

typealias JSONDict = [String: Any]

protocol Decodable {
    init(json: JSONDict) throws
}

extension Dictionary where Key == String, Value == Any {
    func get<T>(_ json: JSONDict, key: String) throws -> T {
        guard let value = json[key] else {
            throw JSONSerializationError.missingAttribute(key: key)
        }
        guard let typedItem = value as? T else {
            throw JSONSerializationError.invalidType(key: key,
                                                     expected: T.self,
                                                     actual: value)
        }
        return typedItem
    }
    
    func get<T: Decodable>(_ json: JSONDict, key: String) throws -> T {
        let value: JSONDict = try get(json, key: key)
        return try get(value)
    }
    
    func get<T: Decodable>(_ json: JSONDict, key: String) throws -> [T] {
        let values: [JSONDict] = try get(json, key: key)
        return values.flatMap { try? get($0) }
    }
    
    func get<T: Decodable>(_ json: JSONDict) throws -> T {
        return try T.init(json: json)
    }
}

