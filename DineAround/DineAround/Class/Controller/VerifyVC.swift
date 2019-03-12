//
//  VerifyVC.swift
//  DineAround
//
//  Created by iPop on 8/19/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class VerifyVC: UIViewController {

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet var codeFieldArray: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneLabel.text = "\(UserInfo.shared.phone)"
    }

    @IBAction func actionDone(_ sender: Any) {
        processVerify()
    }
    

    @IBAction func actionRetry(_ sender: UIButton) {
        SwiftLoader.show(title: "Sending the request", animated: true)
        
        for field in codeFieldArray {
            field.text = ""
        }
        ApiManager.shared.userSignup { (code) in
            SwiftLoader.hide()
        }
    }
    
    func processVerify() {
        for field in codeFieldArray {
            field.resignFirstResponder()
        }
        if let codeStr = getCodeString() {
            SwiftLoader.show(animated: true)
            ApiManager.shared.userCredential(code: codeStr, completion: { (errMsg) in
                SwiftLoader.hide()
                if let msg = errMsg {
                    for field in self.codeFieldArray {
                        field.text = ""
                    }
                    self.showAlert(title: "", message: msg)
                }
                else {
                    UserInfo.shared.isLogin = true
                    self.navigationController!.popToRootViewController(animated: true)
                }
            })
        }
    }
    
    func getCodeString() -> String! {
        
        var codeStr: String! = ""
        
        for field in codeFieldArray {
            if field.text == "" {
                return nil
            }
            codeStr = codeStr + field.text!
        }
        
        return codeStr
    }
    
}

extension VerifyVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return true if the replacementString only contains numeric characters
        if string == "" {
            let tag = textField.tag
            DispatchQueue.main.async {
                if tag >= 2 {
                    self.codeFieldArray[tag-2].becomeFirstResponder()
                }
            }
            return true
        }
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil {
            let nsString = NSString(string: textField.text!)
            let newText = nsString.replacingCharacters(in: range, with: string)
            let ret = newText.characters.count <= 1
            
            if newText.characters.count >= 1 {
                let tag = textField.tag
                DispatchQueue.main.async {
                    if tag == 6 {
                        self.processVerify()
                    }
                    else {
                        self.codeFieldArray[tag].becomeFirstResponder()
                    }
                }
            }
            return ret
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

