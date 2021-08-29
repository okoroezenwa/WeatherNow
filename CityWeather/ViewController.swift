//
//  ViewController.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 27/08/2021.
//

import UIKit

class ViewController: UIViewController, CollectionViewHolder, RequestMaker {
    
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
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewParentEffectView: UIVisualEffectView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { traitCollection.isDarkMode ? .lightContent : .darkContent }
    
    // MARK: - My Properties
    
    let formatter = DateFormatter.init()
    private lazy var collectionViewManager = CollectionViewManager.init(holder: self)
    private lazy var requestHandler = RequestHandler.init(maker: self)
    
    private var collectionViewHeight: CGFloat {
        
        let cellHeight = collectionViewManager.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: .init(item: 0, section: 0)).height
        let numberOfLines = ceil(CGFloat(collectionViewManager.conditions.count) / CGFloat(Constants.numberOfItemsInARow))
        
        return
            Constants.collectionViewVerticalInset
            + (numberOfLines * cellHeight)
            + ((numberOfLines - 1) * Constants.collectionViewVerticalInset)
            + Constants.collectionViewVerticalInset
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionViewParentEffectView.layer.cornerRadius = 14
        
        textField.delegate = self
        
        prepareVisualEffectView()
        prepareBackground()
        prepareNotifications()
    }
    
    func prepareNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard(with:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard(with:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func prepareBackground() {
        
        backgroundImageView.image = #imageLiteral(resourceName: traitCollection.isDarkMode ? "Dark" : "Light")
    }
    
    func prepareVisualEffectView() {
        
        [bottomEffectView, collectionViewParentEffectView].forEach({
            
            $0?.contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? nil : UIColor.white.withAlphaComponent(0.4)
            $0?.effect = UIBlurEffect.init(style: traitCollection.isDarkMode ? .dark : .light)
        })
    }
    
    func prepareCollectionView(with response: Response) {
        
        weatherLabel.text = .init(format: "%.1f", response.current.temperature) + "°F"
        feelsLikeLabel.text = "Feels like \(String.init(format: "%.1f", response.current.feelsLike))°F"
        locationLabel.text = response.name
        conditionLabel.text = response.current.weather.first?.title ?? "—"
        dateAndTimeLabel.text = formatter.withFormat(.preferredDateFormat).string(from: Date.init(timeIntervalSince1970: TimeInterval(response.current.unixTime)))
        print(response.timezoneOffset)
        collectionViewManager.conditions = [
            
            .init(title: "Humidity", details: "\(response.current.humidity)"),
            .init(title: "Pressure (hPa)", details: "\(response.current.pressure)"),
            .init(title: "UV Index", details: "\(response.current.uvIndex)"),
            .init(title: "Cloudiness", details: "\(response.current.clouds)%"),
            .init(title: "Wind (m/h)", details: "\(response.current.windSpeed)"),
            .init(title: "Precipitation (%)", details: "\(String.init(format: "%.1f", response.minutely?.first(where: { Double($0.unixTime + response.timezoneOffset) > Date.init().timeIntervalSince1970 })?.precipitation ?? 0))mm")
        ]
        
        collectionViewHeightConstraint.constant = collectionViewHeight
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    @objc func adjustKeyboard(with notification: Notification) {
        
        guard let keyboardHeightAtEnd = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
        
        let keyboardWillShow = notification.name == UIResponder.keyboardWillShowNotification
            
        bottomEffectViewBottomConstraint.constant = keyboardWillShow ? keyboardHeightAtEnd : 0
        collectionViewHeightConstraint.constant = keyboardWillShow ? 50 : collectionViewHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.collectionView.alpha = keyboardWillShow ? 0 : 1
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
    
    @objc func getCurrentWeatherConditions() {
        
        guard let text = textField.text else {
            
            presentErrorAlert(title: "You need to enter a location or zip code to continue")
            
            return
        }
        
        textField.resignFirstResponder()
        
        let alert = requestAlert(title: "Getting Current Conditions...")
        
        present(alert, animated: true, completion: nil)
        
        requestHandler.getCoordinates(from: text, alert: alert)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        getCurrentWeatherConditions()
        
        return true
    }
}
