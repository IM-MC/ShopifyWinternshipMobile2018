//
//  Button.swift
//  ShopifyWinternshipMobile
//
//  Created by Matthew Chung on 2017-08-27.
//  Copyright © 2017 Matthew Chung. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lightBlueColor = UIColor(red: 71/255, green: 212/255, blue: 252/255, alpha: 1)
        
        self.layer.borderColor = lightBlueColor.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        
        self.setTitleColor(lightBlueColor, for: .normal)
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
