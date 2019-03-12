//
//  LoginVC.swift
//  DineAround
//
//  Created by iPop on 8/5/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //phoneField.text = "123456789"
        //passwordField.text = "123456"
    }
    
    override func viewDidLayoutSubviews() {
        loginButton.makeRound()
        
        var edges = scrollView.contentInset
        edges.bottom = (self.view.frame.size.height-100) * (567-258) / 567
        scrollView.contentInset = edges
    }
    
    
    @IBAction func actionLogin(_ sender: UIButton) {
        
        if isValidItems() == true {
            SwiftLoader.show(animated: true)
            
            ApiManager.shared .userLogin(phoneNumber: phoneField.text!, password: passwordField.text!) { (result) in
                SwiftLoader.hide()
                
                if result == 0 {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                        self.navigationController!.popToRootViewController(animated: true)
                    })
                }
                else {
                    self.showAlert(title: "", message: "Invalide phone or password")
                }
            }
        }
    }
    
    @IBAction func actionReset(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showForgot", sender: self)
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
        
        if isPasswordLenth(password: passwordField.text) == false {
            self.showAlert(title: "", message: "Password length should be greater than 6", withField: passwordField)
            return false
            
        }


        
        return true
    }
}


extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}



