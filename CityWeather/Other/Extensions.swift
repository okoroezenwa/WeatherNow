//
//  Extensions.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 28/08/2021.
//

import UIKit
import MapKit

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
    
    static let preferredDateFormat = "E, MMM dd, yyyy - hh:mm a"
}

extension URLSession {
    
    enum HTTPMethod: String {
        
        case put = "PUT"
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
        case head = "HEAD"
    }
    
    class func makeRequest(with url: URL, method: HTTPMethod, body: Data? = nil) -> URLRequest {
        
        var request = URLRequest.init(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return request
    }
}

extension UIViewController {
    
    func requestAlert(title: String?) -> UIAlertController {
        
        UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
    }
    
    func presentErrorAlert(title: String?, message: String? = nil) {
        
        let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

extension URLComponents {
    
    enum CallType { case coordinates(String), conditions(CLLocationCoordinate2D) }
    
    static func buildComponents(ofType type: CallType) -> URLComponents {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        
        let lastPathItem: String = {
            
            switch type {
                
                case .conditions(_): return "onecall"
                    
                case .coordinates(_): return "weather"
            }
        }()
        
        components.path = "/data/2.5/\(lastPathItem)"
        
        let items: [URLQueryItem] = {
            
            switch type {
                
                case .conditions(let coordinates):
                    
                    return [
                        
                        .init(name: "lat", value: "\(coordinates.latitude)"),
                        .init(name: "lon", value: "\(coordinates.longitude)"),
                        .init(name: "exclude", value: "hourly,daily")
                    ]
                    
                case .coordinates(let query):
                    
                    return [.init(name: "q", value: "\(query)")]
            }
        }()
        
        components.queryItems = items + [
            
            .init(name: "units", value: "imperial"),
            .init(name: "appid", value: "b70953dbe7338b90a67f650598d6e321")
        ]
        
        return components
    }
}

extension CGFloat {
    
    static func labelHeight(withFont font: UIFont) -> CGFloat {
        
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.text = "Test"
        
        return label.sizeThatFits(UIView.layoutFittingCompressedSize).height
    }
}

extension CLLocation {
    
    func fetchCityAndCountry(completion: @escaping (_ street: String?, _ city: String?, _ state:  String?, _ country: String?, _ error: Error?) -> ()) {
        
        CLGeocoder().reverseGeocodeLocation(self) { placemarks, error in completion(placemarks?.first?.subAdministrativeArea, placemarks?.first?.locality, placemarks?.first?.administrativeArea, placemarks?.first?.country, error) }
    }
}
