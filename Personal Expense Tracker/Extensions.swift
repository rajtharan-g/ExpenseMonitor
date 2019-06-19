//
//  Extensions.swift
//  SquareOff
//
//  Created by Bharath R on 04/04/19.
//  Copyright © 2019 Asim Pereira. All rights reserved.
//

import UIKit
import HGPlaceholders

var vSpinner : UIView?

extension UIViewController {
    
    @objc var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }

    func showSpinner(onView : UIView, style: UIActivityIndicatorView.Style) {
        let spinnerView = UIView.init(frame: onView.bounds)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: style)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
    
}

extension UIFont {
    
    class func placeholderTitleFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 20)
    }
    
    class func placeholderSubtitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    class func placeholderButtonFont() -> UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
}

extension UIColor {
    
    class func placeholderTitleColor() -> UIColor {
        return UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
    }
    
    class func placeholderDescriptionColor() -> UIColor {
        return UIColor(red: 64/255, green: 85/255, blue: 196/255, alpha: 1)
    }
    
    class func placeholderButtonColor() -> UIColor {
        return UIColor(red: 0.34, green: 0.39, blue: 0.43, alpha: 0.2)
    }
    
    class func buttonBGColor() -> UIColor {
//        return UIColor(red: 106/255, green: 0, blue: 226/255, alpha: 1)
        return UIColor(red: 85/255, green: 40/255, blue: 243/255, alpha: 1)
    }
    
}

extension PlaceholderStyle {
    
    static func starwarsStyle() -> PlaceholderStyle {
        var style = PlaceholderStyle()
        style.backgroundColor = .clear
        style.actionBackgroundColor = .buttonBGColor()
        style.actionTitleColor = .white
        style.titleColor = .black
        style.subtitleColor = .gray
        style.isAnimated = false
        
        style.titleFont = .placeholderTitleFont()
        style.subtitleFont = .placeholderSubtitleFont()
        style.actionTitleFont = .placeholderButtonFont()
        
        return style
    }
    
}

extension Placeholder {
    
    static func noAccountAdded(withAction: String?) -> Placeholder {
        var starwarsData = PlaceholderData()
        starwarsData.title = NSLocalizedString("No account added.", comment: "")
        starwarsData.subtitle = NSLocalizedString("Please add an account before adding a transaction.", comment: "")
        
        if let actionTitle = withAction {
            starwarsData.action = actionTitle
        }
        
        let placeholder = Placeholder(data: starwarsData, style: .starwarsStyle(), key: PlaceholderKey.noResultsKey)
        
        return placeholder
    }
    
    static var fetchingYourAccounts: Placeholder {
        var starwarsData = PlaceholderData()
        starwarsData.title = NSLocalizedString("Fetching your accounts...", comment: "")
        
        let placeholder = Placeholder(data: starwarsData, style: .starwarsStyle(), key: PlaceholderKey.loadingKey)
        
        return placeholder
    }
    
    static var errorFetchingYourData: Placeholder {
        var starwarsData = PlaceholderData()
        starwarsData.title = NSLocalizedString("There was an error fetching your data.", comment: "")
        starwarsData.subtitle = NSLocalizedString("Please try again later.", comment: "")
        starwarsData.action = NSLocalizedString("OK!", comment: "")
        
        let placeholder = Placeholder(data: starwarsData, style: .starwarsStyle(), key: PlaceholderKey.errorKey)
        
        return placeholder
    }
    
    static var noInternetConnection: Placeholder {
        var starwarsData = PlaceholderData()
        starwarsData.title = NSLocalizedString("No internet connection", comment: "")
        starwarsData.subtitle = NSLocalizedString("Please check your internet connection", comment: "")
        starwarsData.action = NSLocalizedString("OK!", comment: "")
        
        let placeholder = Placeholder(data: starwarsData, style: .starwarsStyle(), key: PlaceholderKey.noConnectionKey)
        
        return placeholder
    }
    
}

