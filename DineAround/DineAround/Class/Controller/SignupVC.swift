//
//  SignupVC.swift
//  DineAround
//
//  Created by iPop on 8/5/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupButton: UIButton!
    
    var userInfo: UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfo = UserInfo()
    }

    override func viewDidLayoutSubviews() {
        signupButton.makeRound()
        
        var edges = scrollView.contentInset
        edges.bottom = (self.view.frame.size.height-100) * (567-258) / 567
        scrollView.contentInset = edges

    }


    @IBAction func actionLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    
    @IBAction func actionSignup(_ sender: UIButton) {
        
        if isValidItems() == true {
            
            SwiftLoader.show(animated: true)
            
            ApiManager.shared.userSignup(userInfo: userInfo, completion: { (vid) in
                SwiftLoader.hide()
                
                if vid != nil {
                
                    UserInfo.shared.isLogin = false
                    UserInfo.shared.setInfo(self.userInfo)
                
                    self.performSegue(withIdentifier: "showVerify", sender: self)
                }
                else {
                    self.showAlert(title: "", message: "Failed to process this number")
                }
            })
            
        }
    }
    
    func isValidItems() -> Bool {
        if (nameField.text == "") {
            self.showAlert(title: "", message: "Please input name", withField: nameField)
            return false
        }
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
        
        if (emailField.text != "" && isValid(email: emailField.text) == false) {
            self.showAlert(title: "", message: "Invalid email address", withField: emailField)
            return false
        }
        
        if isPasswordLenth(password: passwordField.text) == false {
            self.showAlert(title: "", message: "Password length should be greater than 6", withField: passwordField)
            return false
            
        }
        if isPasswordLenth(password: confirmField.text) == false {
            self.showAlert(title: "", message: "Password length should be greater than 6", withField: confirmField)
            return false
            
        }
        if isPasswordSame(password: passwordField.text, confirmPassword: confirmField.text) == false {
            self.showAlert(title: "", message: "Confirm password is incorrect", withField: confirmField)
            return false
        }
        
        userInfo.name = nameField.text!
        userInfo.phone = phoneField.text!
        userInfo.email = emailField.text!
        userInfo.password = passwordField.text!
        
        return true
    }
}


extension SignupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}



