//
//  ViewController.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 27/08/2021.
//

import UIKit
import MapKit

class ViewController: UIViewController, CollectionViewHolder, RequestMaker, LocationButtonContaining {
    
    // MARK: - Outlets

    @IBOutlet var bottomEffectView: UIVisualEffectView!
    @IBOutlet var bottomEffectViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateAndTimeLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    @IBOutlet var goButton: UIButton! {
        
        didSet {
            
            goButton.addTarget(self, action: #selector(getCurrentWeatherConditions), for: .touchUpInside)
        }
    }
    @IBOutlet var locationButton: UIButton! {
        
        didSet {
            
            locationButton.addTarget(self, action: #selector(getCurrentWeatherAtUserLocation(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewParentEffectView: UIVisualEffectView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mapVisualEffectView: UIVisualEffectView!
    
    // MARK: - Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { traitCollection.isDarkMode ? .lightContent : .darkContent }
    
    // MARK: - My Properties
    
    let formatter = DateFormatter.init()
    private lazy var collectionViewManager = CollectionViewManager.init(holder: self)
    private lazy var requestHandler = RequestHandler.init(maker: self)
    private var locationManager = LocationManager.shared
    
    private var collectionViewHeight: CGFloat {
        
        let cellHeight = collectionViewManager.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: .init(item: 0, section: 0)).height
        let numberOfLines = ceil(CGFloat(collectionViewManager.conditions.count) / CGFloat(Constants.numberOfItemsInARow))
        
        return
            Constants.collectionViewVerticalInset
            + (numberOfLines * cellHeight)
            + ((numberOfLines - 1) * Constants.collectionViewVerticalInset)
            + Constants.collectionViewVerticalInset
    }
    
    private var currentAnnotation: MKAnnotation? {
        
        didSet {
            
            guard let oldAnnotation = oldValue else { return }
            
            mapView.removeAnnotation(oldAnnotation)
        }
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionViewParentEffectView.layer.cornerRadius = Constants.cornerRadius
        mapView.layer.cornerRadius = Constants.cornerRadius
        mapVisualEffectView.layer.cornerRadius = Constants.cornerRadius
        mapVisualEffectView.effect = nil
        
        locationManager.buttonContaining = self
        
        textField.delegate = self
        
        prepareVisualEffectView()
        prepareBackground()
        prepareNotifications()
        prepareCollectionViewHeight()
        prepareLocationButton()
    }
    
    // MARK: - Preparation
    
    private func prepareNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard(with:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard(with:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func prepareBackground() {
        
        backgroundImageView.image = #imageLiteral(resourceName: traitCollection.isDarkMode ? "Dark" : "Light")
    }
    
    private func prepareVisualEffectView() {
        
        [bottomEffectView, collectionViewParentEffectView].forEach({
            
            $0?.contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? nil : UIColor.white.withAlphaComponent(0.4)
            $0?.effect = UIBlurEffect.init(style: traitCollection.isDarkMode ? .dark : .light)
        })
    }
    
    func prepareLocationButton() {
        
        guard locationManager.city != nil else {
            
            locationButton.tintColor = .lightGray
            locationButton.setImage(UIImage.init(systemName: "location"), for: .normal)
            
            return
        }
        
        locationButton.tintColor = goButton.tintColor
        locationButton.setImage(UIImage.init(systemName: "location.fill"), for: .normal)
    }
    
    func prepareCollectionViewHeight() {
        
        collectionViewHeightConstraint.constant = collectionViewHeight
    }
    
    func prepareCollectionView(with response: Response) {
        
        weatherLabel.text = .init(format: "%.1f", response.current.temperature) + "°F"
        feelsLikeLabel.text = "Feels like \(String.init(format: "%.1f", response.current.feelsLike))°F"
        locationLabel.text = response.name
        conditionLabel.text = response.current.weather.first?.title ?? "—"
        
        // uses the timezone information from the API to determine the current time for the location returned. Since Date calculations with Unix time always incorporate the current device timezone, we need to remove that to get the right result.
        dateAndTimeLabel.text = formatter.withFormat(.preferredDateFormat).string(from: Date.init(timeIntervalSince1970: TimeInterval(response.current.unixTime + response.timezoneOffset - TimeZone.current.secondsFromGMT())))
        
        collectionViewManager.conditions = [
            
            .init(title: "Humidity", details: "\(response.current.humidity)%"),
            .init(title: "Pressure (hPa)", details: "\(response.current.pressure)"),
            .init(title: "UV Index", details: "\(response.current.uvIndex)"),
            .init(title: "Cloudiness", details: "\(response.current.clouds)%"),
            .init(title: "Wind (m/h)", details: "\(response.current.windSpeed)"),
            .init(title: "Precipitation (mm)", details: "\(String.init(format: "%.1f", response.minutely?.first(where: { Double($0.unixTime + response.timezoneOffset) > Date.init().timeIntervalSince1970 })?.precipitation ?? 0))")
        ]
        
        prepareCollectionViewHeight()
        updateMapView(to: .init(latitude: response.latitude, longitude: response.longitude))
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    func updateMapView(to coordinate: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        currentAnnotation = annotation
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: true)
    }
    
    // MARK: - Responding to System Changes
    
    @objc private func adjustKeyboard(with notification: Notification) {
        
        guard let keyboardHeightAtEnd = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
        
        let keyboardWillShow = notification.name == UIResponder.keyboardWillShowNotification
            
        bottomEffectViewBottomConstraint.constant = keyboardWillShow ? keyboardHeightAtEnd : 0
        collectionViewHeightConstraint.constant = keyboardWillShow ? 0 : collectionViewHeight
        mapViewHeightConstraint.constant = keyboardWillShow ? 60 : Constants.mapViewHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.collectionView.alpha = keyboardWillShow ? 0 : 1
            self.mapVisualEffectView.effect = keyboardWillShow ? UIBlurEffect.init(style: self.traitCollection.isDarkMode ? .dark : .light) : nil
            self.view.layoutIfNeeded()
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            
            prepareBackground()
            prepareVisualEffectView()
        }
    }
    
    // MARK: - The Weather
    
    @objc private func getCurrentWeatherConditions() {
        
        guard let text = textField.text else {
            
            presentErrorAlert(title: "You need to enter a location or zip code to continue")
            
            return
        }
        
        textField.resignFirstResponder()
        
        let alert = requestAlert(title: "Getting Current Conditions...")
        present(alert, animated: true, completion: nil)
        
        requestHandler.getCoordinates(from: text, alert: alert)
    }
    
    @objc func getCurrentWeatherAtUserLocation(_ sender: Any) {
        
        textField.resignFirstResponder()
        
        guard locationManager.authorisationStatus == .authorizedWhenInUse else {
            
            presentErrorAlert(title: "Location access is needed for this feature. You can turn this on in Settings")
            
            return
        }
        
        guard let city = locationManager.city, let country = locationManager.country else {
            
            presentErrorAlert(title: "Your current location has not been obtained yet.")
            
            return
        }
        
        let alert = requestAlert(title: "Getting Current Conditions...")
        present(alert, animated: true, completion: nil)
        
        let text = city + ", " + country
        textField.text = text
        
        let coordinate = CLLocationCoordinate2D.init(latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude)
        
        requestHandler.getCurrentWeatherConditions(from: coordinate, alert: alert, currentConditions: .init(coord: .init(lat: coordinate.latitude, lon: coordinate.longitude), name: text, timezone: TimeZone.current.secondsFromGMT()))
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        getCurrentWeatherConditions()
        
        return true
    }
}
