//
//  HotelViewController.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/22/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import Foundation
import UIKit

enum ImageLoadError: Error {
    case badURL(location: String)
}

class HotelViewController: UIViewController {
    var hotel: Hotel!
    @IBOutlet var hotelNameLabel: UILabel!
    @IBOutlet weak var hotelImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hotelNameLabel.text = hotel.name
        addressLabel.text = hotel.address
        priceLabel.text = "$\(hotel.price)"
        
        do { try loadImage(from: hotel.imageUrl) }
        catch ImageLoadError.badURL(let location) {
            print("Failed to load image from - \(location)")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func loadImage(from location: String) throws {
        guard let url = URL(string: location) else {
            throw ImageLoadError.badURL(location: location)
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    self.hotelImageView.image = UIImage(data: data)
                    self.hotelImageView.layer.cornerRadius = (self.hotelImageView.image?.size.width)! / 2
                }
            }
            }.resume()
    }
}
