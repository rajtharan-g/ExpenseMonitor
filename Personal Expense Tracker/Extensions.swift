//
//  Extensions.swift
//  SquareOff
//
//  Created by Bharath R on 04/04/19.
//  Copyright © 2019 Asim Pereira. All rights reserved.
//

import UIKit

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
