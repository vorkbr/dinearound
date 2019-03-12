//
//  ChangePhoneVC.swift
//  DineAround
//
//  Created by iPop on 8/10/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class ChangePhoneVC: UIViewController {

    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        changeButton.makeRound()
        
        var edges = scrollView.contentInset
        edges.bottom = (self.view.frame.size.height-100) * (567-258) / 567
        scrollView.contentInset = edges
    }
    
    
    @IBAction func actionChange(_ sender: UIButton) {
        
        if isValidItems() {
            ApiManager.shared.userChangePhoneNumber(phoneField.text, completion: { (res) in
                if res < 0 {
                    self.showAlert(title: "Couldn't change to this number", message: "", withField: self.phoneField)
                }
                else {
                    self.performSegue(withIdentifier: "showVerify", sender: self)
                }
            })
        }
    }
    
    
    
    func isValidItems() -> Bool {
        if (phoneField.text == "") {
            self.showAlert(title: "", message: "Please input phone number", withField: phoneField)
            return false
        }
        else {
//            if isValid(phone: phoneField.text) == false {
//                self.showAlert(title: "", message: "Invalid phone number", withField: phoneField)
//                return false
//            }
        }
        
        
        return true
    }

}

extension ChangePhoneVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

