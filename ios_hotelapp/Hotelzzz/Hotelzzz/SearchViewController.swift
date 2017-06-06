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

class SearchViewController: UIViewController {
    let webControllerConfig: WKWebViewConfiguration
    private(set) var currentSearch: Search!
    private var selectedHotel: Hotel?
    lazy var eventController: APIEventController = {
        return APIEventController(eventHandler: self.handleEvent)
    }()
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero, configuration: self.webControllerConfig)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    @IBOutlet weak var container: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        let config = WKWebViewConfiguration()
        self.webControllerConfig = config
        
        super.init(coder: aDecoder)
        config.userContentController = eventController.userContentController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.frame = container.bounds
        container.addSubview(webView)
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
    
    func search(location: String, dateStart: Date, dateEnd: Date) {
        currentSearch = Search(location: location, dateStart: dateStart, dateEnd: dateEnd)
        webView.load(URLRequest(url: URL(string: "http://hipmunk.github.io/hipproblems/ios_hotelapp/")!))
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
