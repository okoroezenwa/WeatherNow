//
//  RequestManager.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 28/08/2021.
//

import UIKit
import MapKit

class RequestHandler {
    
    weak var requestMaker: (RequestMaker & UIViewController)?
    
    init(maker: RequestMaker & UIViewController) {
        
        self.requestMaker = maker
    }
    
    func getCoordinates(from text: String, alert: UIAlertController) {
        
        guard case let components = URLComponents.buildComponents(ofType: .coordinates(text)), let url = components.url else {
            
            alert.dismiss(animated: true, completion: nil)
            
            return
        }
        
        let request = URLSession.makeRequest(with: url, method: .get)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            guard error == nil else {
                
                alert.dismiss(animated: true, completion: nil)
                
                print(error as Any)
                
                return
            }
            
            DispatchQueue.main.async {
                
                guard let weakSelf = self, let data = data else { return }
                
                do {
                    
                    let object = try JSONDecoder.init().decode(Object.self, from: data)
                    
                    weakSelf.getCurrentWeatherConditions(from: .init(latitude: object.coord.lat, longitude: object.coord.lon), alert: alert, currentConditions: object)
                    
                } catch let error {
                    
                    print(error)
                    
                    do {
                        
                        let errorObject = try JSONDecoder.init().decode(RequestError.self, from: data)
                        
                        alert.dismiss(animated: true, completion: { weakSelf.requestMaker?.presentErrorAlert(title: errorObject.message) })
                        
                    } catch let error {
                        
                        alert.dismiss(animated: true, completion: nil)
                        
                        print(error)
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func getCurrentWeatherConditions(from coordinates: CLLocationCoordinate2D, alert: UIAlertController, currentConditions object: Object) {
        
        guard case let components = URLComponents.buildComponents(ofType: .conditions(coordinates)), let url = components.url else {
            
            alert.dismiss(animated: true, completion: nil)
            
            return
        }
        
        let request = URLSession.makeRequest(with: url, method: .get)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            guard error == nil else {
                
                alert.dismiss(animated: true, completion: nil)
                
                print(error as Any)
                
                return
            }
            
            DispatchQueue.main.async {
                
                guard let weakSelf = self, let data = data else { return }
                
                do {
                    
                    var response = try JSONDecoder.init().decode(Response.self, from: data)
                    response.name = object.name
                    response.timezoneOffset = object.timezone
                    
                    weakSelf.requestMaker?.prepareCollectionView(with: response)
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                } catch let error {
                    
                    print(error)
                    
                    do {
                        
                        let errorObject = try JSONDecoder.init().decode(RequestError.self, from: data)
                        
                        weakSelf.requestMaker?.presentErrorAlert(title: errorObject.message)
                        
                    } catch let error {
                        
                        print(error)
                    }
                }
            }
        })
        
        task.resume()
    }
}

protocol RequestMaker: AnyObject {
    
    func prepareCollectionView(with response: Response)
}
