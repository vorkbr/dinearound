//
//  ChangePasswordVC.swift
//  DineAround
//
//  Created by iPop on 8/10/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var oldPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
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
        
        if isValidItems() == true {
            ApiManager.shared.userChange(oldPassword: oldPassField.text, toNewPassword: newPassField.text, completion: { (result) in
                if result == -1 {
                    self.showAlert(title: "", message: "Invalid old password")
                }
                else if result == -2 {
                    self.showAlert(title: "", message: "Failed to connect server")
                }
                else {
                    self.navigationController!.popViewController(animated: true)
                }
            })
        }
    }
    
    
    
    func isValidItems() -> Bool {
        if (oldPassField.text == "") {
            self.showAlert(title: "", message: "Please input old password", withField: oldPassField)
            return false
        }

        if isPasswordLenth(password: newPassField.text) == false {
            self.showAlert(title: "", message: "Password length should be greater than 6", withField: newPassField)
            return false
            
        }
        if isPasswordLenth(password: confirmField.text) == false {
            self.showAlert(title: "", message: "Password length should be greater than 6", withField: confirmField)
            return false
            
        }
        if isPasswordSame(password: newPassField.text, confirmPassword: confirmField.text) == false {
            self.showAlert(title: "", message: "Confirm password is incorrect", withField: confirmField)
            return false
        }
        
        return true
    }
}

extension ChangePasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
