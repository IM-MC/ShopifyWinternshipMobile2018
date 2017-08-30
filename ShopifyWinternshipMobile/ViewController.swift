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
        overlayVC.dismiss(animated: true, completion: nil)

        
    }
    
    private func reloadOrderData(completionHandler: @escaping ((_ response: Bool)->Void)){
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

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
