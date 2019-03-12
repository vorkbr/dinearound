//
//  MainListVC.swift
//  DineAround
//
//  Created by iPop on 8/5/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

extension UIViewController {
    var app:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var localData: UserDefaults {
        return UserDefaults.standard
    }
    
    func showAlert(title: String!, message: String!, withField field:UITextField! = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let field = field {
                field.updateFocusIfNeeded()
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}

class FilterItem {
    var selectedType = 1
    var searchText: String! = ""
    var isCurrentLocation : Bool = false
    var locationAddress: String! = ""
    var filterOption = 0 // 1 : visited, 2: never been
    var features: [Int] = [0, 0, 0, 0, 0, 0]
    
    func hasFeatures(_ featureString: String!) -> Bool {
        var idx = 0
        for item in Feature.names() {
            if features[idx] == 1 {
                if featureString.contains(item) == false {
                    return false
                }
            }
            idx += 1
        }
        return true
    }
    
    func isFeatures() -> Bool {
        for item in features {
            if item != 0 {
                return true
            }
        }
        return false
    }
    
    func hasFilter() -> Bool {
        return selectedType != 1 || searchText != "" || isCurrentLocation == true || filterOption != 0 || isFeatures() //|| locationAddress != ""
    }
    
    func processFilter(_ locations: [Location]! = nil) -> [Location]! {
        var filterArray: [Location]! = nil
        
        let locations = locations ?? ApiManager.shared.locationArray
        
        if !hasFilter() {
            return locations
        }
        
        // first stage
        if selectedType > 1 {
            let typeStr = cuisineTextArray[selectedType-1].uppercased()
            if searchText != "" {
                filterArray = locations.filter { $0.cuisines?.uppercased().contains(typeStr) == true && $0.name?.lowercased().contains(searchText.lowercased()) == true }
            }
            else {
                filterArray = locations.filter { $0.cuisines?.uppercased().contains(typeStr) == true }
            }
        }
        else {
            if searchText != "" {
                filterArray = locations.filter { $0.name?.lowercased().contains(searchText.lowercased()) == true }
            }
            else {
                filterArray = locations
            }
        }
        
        // second stage
        if filterOption != 0 {
            
            if filterOption == 1 {
                filterArray = filterArray.filter({ (location) -> Bool in
                    
                    let res = ApiManager.shared.getPurchases(fromLocation: location.key, andUser: UserInfo.shared.key) ?? []
                    
                    return res.count > 0
                })
            }
            else {
                filterArray = filterArray.filter({ (location) -> Bool in
                        
                    let res = ApiManager.shared.getPurchases(fromLocation: location.key, andUser: UserInfo.shared.key) ?? []
                    
                    return res.count == 0
                })
            }
        }
        
        if isCurrentLocation == true {
            if !CLocationController.shared.loctionUnknown {
                for item in filterArray {
                    item.getDistanceFromCurrent()
                }
                
                filterArray.sort(by: {$0.distance < $1.distance})
            }
        }
        else {
            if locationAddress != "" {
                // get coordinate from location string
            }
        }
        
        // feature filter
        
        if isFeatures() {
            filterArray = filterArray.filter({ self.hasFeatures($0.features) })
        }
        
        return filterArray
    }
}

class MainListVC: UIViewController {
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cuisineScrollView: UIScrollView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var locationSwitch: BigSwitch!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var visitCheckButton: UIButton!
    @IBOutlet weak var visitContainView: BorderView!
    @IBOutlet weak var visitedImgView: UIImageView!
    @IBOutlet weak var neverBeenImgView: UIImageView!
    
    @IBOutlet var featureButtons: [CheckButton]!
    
    var filterArray: [Location] = []
    
    var filterItem = FilterItem()
    
    var isLoadDB = false
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if g_isFirst == false {
            self.performSegue(withIdentifier: "present", sender: self)
        }
        else {
            self.loadFromServer()
        }
        
        self.createCuisineButton()
        
        self.initFilterScreen()
        
        searchBar.isHidden = true
        
        visitContainView.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "ANN ARBOR"
        if g_isFirst == true && isLoadDB == false {
            self.loadFromServer()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            navigationItem.title = ""
            if let loc = sender as? Location, let detailVC = segue.destination as? DetailVC {
                
                detailVC.restaurant = loc
            }
        }
    }
    
    func loadFromServer() {
        if self.isLoadDB == true {
            return
        }
        self.isLoadDB = true
        SwiftLoader.show(title: "Fetching data from server...", animated: true)
        
        ApiManager.shared.getLocations { (locArray) in
            
            if let locArray = locArray {
                self.filterArray = locArray
            }
            else {
                self.isLoadDB = false
            }

            ApiManager.shared.getPurchases(completion: { (purArray) in
                
                self.tableView.reloadData()
                SwiftLoader.hide()
            })
            
            //self.testLocation()
        }
    }
    
    func testLocation() {
        
        let dictArray: [[String:Any?]] = [
            ["key":"locations1", "id": "1", "name": "Spencer", "latitude":"42.279728", "longitude":"-83.747866", "address": "113 E Liberty St", "city":"Ann Arbor", "state":"MI", "postal":"48104", "cuisines": "American, Cheese", "phone":"(734) 369-3979", "url":"spencerannarbor.com",  "logo": "loc_logo", "pictures":["loc_img1", "loc_img2", "loc_img3"], "menu_image": "location_menu", "hours": "Mon\t11:00 am - 3:00 pm, 5:00 pm - 10:00 pm\nTue\tClosed\nWed\t11:00 am - 3:00 pm, 5:00 pm - 10:00 pm\nThu\t:00 am - 3:00 pm, 5:00 pm - 10:00 pm\nFri\t11:00 am - 3:00 pm, 5:00 pm - 11:00 pm\nSat\t:00 am - 3:00 pm, 5:00 pm - 11:00 pm\nSun\t11:00 am - 3:00 pm, 5:00 pm - 10:00 pm\n", "entree_cost": "30", "feature":"creditcard,wheelchair"],
            
            ["key":"locations2", "id": "2", "name": "Tmaz Taqueria", "latitude":"42.279728", "longitude":"-83.747866", "address": "3182 Packard St", "city":"Ann Arbor", "state":"MI",  "postal": "48108", "cuisines": "Mexican", "phone":"(734) 477-6089", "url":"taqueriatmaz.com",  "logo": "res1", "pictures":["res_info1", "res_info3", "res_info4"], "menu_image": "res_info2", "hours": "Mon\t11:00 am - 11:00 pm\nTue\t11:00 am - 11:00 pm\nWed\t11:00 am - 11:00 pm\nThu\t11:00 am - 11:00 pm\nFri\t4:00 pm - 11:00 pm\nSat\t11:00 am - 11:00 pm\nSun\tClosed", "entree_cost": "20"],
            
            ["key":"locations3", "id": "3", "name": "Once-Upon A Grill", "latitude":"42.279728", "longitude":"-83.747866", "address": "3148 Packard Rd", "city":"Ann Arbor", "state":"MI",  "postal": "48108", "cuisines": "Indian", "phone":"(734) 997-5277", "url":"",  "logo": "Once1", "pictures":["res_info1", "res_info3", "res_info4"], "menu_image": "menu2", "hours": "Mon\t11:00 am - 11:00 pm\nTue\t11:00 am - 11:00 pm\nWed\t11:00 am - 11:00 pm\nThu\t11:00 am - 11:00 pm\nFri\t4:00 pm - 11:00 pm\nSat\t11:00 am - 11:00 pm\nSun\t11:00 am - 11:00 pm", "entree_cost": "10"],
            
            ["key":"locations4", "id": "4", "name": "Mani Osteria & Bar", "latitude":"42.279728", "longitude":"-83.747866", "address": "341 E Liberty St", "city":"Ann Arbor", "state":"MI",  "postal": "48104", "cuisines": "Italian", "phone":"(734) 769-6700", "url":"maniosteria.com",  "logo": "mani_logo", "pictures":["res_info1", "res_info3", "res_info4"], "menu_image": "menu1", "hours": "Mon\tClosed\nTue\t11:30 am - 10:00 pm\nWed\t11:30 am - 10:00 pm\nThu\t11:30 am - 10:00 pm\nFri\t11:30 am - 11:00 pm\nSat\t12:00 pm - 11:00 pm\nSun\t11:00 am - 2:30 pm\n\t\t4:00 pm - 9:00 pm", "entree_cost": "20"]
            ]
        
        for dict in dictArray {
            let location = Location(dictionary: dict as NSDictionary)
            //locations.append(location)
        }
        
    }
    
    
    
    func createCuisineButton() {
        var x: CGFloat = 0
        var rect = CGRect(x: 0, y: 0, width: 120, height: 40)
        var tag = 1
        for titleStr in cuisineTextArray {
            
            rect.origin.x = x
            
            let button = UIButton(type: .custom)
            
            button.setTitle(titleStr.uppercased(), for: .normal)
            button.titleLabel?.font = UIFont(name: "Comfortaa-Bold", size: 16)
            
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitleColor(UIColor.orange1, for: .selected)
            
            button.frame = rect
            button.addTarget(self, action: #selector(self.actionCuisine(_:)), for: .touchUpInside)
            
            if tag == filterItem.selectedType {
                button.isSelected = true
            }
            
            button.tag = tag
            
            cuisineScrollView.addSubview(button)
            
            x += 128
            tag += 1
        }
        
        cuisineScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: x)
        
    }
    
    // MARK: - Action
    
    @IBAction func actionCuisine(_ sender: UIButton) {
        if sender.tag == filterItem.selectedType {
            return
        }
        if let oldButton = cuisineScrollView.viewWithTag(filterItem.selectedType) as? UIButton {
            oldButton.isSelected = false
        }
        filterItem.selectedType = sender.tag
        sender.isSelected = true
        
        self.filterArray = filterItem.processFilter()
        
        self.tableView.reloadData()
    }

    @IBAction func actionPrev(_ sender: UIButton) {
        
    }
    
    @IBAction func actionNext(_ sender: UIButton) {
    }
    
    @IBAction func actionFilter(_ sender: UIBarButtonItem) {
        
        if filterView.isHidden == true {
            
            sender.isEnabled = false
            var rect : CGRect = filterView.frame
            rect.origin.y = g_winSize.height
            filterView.frame = rect
            
            filterView.isHidden = false
            
            let y0 = g_winSize.height * 0.25 - 50
            
            UIView.animate(withDuration: 0.5, delay: 0.05, options: [.curveEaseOut], animations: {
            
                rect.origin.y = y0
                self.filterView.frame = rect
            }, completion: {_ in
               sender.isEnabled = true
            })
        }
    }
    
    @IBAction func actionSearch(_ sender: UIBarButtonItem) {
        searchBar.text = ""
        searchBar.isHidden = !searchBar.isHidden
    }
    
    // MARK: - Filter Screen
    
    func initFilterScreen() {
        filterView.isHidden = true

        visitedImgView.isHidden = true
        neverBeenImgView.isHidden = true
    }

    
    @IBAction func actionFilterCancel(_ sender: UIButton) {
        if filterView.isHidden == false {
            
            sender.isEnabled = false

            filterItem.isCurrentLocation = false
            filterItem.locationAddress = ""
            filterItem.filterOption = 0
            for idx in 0..<6 {
                filterItem.features[idx] = 0
            }
            
            var rect : CGRect = filterView.frame
            
            let y0 = g_winSize.height
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut], animations: {
                
                rect.origin.y = y0
                self.filterView.frame = rect
            }, completion: {_ in
                self.filterView.isHidden = true
                sender.isEnabled = true
                
                DispatchQueue.main.async {
                    self.locationSwitch.isOn = false
                    self.locationField.text = ""
                    
                    self.visitCheckButton.isSelected = false
                    self.visitedImgView.isHidden = true
                    self.neverBeenImgView.isHidden = true
                    for btn in self.featureButtons {
                        btn.isSelected = false
                    }
                    
                    if UserInfo.shared.isLogin {
                        SwiftLoader.show(animated: true)
                        self.filterArray = self.filterItem.processFilter()
                        self.tableView.reloadData()
                        SwiftLoader.hide()
                    }
                }
            })
        }
    }
    
    @IBAction func actionFilterDone(_ sender: UIButton) {
        
        if filterView.isHidden == false {
            
            if !UserInfo.shared.isLogin {
                self.showAlert(title: "", message: "You should login to filter items!")
                return
            }
            
            // check if user logged in
            if UserInfo.shared.isLogin {
                filterItem.isCurrentLocation = self.locationSwitch.isOn
                if filterItem.isCurrentLocation == true {
                    filterItem.locationAddress = ""
                }
                else {
                    filterItem.locationAddress = self.locationField.text
                }
                
                filterItem.filterOption = 0
                
                if self.visitCheckButton.isSelected == true {
                    if !self.visitedImgView.isHidden {
                        filterItem.filterOption = 1
                    }
                    else if !self.neverBeenImgView.isHidden {
                        filterItem.filterOption = 2
                    }
                }
                
                var idx = 0
                for btn in self.featureButtons {
                    filterItem.features[idx] = btn.isSelected ? 1 : 0
                    idx += 1
                }
            }
            
            sender.isEnabled = false
            var rect : CGRect = filterView.frame
            
            let y0 = g_winSize.height
            
            UIView.animate(withDuration: 0.5, delay: 0.05, options: [.curveEaseOut], animations: {
                
                rect.origin.y = y0
                self.filterView.frame = rect
            }, completion: {_ in
                self.filterView.isHidden = true
                sender.isEnabled = true
                
                DispatchQueue.main.async {
                    SwiftLoader.show(animated: true)
                    self.filterArray = self.filterItem.processFilter()
                    self.tableView.reloadData()
                    SwiftLoader.hide()
                }
            })
        }
        
    }
    
    @IBAction func actionCheckFilter(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        visitContainView.isUserInteractionEnabled = sender.isSelected
    }
    
    @IBAction func actionFilterVisited(_ sender: UIButton) {
        visitedImgView.isHidden = false
        neverBeenImgView.isHidden = true
    }
    
    @IBAction func actionFilterNeverBeen(_ sender: UIButton) {
        visitedImgView.isHidden = true
        neverBeenImgView.isHidden = false
    }
    
    @IBAction func actionFilterFeatures(_ sender: CheckButton) {
        sender.isSelected = !sender.isSelected
    }
    
}

extension MainListVC: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
}

extension MainListVC: UITableViewDataSource {
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MainViewCell.reuseIdentifier(), for: indexPath) as! MainViewCell
        
        cell.tag = indexPath.row
        cell.location = filterArray[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    
}

extension MainListVC: ViewCellDelegate {
    func openView(_ index: Int) {
        self.performSegue(withIdentifier: "showDetail", sender: filterArray[index])
    }
}

extension MainListVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterItem.searchText = searchText
        
        self.filterArray = filterItem.processFilter()
        
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        
        if filterItem.searchText != "" {
            filterItem.searchText = ""
            
            self.filterArray = filterItem.processFilter()
            self.tableView.reloadData()
        }
        
        searchBar.isHidden = !searchBar.isHidden
    }
    

}
