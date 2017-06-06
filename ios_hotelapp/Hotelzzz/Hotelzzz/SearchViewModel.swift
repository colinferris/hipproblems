//
//  SearchViewModel.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/6/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation

struct SearchViewModel {
    typealias SortHandler = (HotelOrder) -> Void
    private let sortBy: SortHandler
    
    typealias EventHandler = (APIEvent) -> Void
    private let searchEvent: EventHandler
    
    init(sortBy: @escaping SortHandler, searchEvent: @escaping EventHandler) {
        self.sortBy = sortBy
        self.searchEvent = searchEvent
    }
    
    func sort(by closure: HotelOrder) {
        sortBy(closure)
    }
    
    func on(_ name: String, payload: JSONDict) {
        switch name {
        case "API_READY":
            searchEvent(.ready)
        case "HOTEL_API_SEARCH_READY":
            searchEvent(.searchReady)
        case "HOTEL_API_RESULTS_READY":
            guard let results = payload["results"] as? [JSONDict], results.count > 0 else {
                return
            }
            searchEvent(.resultsReady(results.count))
        case "HOTEL_API_HOTEL_SELECTED":
            guard let result = payload["result"] as? JSONDict else { return }
            let hotel: Hotel
            do {
                hotel = try result.get(result)
            }
            catch {
                //Add better error handling
                fatalError("Unable to parse selected hotel")
            }
            searchEvent(.selectedHotel(hotel))
        default:
            fatalError("Unhandled message: \(name)")
        }
    }
}
