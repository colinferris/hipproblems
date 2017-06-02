//
//  Hotel.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/2/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

struct Hotel: Decodable {
    let uuid: Double
    let price: Double
    let name: String
    let address: String
    let imageUrl: String
    
    init(json: JSONDict) throws {
        let hotel: JSONDict = try json.get(json, key: "hotel")
        
        uuid = try json.get(hotel, key: "id")
        price = try json.get(json, key: "price")
        name = try json.get(hotel, key: "name")
        address = try json.get(hotel, key: "address")
        imageUrl = try json.get(hotel, key: "imageURL")
    }
}
