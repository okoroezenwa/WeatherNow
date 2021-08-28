//
//  Extensions.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 28/08/2021.
//

import UIKit

extension UITraitCollection {
    
    var isDarkMode: Bool { userInterfaceStyle == .dark }
}

extension DateFormatter {
    
    func withFormat(_ format: String) -> DateFormatter {
        
        self.dateFormat = format
        
        return self
    }
}

extension String {
    
    static let preferredDateFormat = "EEEE, MMM dd, yyyy"
}
