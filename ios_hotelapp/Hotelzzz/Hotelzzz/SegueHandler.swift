//
//  SegueHandler.swift
//  Hotelzzz
//
//  Created by Natasha Murashev on 12/18/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//
// source: https://www.natashatherobot.com/protocol-oriented-segue-identifiers-swift/

import UIKit

protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegueWithIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    /// Segue handling for eliminating hard-coded String based Segues
    
    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
                fatalError("Invalid segue identifier \(String(describing: segue.identifier)).") }
        
        return segueIdentifier
    }
}

extension UIViewController {
    @IBAction func dismiss(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}
