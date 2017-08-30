//
//  OverlayWithSpinner.swift
//  ShopifyWinternshipMobile
//
//  Created by Matthew Chung on 2017-08-29.
//  Copyright © 2017 Matthew Chung. All rights reserved.
//

import UIKit

class OverlayWithSpinner: UIViewController {

    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(overlayView)

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        overlayView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.6
        
        overlayView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        spinner.startAnimating()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
