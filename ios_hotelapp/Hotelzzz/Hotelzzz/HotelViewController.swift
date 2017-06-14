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
    @IBOutlet weak var hotelPhotoView: RoundedImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hotelNameLabel.text = hotel.name
        addressLabel.text = hotel.address
        priceLabel.text = hotel.price.asCurrency()
        
        self.hotelPhotoView.alpha = 0.0
        
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
                    self.hotelPhotoView.image = UIImage(data: data)
                    
                    UIView.animate(withDuration: 0.2,
                                   delay: 0.0,
                                   options: .curveEaseIn,
                                   animations: {
                                    self.hotelPhotoView.alpha = 1.0
                    }, completion: nil)
                }
            }
            }.resume()
    }
}

extension Double {
    func asCurrency() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self))
    }
}

@IBDesignable
class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}
