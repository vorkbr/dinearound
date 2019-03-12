//
//  MenuImageVC.swift
//  DineAround
//
//  Created by iPop on 8/31/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class MenuImageVC: UIViewController {

    var location: Location!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let location = location {
            location.setImage(toImageView: imageView, url: location.menuImageURL)
        }
        else {
            imageView.image = UIImage(named: "placeholder")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
