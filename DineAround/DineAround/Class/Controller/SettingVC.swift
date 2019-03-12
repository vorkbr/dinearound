//
//  SettingVC.swift
//  DineAround
//
//  Created by iPop on 8/5/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class SettingVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: - Table view data source

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { // change password
            if !UserInfo.shared.isLogin {
                showAlert(title: "Please login!", message: "")
            } else {
                self.performSegue(withIdentifier: "showChangePassword", sender: self)
            }
        }
        else if indexPath.section == 2 { // instructions
            self.performSegue(withIdentifier: "showInstruction", sender: self)
        }
        else {
            if indexPath.row == 0 { // change phone number
                if !UserInfo.shared.isLogin {
                    showAlert(title: "Please login!", message: "")
                } else {
                    self.performSegue(withIdentifier: "showChangePhone", sender: self)
                }
            }
            else if indexPath.row == 1 { // purchase history
                if !UserInfo.shared.isLogin {
                    showAlert(title: "Please login!", message: "")
                } else {
                    self.performSegue(withIdentifier: "showPurchaseHistory", sender: self)
                }
            }
            else { // request help
                self.performSegue(withIdentifier: "showRequestHelp", sender: self)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}

