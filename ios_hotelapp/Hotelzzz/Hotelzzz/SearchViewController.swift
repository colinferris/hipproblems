//
//  SearchViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class SearchViewController: UIViewController, WKScriptMessageHandler {
    @IBOutlet weak var container: UIView!
    
    private let endpointURL = URL(string: "http://hipmunk.github.io/hipproblems/ios_hotelapp/")!
    private var currentSearch: Search!
    private var selectedHotel: Hotel?
   
    lazy var viewModel: SearchViewModel = {
        return SearchViewModel(sortBy: self.sort,
                               searchEvent: self.handleEvent)
    }()
    
    lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        contentController.add(self, name: "API_READY")
        contentController.add(self, name: "HOTEL_API_SEARCH_READY")
        contentController.add(self, name: "HOTEL_API_RESULTS_READY")
        contentController.add(self, name: "HOTEL_API_HOTEL_SELECTED")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.frame = container.bounds
        container.addSubview(webView)
    }
    
    func search(location: String, dateStart: Date, dateEnd: Date) {
        currentSearch = Search(location: location, dateStart: dateStart, dateEnd: dateEnd)
        webView.load(URLRequest(url: endpointURL))
    }
    
    @IBAction func sortHotels(_ sender: UIBarButtonItem) {
        let sortController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        let sortByName = UIAlertAction(title: "Name", style: .default) { (action) in
            self.viewModel.sort(by: .name)
        }
        let sortPriceAscending = UIAlertAction(title: "Price Ascending",
                                               style: .default) { (action) in
            self.viewModel.sort(by: .priceAscending)
        }
        let sortPriceDescending = UIAlertAction(title: "Price Descending",
                                                style: .default) { (action) in
            self.viewModel.sort(by: .priceDescending)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sortController.addAction(sortByName)
        sortController.addAction(sortPriceAscending)
        sortController.addAction(sortPriceDescending)
        sortController.addAction(cancelAction)
        present(sortController, animated: true, completion: nil)
    }
    
    func sort(by order: HotelOrder) {
        let method: String
        switch order {
        case .name:
            method = "name"
        case .priceAscending:
            method = "priceAscend"
        case .priceDescending:
            method = "priceDescend"
        }
        let javascript = "window.JSAPI.setHotelSort(\"\(method)\")"
        self.webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let response = message.body as? JSONDict else {
            fatalError("Unexpected response")
        }
        viewModel.on(message.name, payload: response)
    }
    
    func handleEvent(_ event: APIEvent) {
        switch event {
        case .ready:
            let json = try! currentSearch.toJSON().jsonStringify()
            let javascript = "window.JSAPI.runHotelSearch(\(json))"
            self.webView.evaluateJavaScript(javascript, completionHandler: nil)
        case .selectedHotel(let hotel):
            self.selectedHotel = hotel
            self.performSegue(withIdentifier: "hotel_details", sender: nil)
        case .resultsReady(let numResults):
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.title = "\(numResults) Results"
                })
            }
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hotel_details", let destination = segue.destination as? HotelViewController {
            destination.hotel = selectedHotel
        }
    }
}

extension SearchViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alertController = UIAlertController(title: NSLocalizedString("Could not load page", comment: ""),
                                                message: NSLocalizedString("Looks like the server isn't running.", comment: ""),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Bummer", comment: ""), style: .default))
        
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
}
