//
//  CollectionViewManager.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 29/08/2021.
//

import UIKit

struct WeatherCondition {
    
    let title: String
    let details: String
}

class CollectionViewManager: NSObject {
    
    weak var holder: CollectionViewHolder?
    lazy var conditions = [WeatherCondition].init() {
        
        didSet {
            
            holder?.collectionView.reloadData()
        }
    }
    
    init(holder: CollectionViewHolder) {
        
        super.init()
        
        self.holder = holder
        holder.collectionView.delegate = self
        holder.collectionView.dataSource = self
    }
}

extension CollectionViewManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        conditions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? WeatherConditionCollectionViewCell else { fatalError("This cell does not exist") }
        
        let condition = conditions[indexPath.item]
        cell.prepare(with: condition)
        
        return cell
    }
}

extension CollectionViewManager: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let collectionViewWidth = screenWidth - (Constants.margin * 2)
        
        return .init(
            width: collectionViewWidth / CGFloat(Constants.numberOfItemsInARow),
            height:
                .labelHeight(withFont: .systemFont(ofSize: Constants.conditionTitleLabelFontSize, weight: .semibold))
                + Constants.stackViewLabelSpacing
                + .labelHeight(withFont: .systemFont(ofSize: Constants.conditionDetailLabelFontSize, weight: .regular))
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return Constants.collectionViewVerticalInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}

protocol CollectionViewHolder: AnyObject {
    
    var collectionView: UICollectionView! { get set }
}
