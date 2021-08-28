//
//  ViewController.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 27/08/2021.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet var bottomEffectView: UIVisualEffectView!
    @IBOutlet var bottomEffectViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var goButton: UIButton! {
        
        didSet {
            
            goButton.addTarget(self, action: #selector(getCurrentWeatherConditions), for: .touchUpInside)
        }
    }
    
    // MARK: - Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { traitCollection.isDarkMode ? .lightContent : .darkContent }
    
    // MARK: - My Properties
    
    let formatter = DateFormatter.init()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        bottomEffectView.layer.cornerRadius = 14
        
        prepareVisualEffectView()
        prepareBackground()
        prepareNotifications()
        prepareDateLabel()
    }
    
    func prepareDateLabel() {
        
        dateLabel.text = formatter.withFormat(.preferredDateFormat).string(from: .init())
    }
    
    func prepareNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard(with:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard(with:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func prepareBackground() {
        
        backgroundImageView.image = #imageLiteral(resourceName: traitCollection.isDarkMode ? "Dark" : "Light")
    }
    
    func prepareVisualEffectView() {
        
        bottomEffectView.contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? nil : UIColor.white.withAlphaComponent(0.4)
        bottomEffectView.effect = UIBlurEffect.init(style: traitCollection.isDarkMode ? .dark : .light)
    }
    
    @objc func adjustKeyboard(with notification: Notification) {
        
        guard let keyboardHeightAtEnd = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
        
        let keyboardWillShow = notification.name == UIResponder.keyboardWillShowNotification
            
        bottomEffectViewBottomConstraint.constant = (keyboardWillShow ? keyboardHeightAtEnd : 0) + 20
        
        UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            
            prepareBackground()
            prepareVisualEffectView()
        }
    }
    
    @objc func getCurrentWeatherConditions() {
        
        
    }
}

