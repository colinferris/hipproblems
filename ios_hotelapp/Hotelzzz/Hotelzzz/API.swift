//
//  APIEventController.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/3/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

enum APIEvent {
    /// API_READY
    case ready
    /// HOTEL_API_SEARCH_READY
    case searchReady
    /// HOTEL_API_RESULTS_READY
    case resultsReady(Int)
    /// HOTEL_API_HOTEL_SELECTED
    case selectedHotel(Hotel)
}

enum HotelOrder {
    /// name
    case name
    /// priceAscend
    case priceAscending
    /// priceDescend
    case priceDescending
}
