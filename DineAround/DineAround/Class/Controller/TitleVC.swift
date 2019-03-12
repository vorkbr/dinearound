//
//  TitleVC.swift
//  DineAround
//
//  Created by iPop on 8/5/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class TitleVC: UIViewController {

    @IBOutlet weak var tabView1: UIView!
    @IBOutlet weak var tabView2: UIView!
    
    
    @IBOutlet weak var loginFacebookButton: UIButton!
    @IBOutlet weak var signupFacebookButton: UIButton!
    
    var tabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectTab(index: 0)
        tabIndex = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        loginFacebookButton.makeRound()
        signupFacebookButton.makeRound()
    }

    // MARK:- Action

    @IBAction func actionSignup(_ sender: UIButton) {
        if tabIndex == 1 {
            tabIndex = 0
            selectTab(index: 0)
        }
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        if tabIndex == 0 {
            tabIndex = 1
            selectTab(index: 1)
        }
    }
    
    
    @IBAction func actionSignupPhone(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showSignup", sender: self)
    }
         
    @IBAction func actionLoginPhone(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    
    // MARK: - 
    
    func selectTab(index: Int) {
        
        let flag: Bool = (index == 0)
        
        tabView1.isHidden = !flag
        tabView2.isHidden = flag
        
        signupFacebookButton.isHidden = !flag
        loginFacebookButton.isHidden = flag
    }
    
}

