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
    
    var orders: [Order] = []
    var itemArray: [String] = []
    
    var bronzeBagCount = 0
    
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var bronzeBagAmountLabel: UILabel!
    
    @IBAction func refreshButtonBatz(_ sender: Any) {
        reloadOrderData()
        
        var total_spent: String = ""
        
        for order in orders {
            if order.first_name == "Napoleon" && order.last_name == "Batz" {
                total_spent = order.total_spent!
            }
        }
        amountSpentLabel.text = "$" + total_spent
        
    }

    @IBAction func refreshButtonBronzeBags(_ sender: Any) {
        bronzeBagCount = 0
        
        reloadOrderData()
        
        for item in itemArray {
            if item == "Awesome Bronze Bag" {
                bronzeBagCount += 1
                bronzeBagAmountLabel.text = String(bronzeBagCount)
            }
        }
    }

    private func reloadOrderData() {
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in

            self.itemArray = []
            
            if error != nil {
                print(error?.localizedDescription ?? "")
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

                        self.orders.append(order)
                    }
                }
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadOrderData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
