//
//  Purchase.swift
//  DineAround
//
//  Created by iPop on 8/30/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import Foundation
import Firebase

class Purchase: NSObject {
    var key: String! = ""
    var locationKey : String! = ""
    var locationId : Int = 0
    var locationName: String! = ""
    var couponIndex: Int = 0
    var couponName: String! = ""
    var couponPrice: Double = 0.0
    var userKey : String! = ""
    var userPhone: String! = ""
    
    var dateStr: String! = ""
    
    var date = Date()
    var location: Location! = nil
    
    init(dictionary: NSDictionary, key: String! = "key") {
        
        self.key = key
        
        self.locationKey = dictionary.stringOrNil(forKeyPath: "locationKey") ?? ""
        self.locationId = dictionary.safeInteger(forKeyPath: "locationId")
        self.locationName = dictionary.stringOrNil(forKeyPath: "locationName") ?? ""
        
        self.couponIndex = dictionary.safeInteger(forKeyPath: "couponIndex")
        self.couponPrice = dictionary.safeFloat(forKeyPath: "couponPrice")
        self.couponName = dictionary.stringOrNil(forKeyPath: "couponName") ?? ""
        
        self.userKey = dictionary.stringOrNil(forKeyPath: "userKey") ?? ""
        self.userPhone = dictionary.stringOrNil(forKeyPath: "userPhone") ?? ""
        
        self.dateStr = dictionary.stringOrNil(forKeyPath: "date") ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        self.date = dateFormatter.date(from: self.dateStr) ?? Date()
        
        super.init()
    }
    
    
    // Use this when adding one locally
    init(key: String!, locKey: String!, locId: Int, locName: String!, cIndex: Int, cPrice: Double, cName: String!, userKey: String!, phone: String!, dateStr: String!) {
        
        self.key = key
        self.locationKey = locKey
        self.locationId = locId
        self.locationName = locName
        
        self.couponIndex = cIndex
        self.couponPrice = cPrice
        self.couponName = cName
        
        self.userKey = userKey
        self.userPhone = phone

        self.dateStr = dateStr
    }
    
    convenience init(snap: DataSnapshot!) {
        if let dict = snap.value as? NSDictionary {
            self.init(dictionary: dict, key: snap.key)
        }
        else {
            fatalError("blah")
        }
    }
}
