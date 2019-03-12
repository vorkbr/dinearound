//
//  PurchaseVC.swift
//  DineAround
//
//  Created by iPop on 8/31/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class PurchaseVC: UIViewController {
    
    @IBOutlet weak var purchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        purchaseButton.makeRound()
    }
    
    @IBAction func actionPurchase(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
