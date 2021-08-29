//
//  WeatherConditionCollectionViewCell.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 29/08/2021.
//

import UIKit

class WeatherConditionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    func prepare(with condition: WeatherCondition) {
        
        titleLabel.text = condition.details
        detailLabel.text = condition.title
    }
}
