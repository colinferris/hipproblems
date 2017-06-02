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
}

func jsonStringify(_ obj: [AnyHashable: Any]) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: obj, options: [])
    guard let json = String(data: data, encoding: .utf8) else {
        throw JSONSerializationError.stringifyFailure
    }
    return json
}
