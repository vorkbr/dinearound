//
//  ApiMngr.swift
//  DineAround
//
//  Created by iPop on 8/19/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorageUI
import CoreLocation

import YelpAPI

let TEST = 0
// Fill in your app keys here from
// https://www.yelp.com/developers/v3/manage_app
let yelpAppId = "tpI4cOpFEqcGmg9A-BlJKA"
let yelpAppSecret = "cQoJGPkTfbWPGmwUTNiikwcQ9Y8Z6MTA1LKntHwUMTFadA2uAgkbARqB1ExwaVO0"


class UserInfo {
    
    public static var _shared: UserInfo! = nil
    
    public class var shared: UserInfo {
        if _shared == nil {
            _shared = UserInfo()
        }
        return _shared
    }
    
    var key: String = ""
    var name: String = ""
    var phone: String = ""
    var email: String = ""
    var password: String = ""
    var isLogin: Bool = false
    
    init() {
        self.load()
    }
    
    func setInfo(_ userInfo: UserInfo!) {
        key = userInfo.key
        name = userInfo.name
        phone = userInfo.phone
        email = userInfo.email
        password = userInfo.password
        isLogin = userInfo.isLogin
    }
    
    func empty() {
        key = ""
        name = ""
        phone = ""
        email = ""
        password = ""
        isLogin = false
    }
    
    func load() {
        let userDefaults = UserDefaults.standard
        self.key = userDefaults.object(forKey: "key") as? String ?? ""
        self.name = userDefaults.object(forKey: "name") as? String ?? ""
        self.phone = userDefaults.object(forKey: "phone") as? String ?? ""
        self.email = userDefaults.object(forKey: "email") as? String ?? ""
        self.password = userDefaults.object(forKey: "password") as? String ?? ""
        self.isLogin = userDefaults.bool(forKey: "isLogin")
    }
    
    func save() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(key, forKey: "key")
        userDefaults.set(name, forKey: "name")
        userDefaults.set(phone, forKey: "phone")
        userDefaults.set(email, forKey: "email")
        userDefaults.set(password, forKey: "password")
        userDefaults.set(isLogin, forKey: "isLogin")
        
        userDefaults.synchronize()
    }
}

class ApiManager {
    
    var verifyID: String!
    var verifyCode: String!
    
    var tempVerifyID: String = ""
    var tempVerifyCode: String = ""
    var tempPhone: String = ""
    var tempKey: String = ""
    
    var locDBRef: DatabaseReference!
    var usrDBRef: DatabaseReference!
    var purDBRef: DatabaseReference!
    
    //
    var locationArray: [Location] = []
    var purchaseArray: [Purchase] = []
    
    static var _shared: ApiManager! = nil
    
    class var shared: ApiManager {
        if _shared == nil {
            _shared = ApiManager()
        }
        return _shared
    }
    
    init() {
        locDBRef = Database.database().reference(withPath: "locations")
        usrDBRef = Database.database().reference(withPath: "users")
        purDBRef = Database.database().reference(withPath: "purchases")
        self.load()
    }
    
    func load() {
        let userDefaults = UserDefaults.standard
        self.verifyID = userDefaults.object(forKey: "authID") as? String ?? ""
        self.verifyCode = userDefaults.object(forKey: "authCode") as? String ?? ""
    }
    
    func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(verifyID, forKey: "authID")
        userDefaults.set(verifyCode, forKey: "authCode")
        userDefaults.synchronize()
    }
    
    func userSignup(userInfo: UserInfo! = nil, completion: @escaping (String!)->()) {
        
        let info = userInfo ?? UserInfo.shared
        
        self.userSignup(phoneNumber: info.phone, name: info.name, email: info.email, password: info.password, completion: completion)
    }
    
    func userSignup(phoneNumber: String!, name: String!, email: String!, password: String!, completion: @escaping (String!)->()) {
//        if self.verifyID != nil && self.verifyID != "" {
//            completion(self.verifyID)
//            return
//        }
        userSignOut()
        
        let phone0 = makePhone(number: phoneNumber)
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phone0) { (verificationID, error) in
            if error != nil {
                print("\(String(describing: error))")
                completion(nil)
                return
            }
            
            print("\(String(describing: verificationID))")
            
            self.verifyID = verificationID
            self.save()
            
            completion(verificationID)
            return
        }
    }
    
    func userCredential(code: String!, completion: @escaping (String!)->()) {
        let phoneAuth = PhoneAuthProvider.provider().credential(withVerificationID: verifyID, verificationCode: code)
        
        Auth.auth().signIn(with: phoneAuth) { (user, error) in
            if error != nil {
                print("\(error!.localizedDescription)")
                completion(error!.localizedDescription)
                return
            }
            self.verifyCode = code
            self.save()
            
            self.saveUserInfo(user: user)
            UserInfo.shared.isLogin = true
            UserInfo.shared.save()
            
            completion(nil)
        }
    }
    
    func userLogin(phoneNumber: String!, password: String!, completion: @escaping (Int)->()) {
        self.usrDBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children {
                if let snap = item as? DataSnapshot,
                    let dict = snap.value as? NSDictionary {
                    print("\(dict)")
                    let phone = dict.value(forKey: "phone") as? String ?? ""
                    let pass = dict.value(forKey: "password") as? String ?? ""
                
                    print("\(phone) - \(pass)")
                    
                    if phoneNumber == phone && password == pass {
                        
                        print("equals")
                    
                        let userInfo = UserInfo.shared
                        
                        userInfo.key = snap.key
                        userInfo.phone = phone
                        userInfo.password = pass
                        userInfo.name = dict.value(forKey: "name") as? String ?? ""
                        userInfo.email = dict.value(forKey: "email") as? String ?? ""
                        userInfo.isLogin = true
                        
                        userInfo.save()
                        
                        completion(0)
                        return
                    }
                }
            }
            completion(-1)
        }) { (error) in
            print(error.localizedDescription)
            completion(-2)
        }
    }
    
    func userSignOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func userChange(oldPassword: String!, toNewPassword newPass: String!, completion: @escaping (Int)->()) {

        let userInfo = UserInfo.shared
        
        if (userInfo.password != oldPassword) {
            completion(-1)
            return
        }
        
        if userInfo.key != "" {
            if let pass = newPass {
                
                self.usrDBRef.child(userInfo.key).child("password").setValue(pass, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        completion(-2)
                        return
                    }
                    userInfo.password = newPass
                    userInfo.save()
                    
                    completion(0)
                })
            }
        }
    }
    
    func userChangePhoneNumber(_ newPhone: String!, completion: @escaping (Int)->()) {
        
        let userInfo = UserInfo.shared
        
        if (userInfo.phone == newPhone) {
            completion(-1)
            return
        }
        
        self.usrDBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children {
                if let snap = item as? DataSnapshot,
                    let dict = snap.value as? NSDictionary {
                    print("\(dict)")
                    let itemPhone = dict.value(forKey: "phone") as? String ?? ""
                    
                    if itemPhone == newPhone {
                        completion(-2)
                        return
                    }
                }
            }
            
            self.tempKey = userInfo.key
            self.tempPhone = newPhone
            
            if TEST == 1 {
                completion(0)
                return
            }
            
            let phone0 = self.makePhone(number: newPhone)
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phone0) { (verificationID, error) in
                if error != nil {
                    print("\(String(describing: error))")
                    completion(-5)
                    return
                }
                
                self.tempVerifyID = verificationID!
                completion(0)
            }
        })
    }
    
    func userChangeConfirm(code: String!, completion: @escaping (String!)->()) {
        
        let userInfo = UserInfo.shared
        
        if TEST == 1 {
            self.usrDBRef.child(self.tempKey).child("phone").setValue(self.tempPhone, withCompletionBlock: { (error, ref) in
                if error != nil {
                    completion("Failed to change phone number")
                    return
                }
                userInfo.phone = self.tempPhone
                userInfo.save()
                
                completion(nil)
            })
            return
        }
        
        let phoneAuth = PhoneAuthProvider.provider().credential(withVerificationID: tempVerifyID, verificationCode: code)
        
        Auth.auth().signIn(with: phoneAuth) { (user, error) in
            if error != nil {
                print("\(error!.localizedDescription)")
                completion(error!.localizedDescription)
                return
            }
            self.tempVerifyCode = code
            
            self.usrDBRef.child(self.tempKey).child("phone").setValue(self.tempPhone, withCompletionBlock: { (error, ref) in
                if error != nil {
                    completion("Failed to change phone number")
                    return
                }
                userInfo.phone = self.tempPhone
                userInfo.save()
                
                completion(nil)
            })
        }
 
    }
    
    
    func requestPhone(phoneNumber: String!, completion: @escaping (Int)->()) {
        self.userSignOut()
        
        self.usrDBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children {
                if let snap = item as? DataSnapshot {
                    if let dict = snap.value as? NSDictionary {
                        print("\(dict)")
                        let phone = dict.value(forKey: "phone") as? String ?? ""
                        
                        print("\(phone)")
                        
                        if phoneNumber == phone {
                            
                            self.tempKey = snap.key
                            self.tempPhone = phoneNumber
                            
                            if TEST == 1 {
                                print("exist")
                                completion(0)
                                return
                            }

                            let phone0 = self.makePhone(number: phoneNumber)
                            
                            PhoneAuthProvider.provider().verifyPhoneNumber(phone0) { (verificationID, error) in
                                if error != nil {
                                    print("\(String(describing: error))")
                                    completion(-2)
                                    return
                                }
                                
                                self.tempVerifyID = verificationID!
                                completion(0)
                            }
                            return
                        }
                    }
                }
            }
            completion(-1)
        }) { (error) in
            print(error.localizedDescription)
            completion(-2)
        }
    }

    func tempCredential(code: String!, completion: @escaping (String!)->()) {
        
        if TEST == 1 {
            completion(nil)
            return
        }
        
        let phoneAuth = PhoneAuthProvider.provider().credential(withVerificationID: tempVerifyID, verificationCode: code)
        
        Auth.auth().signIn(with: phoneAuth) { (user, error) in
            if error != nil {
                print("\(error!.localizedDescription)")
                completion(error!.localizedDescription)
                return
            }
            self.tempVerifyCode = code
            
            completion(nil)
        }
    }
    
    
    func resetPassword(_ newPass: String!, completion: @escaping (Int)->()) {
        
        if let pass = newPass {
            self.usrDBRef.child(self.tempKey).child("password").setValue(pass, withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    completion(-2)
                    return
                }
                
                completion(0)
            })
        }
    }
    
    func getLocations(completion: @escaping ([Location]!)->()) {
        self.locDBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var locArray = [Location]()
            for item in snapshot.children {
                if let snap = item as? DataSnapshot {
                    let loc = Location(snap: snap)
                    
                    self.getReview(from: loc)
                    
                    locArray.append(loc)
                }
            }
            self.locationArray = locArray
            completion(locArray)
            
        }) { (error) in
            print(error.localizedDescription)
            self.locationArray = []
            completion(nil)
        }
    }
    
    func getPurchases(completion: @escaping ([Purchase]!)->()) {
        self.purDBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var purArray = [Purchase]()
            for item in snapshot.children {
                if let snap = item as? DataSnapshot {
                    let pur = Purchase(snap: snap)
                    
                    let res = self.locationArray.filter({$0.key == pur.locationKey})
                    if res.count > 0 {
                        pur.location = res[0]
                    }
                    purArray.append(pur)
                }
            }
            self.purchaseArray = purArray
            completion(purArray)
            
        }) { (error) in
            print(error.localizedDescription)
            self.purchaseArray = []
            completion(nil)
        }
    }
    
    func getPurchases(fromLocationKey locKey: String!) -> [Purchase]! {
        let filters = purchaseArray.filter({$0.locationKey == locKey})
        return filters
    }
    
    func getPurchases(fromLocationId locId: Int) -> [Purchase]! {
        let filters = purchaseArray.filter({$0.locationId == locId})
        return filters
    }
    
    func getPurchases(fromUserPhone phone: String!) -> [Purchase]! {
        let filters = purchaseArray.filter({$0.userPhone == phone})
        return filters
    }
    
    func getPurchases(fromLocation locKey: String!, andUser userKey: String!) -> [Purchase]! {
        if let locKey = locKey {
            if let userKey = userKey {
                let filters = purchaseArray.filter({$0.locationKey == locKey && $0.userKey == userKey})
                return filters
            }
            else {
                let filters = purchaseArray.filter({$0.locationKey == locKey})
                return filters
            }
        }
        else {
            if let userKey = userKey {
                let filters = purchaseArray.filter({$0.userKey == userKey})
                return filters
            }
        }
        return purchaseArray
    }
    
    
    func putPurchases(_ location: Location, entree: Int, completion: ((Bool)->())?) {
        if entree < 0 || entree > 1 { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy HH:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateString = dateFormatter.string(from: Date())
        
        let coupon = location.coupons[entree]
        
        let item: NSDictionary = [
            "locationId": NSNumber(value: location.getLocationId()),
            "locationKey": location.key!,
            "locationName": location.name ?? "restaurant",
            "couponIndex": entree+1,
            "couponName": coupon.name!,
            "couponPrice": coupon.price,
            "userKey": UserInfo.shared.key,
            "userPhone": UserInfo.shared.phone,
            "date": dateString
        ]
        
        self.purDBRef.childByAutoId().setValue(item, withCompletionBlock: { (error, dbRef) in
            if error != nil {
                if let completion = completion {
                    completion(true)
                }
            }
            if let completion = completion {
                completion(true)
            }
        })
    }
    
    func getReview(from location: Location!, completion: ((Bool)->())? = nil) {
        YLPClient.authorize(withAppId: yelpAppId, secret: yelpAppSecret) { (ylpClient, error) in
            if error != nil {
                if let completion = completion {
                    completion(false)
                }
            }
            
            if let client = ylpClient {
                let coord = YLPCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                client.search(with: coord, term: "food,restaurants", limit: 8, offset: 0, sort: .distance, completionHandler: { (ylpSearch, error) in
                    if error != nil {
                        if let completion = completion {
                            completion(false)
                        }
                    }
                    
                    if let search = ylpSearch {
                        
                        let result = search.businesses.sorted(by: { (item1, item2) -> Bool in
                          
                            let coord1 = CLLocationCoordinate2DMake((item1.location.coordinate?.latitude)!, (item1.location.coordinate?.longitude)!)
                            let coord2 = CLLocationCoordinate2DMake((item2.location.coordinate?.latitude)!, (item2.location.coordinate?.longitude)!)
                            
                            let dist1 = Location.getDistance(with: location.coordinate, and: coord1)
                            let dist2 = Location.getDistance(with: location.coordinate, and: coord2)
                            
                            return dist1 < dist2
                        })
                        
                        var found = false
                        for item in result {
                            print("----------------------------")
                            print("\(item.identifier) | \(item.name) | \(String(describing: item.phone)) | \(item.rating) | \(item.reviewCount)")
                            print("\(item.location.countryCode) | \(item.location.stateCode) | \(item.location.city) | \(item.location.postalCode) | \(item.location.address) | { \(String(describing: item.location.coordinate?.latitude)), \(String(describing: item.location.coordinate?.longitude)) }")

                            for cat in item.categories {
                                print("\(cat.name) - \(cat.alias)")
                            }
                            
                            let coord = CLLocationCoordinate2DMake((item.location.coordinate?.latitude)!, (item.location.coordinate?.longitude)!)
                            let dist = Location.getDistance(with: location.coordinate, and: coord)
                            
                            print("dist = \(dist)")
                            
                            if let address = location.address {
                                for addr in item.location.address {
                                    if address.lowercased().contains(addr.lowercased()) {
                                        found = true
                                        break
                                    }
                                }
                            }
                            
                            if found {
                                location.rating = item.rating
                                location.reviewCount = item.reviewCount
                                
                                if let completion = completion {
                                    completion(true)
                                }
                                
                                return
                            }
                            
                        }
                        if let completion = completion {
                            completion(false)
                        }
                    }
                })
            }
        }
    }
    
    // send SMS to phone number by using Twilio, 
    // if account is trial mode, To Phone number should be registered
    func sendSMS(_ message: String, toPhone phone:String) {
        // Use your own details here
        let twilioSID = "AC3fcc607107454e5cf37392a4779a2cf0"// "ACc5fc824ee404150440c5934b9d06788c"
        let twilioSecret = "bc3342b95441ab516c6367487fa2fda8" //"a79add6c57db0b0fd17b7a9ba95ab014"
        let fromNumber = "+14437374399" // "%2B15005550006"
        
        let phone0 = self.makePhone(number: phone)
        
        // Build the request
        let surl = "https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/Messages"
        let sbody = "From=\(fromNumber)&To=\(phone0)&Body=\(message)"
        var request = URLRequest(url: URL(string: surl)!)
        request.httpMethod = "POST"
        request.httpBody = sbody.data(using: .utf8)
        
        // Build the completion block and send the request
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            print("Finished")
            if let error = error {
                print("Error: \(error)")
            }
            else {
                if let data = data, let details = String(data: data, encoding: .utf8) {
                    // Success
                    print("Response: \(details)")
                } else {
                    print("Error: data invalid")
                }
            }
        }).resume()
    }
    
    // save User into firebase
    func saveUserInfo(user: User!) {
        
        if let user = user {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let dateString = dateFormatter.string(from: Date())
            
            let userInfo = UserInfo.shared
            userInfo.key = user.uid
            
            let newUser = [
                "phone": userInfo.phone,
                "name": userInfo.name,
                "email": userInfo.email,
                "provider": user.providerID,
                "password": userInfo.password,
                "createdAt": dateString
            ]
            
            self.usrDBRef.child(user.uid).setValue(newUser)
            
        }
        else {
            print("user is nil")
        }

    }

    // add +1 if phone has not county code.
    func makePhone(number: String!) -> String {
        var phone0 = number ?? ""
        if phone0.contains("+") == false {
            phone0 = "+1\(phone0)"
        }
        return phone0
    }
}
