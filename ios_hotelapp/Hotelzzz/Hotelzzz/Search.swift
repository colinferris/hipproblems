//
//  Search.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/1/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

struct Search {
    let location: String
    let dateStart: Date
    let dateEnd: Date
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-mm-dd"
        return formatter
    }()
    
    func getJSON() throws -> String {
        return try jsonStringify([
            "location": location,
            "dateStart": Search.dateFormatter.string(from: dateStart),
            "dateEnd": Search.dateFormatter.string(from: dateEnd)
            ])
    }
}
