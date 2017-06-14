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
    @IBOutlet weak var minimumPriceSlider: UISlider!
    
    @IBOutlet weak var maximumPriceLabel: UILabel!
    @IBOutlet weak var maximumPriceSlider: UISlider!
    
    var priceRange: PriceRange!
    
    typealias CompletionClosure = (PriceRange) -> Void
    var onCompletion: CompletionClosure!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let minValue = Float(priceRange.min)
        let maxValue = Float(priceRange.max)
        
        // configure minimum price label and slider
        minimumPriceLabel.text = priceRange.min.asCurrency()
        minimumPriceSlider.minimumValue = minValue
        minimumPriceSlider.maximumValue = maxValue
        
        minimumPriceSlider.setValue(minValue, animated: false)
        
        // configure maximum price label and slider
        maximumPriceLabel.text = priceRange.max.asCurrency()
        maximumPriceSlider.minimumValue = minValue
        maximumPriceSlider.maximumValue = maxValue
        
        maximumPriceSlider.setValue(maxValue, animated: false)
    }
    
    @IBAction func minValueChanged(_ sender: UISlider) {
        // Protects min slider value from being greater than max slider.
        // This prevents an invalid range.
        guard minimumPriceSlider.value < maximumPriceSlider.value else {
            minimumPriceSlider.setValue(maximumPriceSlider.value, animated: false)
            return
        }
        
        let selectedValue = Double(sender.value)
        minimumPriceLabel.text = selectedValue.asCurrency()
    }
    
    @IBAction func maxValueChanged(_ sender: UISlider) {
        // Protects max slider value from being less than min slider.
        // This prevents an invalid range.
        guard maximumPriceSlider.value > minimumPriceSlider.value else {
            maximumPriceSlider.setValue(minimumPriceSlider.value, animated: false)
            return
        }
        
        let selectedValue = Double(sender.value)
        maximumPriceLabel.text = selectedValue.asCurrency()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        priceRange.min = Double(minimumPriceSlider.value)
        priceRange.max = Double(maximumPriceSlider.value)
        
        onCompletion(priceRange)
    }
}
