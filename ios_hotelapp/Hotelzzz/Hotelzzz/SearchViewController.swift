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
    private var _searchToRun: Search?

    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero, configuration: {
            let config = WKWebViewConfiguration()
            config.userContentController = {
                let userContentController = WKUserContentController()
                
                // DECLARE YOUR MESSAGE HANDLERS HERE
                userContentController.add(self, name: "API_READY")
                userContentController.add(self, name: "HOTEL_API_HOTEL_SELECTED")
                
                return userContentController
            }()
            return config
        }())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: ["webView": webView]))
        return webView
    }()
    
    func search(location: String, dateStart: Date, dateEnd: Date) {
        _searchToRun = Search(location: location, dateStart: dateStart, dateEnd: dateEnd)
        self.webView.load(URLRequest(url: URL(string: "http://hipmunk.github.io/hipproblems/ios_hotelapp/")!))
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "API_READY":
            guard let searchToRun = _searchToRun else { fatalError("Tried to load the page without having a search to run") }
            let json: String
            do {
                json = try searchToRun.getJSON()
            }
            catch {
                fatalError("Failed stringify search info")
            }
            self.webView.evaluateJavaScript(
                "window.JSAPI.runHotelSearch(\(json))",
                completionHandler: nil)
        case "HOTEL_API_HOTEL_SELECTED":
            guard let body = message.body as? [String: Any], let result = body["result"] as? [String: Any] else { return }
            let hotel: Hotel
            do {
                hotel = try result.get(result)
            }
            catch {
                //Add better error handling
                fatalError("Unable to parse selected hotel")
            }
            // Delete me
            print(hotel)
            self.performSegue(withIdentifier: "hotel_details", sender: nil)
        default: break
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
