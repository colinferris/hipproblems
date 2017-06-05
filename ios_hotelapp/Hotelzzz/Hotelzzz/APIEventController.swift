//
//  APIEventController.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/3/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import WebKit

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

class APIEventController: NSObject, WKScriptMessageHandler {
    let eventHandler: (APIEvent) -> Void
    let userContentController: WKUserContentController
    
    init(eventHandler: @escaping (APIEvent) -> Void) {
        self.userContentController = WKUserContentController()
        self.eventHandler = eventHandler
        
        super.init()
        userContentController.add(self, name: "API_READY")
        userContentController.add(self, name: "HOTEL_API_SEARCH_READY")
        userContentController.add(self, name: "HOTEL_API_RESULTS_READY")
        userContentController.add(self, name: "HOTEL_API_HOTEL_SELECTED")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "API_READY":
            eventHandler(.ready)
        case "HOTEL_API_SEARCH_READY":
            eventHandler(.searchReady)
        case "HOTEL_API_RESULTS_READY":
            guard let body = message.body as? JSONDict,
                let results = body["results"] as? [JSONDict], results.count > 0 else {
                    return
            }
            eventHandler(.resultsReady(results.count))
        case "HOTEL_API_HOTEL_SELECTED":
            guard let body = message.body as? JSONDict, let result = body["result"] as? JSONDict else { return }
            let hotel: Hotel
            do {
                hotel = try result.get(result)
            }
            catch {
                //Add better error handling
                fatalError("Unable to parse selected hotel")
            }
            eventHandler(.selectedHotel(hotel))
        default:
            fatalError("Unhandled message: \(message.name)")
        }
    }
}
