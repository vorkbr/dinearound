//
//  ProfileVC.swift
//  DineAround
//
//  Created by iPop on 8/5/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var sinceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedType = 1
    
    var purchases: [Purchase] = []
    
    //
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var tabView1: UIView!
    @IBOutlet weak var tabView2: UIView!
    
    @IBOutlet weak var loginPhoneButton: UIButton!
    @IBOutlet weak var signupPhoneButton: UIButton!
    
    var tabIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceLabel.text = "$0.0"
        //self.testLocation()

        selectTab(index: 1)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profileView.isHidden = !UserInfo.shared.isLogin
        registerView.isHidden = UserInfo.shared.isLogin
        
        if UserInfo.shared.isLogin {
            nameLabel.text = UserInfo.shared.name
            phoneLabel.text = UserInfo.shared.phone
            
            DispatchQueue.main.async {
                self.getPurchaseInfo()
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        loginPhoneButton.makeRound()
        signupPhoneButton.makeRound()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            navigationItem.title = ""
            if let pur = sender as? Purchase, let loc = pur.location, let detailVC = segue.destination as? DetailVC {
                
                detailVC.restaurant = loc
            }
        }
    }
    
    // MARK: -
    
    func testLocation() {
        
        let dictArray: [[String:Any?]] = [
            ["id": "1", "name": "the oxford", "address": "Venue St. 29, Ann Arbor", "cuisine_types": [["name": "Chinese"]], "logo": "res1", "photos":[["url": "res_info1"], ["url": "res_info2"], ["url": "res_info3"], ["url": "res_info4"]]],
            ["id": "2", "name": "spice art", "address": "Spice St. 31, Ann Arbor", "cuisine_types": [["name": "Indian"]], "logo": "res2", "photos":[["url": "res_info3"], ["url": "res_info1"], ["url": "res_info4"], ["url": "res_info2"]]],
            ["id": "3", "name": "peumuht", "address": "Pensil Rd. 12, Ann Arbor", "cuisine_types": [["name": "Italian"]], "logo": "res3", "photos":[["url": "res_info4"], ["url": "res_info3"], ["url": "res_info1"], ["url": "res_info1"]]]
        ]
        
        //locations = []
        
        for dict in dictArray {
            let location = Location(dictionary: dict as NSDictionary)
            //locations.append(location)
        }
        
    }
    
    func getPurchaseInfo() {
        SwiftLoader.show(animated: true)
        
        ApiManager.shared.getPurchases(completion: { (purchases) in
  
            var purArray: [Purchase] = []
            
            let resAry = ApiManager.shared.getPurchases(fromLocation: nil, andUser: UserInfo.shared.key) ?? []
            
            var price = 0.0
            for pur in resAry {
                if pur.location != nil {
                    price += pur.couponPrice
                    
                    if purArray.filter({$0.locationKey == pur.locationKey}).count == 0 {
                        purArray.append(pur)
                    }
                }
                else {
                    print("not exist [\(pur.locationKey)]")
                }
            }
            self.purchases = purArray
            
            DispatchQueue.main.async {
                self.priceLabel.text = String.init(format: "$%0.1f", price)
                self.tableView.reloadData()
                SwiftLoader.hide()
            }
        })
    }
    
    // MARK: - Register View
    
    
    @IBAction func actionSelectTab(_ sender: UIButton) {
        if sender.tag == 20 { // signup
            if tabIndex == 1 {
                tabIndex = 0
                selectTab(index: 0)
            }
        }
        else {
            if tabIndex == 0 {
                tabIndex = 1
                selectTab(index: 1)
            }
        }
    }
    
    @IBAction func actionSignup(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showSignup", sender: self)
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    
    // MARK: -
    
    func selectTab(index: Int) {
        
        let flag: Bool = (index == 0)
        
        tabView1.isHidden = !flag
        tabView2.isHidden = flag
        
        signupPhoneButton.isHidden = !flag
        loginPhoneButton.isHidden = flag
    }
    

}

extension ProfileVC: ViewCellDelegate {
    func openView(_ index: Int) {
        self.performSegue(withIdentifier: "showDetail", sender: purchases[index])
    }
}

extension ProfileVC: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
}

extension ProfileVC: UITableViewDataSource {
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchases.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitedCell.reuseIdentifier(), for: indexPath) as! VisitedCell
        
        cell.tag = indexPath.row
        cell.purchase = purchases[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    
}

