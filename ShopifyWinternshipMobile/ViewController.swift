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
    let currencyExchangeFromUSD = URL(string: "https://openexchangerates.org/api/latest.json?app_id=7b9fcc02aab24739929a0f5e6e93e571")
    
    var orders: [Order] = []
    var itemArray: [String] = []
    
    var bronzeBagCount = 0
    var itemImageSource: String = ""
    
    var USDtoCADConversionRate = 0.00
    
    let overlayVC = OverlayWithSpinner()
    
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var bronzeBagAmountLabel: UILabel!
    @IBOutlet weak var bronzeBagImage: UIImageView!
    
    @IBAction func refreshButton(_ sender: Any) {
        overlayVC.modalTransitionStyle = .crossDissolve
        overlayVC.modalPresentationStyle = .overCurrentContext
        present(overlayVC, animated: true, completion: nil)
        
        reloadOverallData()
       
        overlayVC.dismiss(animated: true, completion: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bronzeBagImage.contentMode = .scaleAspectFit
        
        getCurrencyExchangeFromUSDtoCAD { (response, data) in
            if response != true {
                self.USDtoCADConversionRate = 1.24 //At time of creation the exchange rate is 1.24. This should only happen if reading the json fails
            } else {
                self.USDtoCADConversionRate = data
            }
        }
        
        reloadOverallData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func reloadOverallData() {
        
        reloadOrderData { (response, orderArray, items, error) in
            
            self.orders = orderArray
            self.itemArray = items
            
            self.bronzeBagCount = 0
            var total_spent: String = ""
            
            for item in self.itemArray {
                if item == "Awesome Bronze Bag" {
                    self.bronzeBagCount += 1
                }
            }
            
            for order in self.orders {
                if order.first_name == "Napoleon" && order.last_name == "Batz" {
                    if let total_spent_double = Double(order.total_spent ?? "0") {
                        total_spent = String(format: "%.2f", (total_spent_double * self.USDtoCADConversionRate))
                    }
                }
            }
            
            DispatchQueue.main.async {
                if response {
                    self.amountSpentLabel.text = "$" + total_spent
                    self.bronzeBagAmountLabel.text = String(self.bronzeBagCount)
                } else {
                    let errorView = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
                        errorView.dismiss(animated: true, completion: nil)
                    })
                    errorView.addAction(okayButton)
                    self.show(errorView, sender: self)
                }
            }
        }
        
        grabImageURL { (response, data) in
            
            self.itemImageSource = data
            guard let itemImageSourceURL = URL(string: self.itemImageSource) else {
                DispatchQueue.main.async {
                    self.bronzeBagImage.image = UIImage(named: "Image_Not_Available")
                }
                return
            }
            
            if let data = try? Data(contentsOf: itemImageSourceURL) {
                DispatchQueue.main.async {
                    if response {
                        self.bronzeBagImage.image = UIImage(data: data)
                    } else {
                        self.bronzeBagImage.image = UIImage(named: "Image_Not_Available")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.bronzeBagImage.image = UIImage(named: "Image_Not_Available")
                }
            }
        }

    }
    
    private func reloadOrderData(completionHandler: @escaping ((_ response: Bool, _ orders: [Order], _ items: [String], _ error: String) -> Void)){
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            var orderArray = [Order]()
            var itemTitleArray = [String]()
            self.itemArray = []
            
            if error != nil {
                completionHandler(false, [], [], error?.localizedDescription ?? "")
                return
            }
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                if let result = json?["orders"] as? [[String: Any]] {
                    for output in result {
                        let order = Order()
                        if let customer = output["customer"] as? [String: Any] {
                            order.first_name = customer["first_name"] as? String
                            order.last_name = customer["last_name"] as? String
                            order.total_spent = customer["total_spent"] as? String
                            orderArray.append(order)
                        }
                        
                        if let line_items = output["line_items"] as? [[String:Any]] {
                            for items in line_items {
                                if let title = items["title"] as? String {
                                    itemTitleArray.append(title)
                                }
                            }
                        }
                        completionHandler(true, orderArray, itemTitleArray, "")
                    }
                }
            } else {
                completionHandler(false, [], [], "Error parsing JSON file")
            }
        }
        task.resume()
    }
    
    private func grabImageURL(completionHandler: @escaping ((_ response: Bool, _ data: String) -> Void)) {
        let task = URLSession.shared.dataTask(with: imageURL!) {(data, response, error) in
            
            var imageSRC: String = ""

            if error != nil {
                completionHandler(false, "")
            }

            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                if let images = json?["images"] as? [[String: Any]] {
                    for items in images {
                        if let imageSource = items["src"] as? String {
                            imageSRC = imageSource
                        }
                    }
                    completionHandler(true, imageSRC)

                }
            } else {
                completionHandler(false, "")
            }
        }
        task.resume()
    }
    
    func getCurrencyExchangeFromUSDtoCAD(completionHandler: @escaping ((_ response: Bool, _ data: Double) -> Void)) {
        let task = URLSession.shared.dataTask(with: currencyExchangeFromUSD!) {(data, response, error) in
            var USDtoCAD: Double = 0.00
            
            if error != nil {
                completionHandler(false, 0.00)
            }
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                if let CADrate = json?["rates"]?["CAD"] as! Double? {
                    USDtoCAD = CADrate
                    completionHandler(true, USDtoCAD)
                }
            } else {
                completionHandler(false, 0.00)
            }
        }
        task.resume()
    }
    
}
