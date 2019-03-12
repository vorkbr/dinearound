//
//  RequestHelpVC.swift
//  DineAround
//
//  Created by iPop on 8/10/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import MessageUI

class RequestHelpVC: UIViewController {

    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !MFMailComposeViewController.canSendMail() {
            submitButton.isEnabled = false
            submitButton.setTitleColor(UIColor.lightGray, for: .disabled)
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        submitButton.makeRound()
        
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.cornerRadius = 3
        messageTextView.layer.masksToBounds = true
    }
    
    
    @IBAction func actionSend(_ sender: UIButton) {
        
        if let text = messageTextView.text {
        
            if text == "" {
                showAlert(title: "Please input message!", message: "")
                return
            }
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["madhavs@umich.edu"])
            composeVC.setSubject("Support")
            composeVC.setMessageBody(text, isHTML: false)
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
    }
}

extension RequestHelpVC : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true) {
            self.navigationController!.popViewController(animated: true)
        }
    }
}
