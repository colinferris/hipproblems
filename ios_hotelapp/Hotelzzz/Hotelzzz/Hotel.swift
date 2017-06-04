//
//  Hotel.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/2/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

/// Defines the Hotel 
/// Can contain information gotten from a hotel search
struct Hotel: Decodable {
    let uuid: Double
    let price: Double
    let name: String
    let address: String
    let imageUrl: String
    
    init(uuid: Double, price: Double, name: String, address: String, imageUrl: String) {
        self.uuid = uuid
        self.price = price
        self.name = name
        self.address = address
        self.imageUrl = imageUrl
    }
    
    init(json: JSONDict) throws {
        let hotel: JSONDict = try json.get(json, key: "hotel")
        
        uuid = try json.get(hotel, key: "id")
        price = try json.get(json, key: "price")
        name = try json.get(hotel, key: "name")
        address = try json.get(hotel, key: "address")
        imageUrl = try json.get(hotel, key: "imageURL")
    }
}

extension Hotel: Equatable {
    static func ==(lhs: Hotel, rhs: Hotel) -> Bool {
        return lhs.uuid == rhs.uuid &&
        lhs.price == rhs.price &&
        lhs.name == rhs.name &&
        lhs.address == rhs.address &&
        lhs.imageUrl == rhs.imageUrl
    }
}
