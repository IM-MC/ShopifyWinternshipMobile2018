//
//  ViewController.swift
//  ShopifyWinternshipMobile
//
//  Created by Matthew Chung on 2017-08-26.
//  Copyright © 2017 Matthew Chung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let url = URL(string: "https://shopicruit.myshopify.com/admin/orders.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6")
    let imageURL = URL(string: "https://shopicruit.myshopify.com/admin/products/2759139395/images.json?access_token=c32313df0d0ef512ca64d5b336a0d7c6")
    
    var orders: [Order] = []
    var itemArray: [String] = []
    
    var bronzeBagCount = 0
    var itemImageSource: String = ""
    
    let overlayVC = OverlayWithSpinner()
    
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var bronzeBagAmountLabel: UILabel!
    @IBOutlet weak var bronzeBagImage: UIImageView!
    
    @IBAction func refreshButton(_ sender: Any) {
        overlayVC.modalTransitionStyle = .crossDissolve
        overlayVC.modalPresentationStyle = .overCurrentContext
        present(overlayVC, animated: true, completion: nil)
        
        reloadOrderData { (response) in

            self.bronzeBagCount = 0
            var total_spent: String = ""
            
            for item in self.itemArray {
                if item == "Awesome Bronze Bag" {
                    self.bronzeBagCount += 1
                }
            }
            
            for order in self.orders {
                if order.first_name == "Napoleon" && order.last_name == "Batz" {
                    total_spent = order.total_spent!
                }
            }
            
            DispatchQueue.main.async {
                if response {
                    self.amountSpentLabel.text = "$" + total_spent
                    self.bronzeBagAmountLabel.text = String(self.bronzeBagCount)
                }
            }
        }
        
        grabImageData { (response) in
            
            if response {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: URL(string: self.itemImageSource)!)
                    DispatchQueue.main.async {
                        self.bronzeBagImage.image = UIImage(data: data!)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.bronzeBagImage.image = UIImage(named: "Image_Not_Available")
                }
            }
        }

        overlayVC.dismiss(animated: true, completion: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bronzeBagImage.contentMode = .scaleAspectFit
        
        reloadOrderData { (response) in
            self.bronzeBagCount = 0
            var total_spent: String = ""
            
            for item in self.itemArray {
                if item == "Awesome Bronze Bag" {
                    self.bronzeBagCount += 1
                }
            }
            
            for order in self.orders {
                if order.first_name == "Napoleon" && order.last_name == "Batz" {
                    total_spent = order.total_spent!
                }
            }
            
            DispatchQueue.main.async {
                if response {
                    self.amountSpentLabel.text = "$" + total_spent
                    self.bronzeBagAmountLabel.text = String(self.bronzeBagCount)
                }
            }
        }
        
        grabImageData { (response) in
            
            if response {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: URL(string: self.itemImageSource)!)
                    DispatchQueue.main.async {
                        self.bronzeBagImage.image = UIImage(data: data!)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.bronzeBagImage.image = UIImage(named: "Image_Not_Available")
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func reloadOrderData(completionHandler: @escaping ((_ response: Bool) -> Void)){
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            self.itemArray = []
            
            if error != nil {
                let errorView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let okayButton = UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
                    errorView.dismiss(animated: true, completion: nil)
                })
                errorView.addAction(okayButton)
                self.show(errorView, sender: self)
                completionHandler(false)
            }
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]{
                if let result = json?["orders"] as? [[String: Any]] {
                    for output in result {
                        let order = Order()
                        if let customer = output["customer"] as? [String: Any] {
                            order.first_name = customer["first_name"] as? String
                            order.last_name = customer["last_name"] as? String
                            order.total_spent = customer["total_spent"] as? String
                        }
                        
                        if let line_items = output["line_items"] as? [[String:Any]] {
                            for items in line_items {
                                if let title = items["title"] as? String {
                                    self.itemArray.append(title)
                                }
                            }
                        }
                        
                        completionHandler(true)
                        
                        self.orders.append(order)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func grabImageData(completionHandler: @escaping ((_ response: Bool) -> Void)) {
        let task = URLSession.shared.dataTask(with: imageURL!) {(data, response, error) in
            if error != nil {
                let errorView = UIAlertController(title: "Error", message: "Cannot grab image data. \n \(String(describing: (error ?? "" as! Error).localizedDescription))", preferredStyle: .alert)
                let okayButton = UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
                    errorView.dismiss(animated: true, completion: nil)
                })
                errorView.addAction(okayButton)
                self.show(errorView, sender: self)
                completionHandler(false)
            }
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                if let images = json?["images"] as? [[String:Any]] {
                    for items in images {
                        if let imageSource = items["src"] as? String {
                            self.itemImageSource = imageSource
                            completionHandler(true)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
}
