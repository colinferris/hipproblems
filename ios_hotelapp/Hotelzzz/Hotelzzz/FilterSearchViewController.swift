//
//  FilterSearchViewController.swift
//  Hotelzzz
//
//  Created by Colin Ferris on 6/8/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import UIKit

typealias PriceRange = (min: Double, max: Double)

class FilterSearchViewController: UIViewController {
    @IBOutlet weak var minimumPriceLabel: UILabel!
    @IBOutlet weak var maximumPriceLabel: UILabel!
    @IBOutlet weak var priceSlider: UISlider!
    
    var priceRange: PriceRange!
    
    typealias CompletionClosure = (PriceRange) -> Void
    var onCompletion: CompletionClosure!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.minimumPriceLabel.text = priceRange.min.asCurrency()
        self.maximumPriceLabel.text = priceRange.max.asCurrency()
        
        let minValue = Float(priceRange.min)
        let maxValue = Float(priceRange.max)
        self.priceSlider.minimumValue = minValue
        self.priceSlider.maximumValue = maxValue
    }
    
    @IBAction func maxValueChanged(_ sender: UISlider) {
        let selectedValue = Double(sender.value)
        maximumPriceLabel.text = selectedValue.asCurrency()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        priceRange.max = Double(priceSlider.value)
        onCompletion(priceRange)
    }
}
