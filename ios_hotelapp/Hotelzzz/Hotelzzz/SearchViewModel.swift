//
//  SearchViewModel.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/6/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import WebKit

class SearchViewModel: NSObject, WKScriptMessageHandler {
    typealias APIReadyClosure = () -> Void
    private let onReady: APIReadyClosure
    
    typealias HotelSelectedClosure = (Hotel) -> Void
    private let selectedHotel: HotelSelectedClosure
    
    typealias SearchResultsClosure = (Int, PriceRange?) -> Void
    private let receivedResults: SearchResultsClosure
    
    init(onReady: @escaping APIReadyClosure,
         onHotelSelected: @escaping HotelSelectedClosure,
         onReceivedResults: @escaping SearchResultsClosure) {
        
        self.onReady = onReady
        self.selectedHotel = onHotelSelected
        self.receivedResults = onReceivedResults
    }
    
    func searchContentController() -> WKUserContentController {
        let contentController = WKUserContentController()
        
        contentController.add(self, name: "API_READY")
        contentController.add(self, name: "HOTEL_API_SEARCH_READY")
        contentController.add(self, name: "HOTEL_API_RESULTS_READY")
        contentController.add(self, name: "HOTEL_API_HOTEL_SELECTED")
        
        return contentController
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let response = message.body as? JSONDict else {
            assertionFailure("Unexpected response. Expected \(JSONDict.self) but got \(message.body.self)")
            return
        }
        
        switch message.name {
        case "API_READY":
            onReady()
            
        case "HOTEL_API_RESULTS_READY":
            let resultsKey = "results"
            guard let results = response[resultsKey] as? [JSONDict] else {
                assertionFailure("Unexpected type for key: \(resultsKey)")
                return
            }
            do {
                var hotels: [Hotel] = try results.map{ try $0.get($0) }
                hotels = hotels.sorted(by: { $0.price < $1.price })
                
                var range: PriceRange?
                if let min = hotels.first?.price, let max = hotels.last?.price {
                    range = (min, max)
                }
                receivedResults(hotels.count, range)
                
            } catch {
                assertionFailure("Failed to parse hotel results")
            }
            
        case "HOTEL_API_HOTEL_SELECTED":
            let resultKey = "result"
            guard let result = response[resultKey] as? JSONDict else {
                assertionFailure("Unexpected type for key: \(resultKey)")
                return
            }
            
            do {
                let hotelSelected: Hotel = try result.get(result)
                selectedHotel(hotelSelected)
            }
            catch {
                assertionFailure("Mapping Hotel JSON failed with error: \(error)")
            }
        case "HOTEL_API_SEARCH_READY":
            break
        default:
            assertionFailure("Unexpected name: \(message.name) payload: \(response)")
        }
    }
}
