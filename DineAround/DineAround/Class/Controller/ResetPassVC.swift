//
//  ResetPassVC.swift
//  DineAround
//
//  Created by iPop on 8/30/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class ResetPassVC: UIViewController {

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
            SwiftLoader.show(animated: true)
            ApiManager.shared.resetPassword(newPassField.text, completion: { (result) in
                SwiftLoader.hide()
                if result == -2 {
                    self.showAlert(title: "", message: "Failed to connect server")
                }
                else {
                    self.showSuccess()
                }
            })
        }
    }
    
    func isValidItems() -> Bool {
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
    
    func showSuccess() {
        let alertVC = UIAlertController(title: "", message: "Reset password successfully", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            DispatchQueue.main.async {
                self.navigationController!.popToRootViewController(animated: true)
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension ResetPassVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

