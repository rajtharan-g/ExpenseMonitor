//
//  RoundedButton.swift
//  Personal Expense Tracker
//
//  Created by Rajtharan G on 16/06/19.
//  Copyright © 2019 Vyshak Athreya B K. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // For storyboard
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // If button in storyboard is Custom, you'll need to set
        // title color for control states and optionally the font
        // I've set mine to System, so uncomment next three lines if Custom
        
        configure()
    }
    
    func configure() {
        self.layer.cornerRadius = 22
        self.clipsToBounds = true
    }
    
}
