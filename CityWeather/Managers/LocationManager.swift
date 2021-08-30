//
//  LocationManager.swift
//  Sistem
//
//  Created by Ezenwa Okoro on 03/08/2021.
//  Copyright © 2021 Sistem. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private override init() {
        
        self.manager = CLLocationManager()
        authorisationStatus = manager.authorizationStatus
        
        super.init()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    lazy var results = [MKLocalSearchCompletion]()
    let manager: CLLocationManager
    var authorisationStatus: CLAuthorizationStatus
    var location = CLLocation.init(latitude: 0, longitude: 0) {
        
        didSet {
            
            location.fetchCityAndCountry(completion: { street, city, state, country, error in
                
                self.street = street
                self.city = city
                self.state = state
                self.country = country
            })
        }
    }
    var street: String?
    var city: String? {
        
        didSet {
            
            locationPresenter?.prepareLocationButton()
        }
    }
    var state: String?
    var country: String?
    
    weak var locationPresenter: LocationButtonContaining?
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
        
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.resultTypes = [.address]

        return completer
    }()
    
    //MARK: CLLocationManager Delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        authorisationStatus = status
        
        switch status {
            
            case .notDetermined, .denied, .restricted: break
                
            case .authorizedWhenInUse: self.manager.startUpdatingLocation()
                
            case .authorizedAlways: self.manager.startUpdatingLocation()
            
            @unknown default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = locations.last ?? .init(latitude: 0, longitude: 0)
        manager.stopUpdatingLocation()
        
        // immediately stops updating location because that is a battery killer
    }
}

protocol LocationButtonContaining: AnyObject {
    
    func prepareLocationButton()
    func updateTableView()
    func getConditionsForResult(_ result: MKLocalSearchCompletion)
}

extension LocationManager: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let object = results[indexPath.row]
        cell.textLabel?.text = object.title
        cell.detailTextLabel?.text = object.subtitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let result = results[indexPath.row]
        locationPresenter?.getConditionsForResult(result)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LocationManager: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        results = completer.results
        locationPresenter?.updateTableView()
    }
}
