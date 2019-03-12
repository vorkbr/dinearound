//
//  ForgotVC.swift
//  DineAround
//
//  Created by iPop on 8/29/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class ForgotVC: UIViewController {

    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        sendButton.makeRound()
    }
    
    
    @IBAction func actionSend(_ sender: UIButton) {
        if isValidItems() {
            SwiftLoader.show(animated: true)
            ApiManager.shared.requestPhone(phoneNumber: phoneField.text, completion: { (result) in
                SwiftLoader.hide()
                self.performSegue(withIdentifier: "showVerify", sender: self)
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

extension ForgotVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
