//
//  SearchViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import WebKit
import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var container: UIView!
    
    private static let endpointURL = URL(string: "http://hipmunk.github.io/hipproblems/ios_hotelapp/")!
    private var currentSearch: Search?
    private var selectedHotel: Hotel?
    private var priceRange: PriceRange?
    
    lazy var viewModel: SearchViewModel = {
        return SearchViewModel(onReady: self.search,
                               onHotelSelected: self.selected,
                               onReceivedResults: self.receivedResults)
    }()
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController = self.viewModel.searchContentController()
        
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
        webView.load(URLRequest(url: SearchViewController.endpointURL))
    }
    
    /// Creates and presents action sheet for sorting hotel results
    @IBAction func sortHotels(_ sender: UIBarButtonItem) {
        let sortController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        let sortByName = UIAlertAction(title: "Name", style: .default) { (action) in
            self.sort(by: .name)
        }
        let sortPriceAscending = UIAlertAction(title: "Price Ascending", style: .default) { (action) in
            self.sort(by: .priceAscending)
        }
        let sortPriceDescending = UIAlertAction(title: "Price Descending", style: .default) { (action) in
            self.sort(by: .priceDescending)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sortController.addAction(sortByName)
        sortController.addAction(sortPriceAscending)
        sortController.addAction(sortPriceDescending)
        sortController.addAction(cancelAction)
        present(sortController, animated: true, completion: nil)
    }
    
    private func sort(by order: HotelOrder) {
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
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    func filter(by price: (min: Double, max: Double)) {
        self.priceRange = price
        
        let params = "{priceMin: \(price.min), priceMax: \(price.max)}"
        let javascript = "window.JSAPI.setHotelFilters(\(params))"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    func search() {
        guard let search = currentSearch else {
            return
        }
        
        do {
            let searchJSON = try search.toJSON().jsonStringify()
            let javascript = "window.JSAPI.runHotelSearch(\(searchJSON))"
            webView.evaluateJavaScript(javascript, completionHandler: nil)
        }
        catch {
            fatalError("Unable to execute search. Search failed with error: \(error)")
        }
    }
    
    /// Updates the current selected hotel and performs segue to detail view
    func selected(hotel: Hotel) {
        selectedHotel = hotel
        performSegueWithIdentifier(segueIdentifier: .hotelDetails, sender: nil)
    }
    
    /// Updates the navigation bar title with the number of search results.
    func receivedResults(numResults: Int, priceRange: PriceRange?) {
        self.priceRange = priceRange
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.title = "\(numResults) Results"
            })
        }
    }
    
    // MARK: - Segue Handling
    
    @IBAction func unwindToSearch(segue: UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifierForSegue(segue: segue) {
        case .hotelDetails:
            guard let destination = segue.destination as? HotelViewController else {
                fatalError("Unexpected destination when trying to perform hotel details segue.")
            }
            destination.hotel = selectedHotel
            
        case .selectFilters:
            guard let navController = segue.destination as? UINavigationController,
                let destination = navController.viewControllers[0] as? FilterSearchViewController else {
                    fatalError("Unexpected destination when trying to perform select filters segue.")
            }
            guard let range = self.priceRange else {
                fatalError("Search results are needed to filter.")
            }
            destination.priceRange = range
            destination.onCompletion = self.filter
        }
    }
}

extension SearchViewController {
    /// Sort options for hotel results
    enum HotelOrder {
        /// name
        case name
        /// priceAscend
        case priceAscending
        /// priceDescend
        case priceDescending
    }
}

extension SearchViewController: SegueHandler {
    /// Identifiers configured in IB
    enum SegueIdentifier: String {
        case hotelDetails = "hotel_details"
        case selectFilters = "select_filters"
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
