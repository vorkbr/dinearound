//
//  RestaurantItem.swift
//  DineAround
//
//  Created by iPop on 8/11/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseStorageUI
import SDWebImage

let g_features = ["bt_booze", "bt_creditcard", "bt_freewifi",
                  "bt_reserve", "bt_wheelchair", "bt_outside"]

public enum Feature {
    static let booze = "booze"
    static let creditcard = "creditcard"
    static let freewifi = "freewifi"
    static let reserve = "reserve"
    static let wheelchair = "wheelchair"
    static let outside = "outside"
    
    public static func resource(type: String) -> String! {
        switch (type) {
        case Feature.booze:
            return "bt_booze"
        case Feature.creditcard:
            return "bt_creditcard"
        case Feature.freewifi:
            return "bt_freewifi"
        case Feature.reserve:
            return "bt_reserve"
        case Feature.wheelchair:
            return "bt_wheelchair"
        case Feature.outside:
            return "bt_outside"
        default: break
        }
        return nil
    }
    
    public static func names() -> [String] {
        return [Feature.booze, Feature.creditcard, Feature.freewifi,
                Feature.reserve, Feature.wheelchair, Feature.outside]
    }
}

public class Coupon {
    var key: Int = 0
    var name: String! = ""
    var code = 0
    var price = 0.0
    
    init(dictionary: NSDictionary, index: Int) {
        key = index
        name = dictionary.stringOrNil(forKeyPath: "name")
        code = dictionary.safeInteger(forKeyPath: "code")
        price = dictionary.safeFloat(forKeyPath: "price")
    }
}

public class Location: NSObject, NSCoding {
    
    public var locationID: Int!
    public var key: String!

    public var name: String?
    public var coordinate: CLLocationCoordinate2D
    public var distance: Double = -1
    
    public var address: String?
    public var city: String?
    public var state: String?
    public var postal: String?
    public var phone: String?
    public var website: String!

    public var cuisines: String?

    public var logoURL: String?
    public var logo: UIImage?
    public var pictureURLs: [String]?
    public var pictures: [UIImage]?
    public var menuImageURL: String?
    public var menuImage: UIImage?

    public var hours: String?
    public var entreeCost: Double!
    public var features: String?
    
    public var createAt: String?
    
    public var coupons: [Coupon]
    
    public var reviewCount: UInt = 0
    public var rating = -1.0
    
 
    init(dictionary: NSDictionary, key: String! = "key") {
        
        locationID = dictionary.safeInteger(forKeyPath: "id")
        self.key = key
        
        name = dictionary.stringOrNil(forKeyPath: "name")
        address = dictionary.stringOrNil(forKeyPath: "address")
        city = dictionary.stringOrNil(forKeyPath: "city")
        state = dictionary.stringOrNil(forKeyPath: "state")
        postal = dictionary.stringOrNil(forKeyPath: "postal")
        phone = dictionary.stringOrNil(forKeyPath: "phone")
        
        if let web = dictionary.stringOrNil(forKeyPath: "url") {
            if web.contains("https://") || web.contains("http://") {
                website = web as String!
            } else if web != "" {
                website = String(format: "http://%@", web)
            }
        }
        
        cuisines = dictionary.stringOrNil(forKeyPath: "cuisines") ?? "American"
        
        logoURL = dictionary.stringOrNil(forKeyPath: "logo_image")
       
        var urls: [String] = []
        let imgURLs = dictionary.arrayOrNil(forKey: "pictures" as NSCopying!) ?? []
        for item in imgURLs {
            if let url = item as? String {
                urls.append(url)
            }
        }
        pictureURLs = urls
        
        menuImageURL = dictionary.stringOrNil(forKeyPath: "menu_image")
        
        
        let latNum = dictionary.safeFloat(forKeyPath: "latitude")
        let lngNum = dictionary.safeFloat(forKeyPath: "longitude")
        
        if latNum == 0 || lngNum == 0 {
            coordinate = g_currentLocation
        }
        else {
            coordinate = CLLocationCoordinate2DMake(latNum, lngNum)
        }

        features = dictionary.stringOrNil(forKeyPath: "feature") ?? ""
        hours = dictionary.stringOrNil(forKeyPath: "hours") ?? ""
        entreeCost = dictionary.safeFloat(forKeyPath: "entree_cost")
        
        createAt = dictionary.stringOrNil(forKeyPath: "createAt") ?? "05-17"
        
        var cps: [Coupon] = []
        let ary = dictionary.arrayOrNil(forKey: "coupons" as NSCopying!) ?? []
        
        for item in ary {
            if let dict = item as? NSDictionary {
                let cp = Coupon(dictionary: dict, index: cps.count+1)
                cps.append(cp)
            }
        }
        coupons = cps
        
        super.init()
    }
 
    
    // Use this when adding one locally
    init(key: String!, locID: Int, name: String?, coordinate: CLLocationCoordinate2D,
         address: String?, city: String?, state: String?, postal: String?,
         phone: String?, website: String!, cuisines: String?, logoURL: String?,
         picURLs: [String]?, menuURL: String?, features: String?, hours: String?,
         entreeCost: Double!, createAt: String?, coupons: [Coupon]) {
        self.key = key
        self.locationID = locID
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.city = city
        self.state = state
        self.postal = postal
        self.website = website
        self.cuisines = cuisines
        self.logoURL = logoURL
        self.pictureURLs = picURLs
        self.menuImageURL = menuURL
        self.features = features
        self.hours = hours
        self.entreeCost = entreeCost
        self.createAt = createAt
        self.coupons = coupons
    }
    
    convenience init(snap: DataSnapshot!) {
        if let dict = snap.value as? NSDictionary {
            self.init(dictionary: dict, key: snap.key)
        }
        else {
            fatalError("blah")
        }
    }
    
    // MARK: NSCoding
    
    public convenience required init?(coder aDecoder: NSCoder) {
        //Error here "missing argument for parameter name in call
        
        let key = aDecoder.decodeObject(forKey: "key") as! String
        let locID = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        let coord = CLLocationCoordinate2DMake(latitude, longitude)
        
        let address = aDecoder.decodeObject(forKey: "address") as! String
        let city = aDecoder.decodeObject(forKey: "city") as! String
        let state = aDecoder.decodeObject(forKey: "state") as! String
        let postal = aDecoder.decodeObject(forKey: "postal") as! String
        let phone = aDecoder.decodeObject(forKey: "phone") as! String
        let website = aDecoder.decodeObject(forKey: "url") as! String
        
        let cuisines = aDecoder.decodeObject(forKey: "cuisines") as! String
        
        let logoURL = aDecoder.decodeObject(forKey: "logo_image") as! String
        let picURLs = aDecoder.decodeObject(forKey: "pictures") as! [String]
        let menuURL = aDecoder.decodeObject(forKey: "menu_image") as! String
        
        let features = aDecoder.decodeObject(forKey: "features") as! String
        let hours = aDecoder.decodeObject(forKey: "hours") as! String
        let entreeCost = aDecoder.decodeDouble(forKey: "entree_cost")
        let createAt = aDecoder.decodeObject(forKey: "createAt") as! String
        
        let coupons = aDecoder.decodeObject(forKey: "coupons") as? [Coupon] ?? []
        
        self.init(key: key, locID: locID, name: name, coordinate: coord,
                 address: address, city: city, state: state, postal: postal,
                 phone: phone, website: website, cuisines: cuisines,
                 logoURL: logoURL, picURLs: picURLs, menuURL: menuURL,
                 features: features, hours: hours, entreeCost: entreeCost,
                 createAt: createAt, coupons: coupons)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.key, forKey: "key")
        aCoder.encode(self.locationID, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        
        aCoder.encode(self.coordinate.latitude, forKey: "latitude")
        aCoder.encode(self.coordinate.longitude, forKey: "longitude")
        
        aCoder.encode(self.address, forKey: "address")
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.state, forKey: "state")
        aCoder.encode(self.postal, forKey: "postal")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.website, forKey: "url")
        
        aCoder.encode(self.cuisines, forKey: "cuisines")
        
        aCoder.encode(self.logoURL, forKey: "logo_image")
        aCoder.encode(self.pictureURLs, forKey: "pictures")
        aCoder.encode(self.menuImageURL, forKey: "menu_image")
        
        aCoder.encode(self.features, forKey: "features")
        aCoder.encode(self.hours, forKey: "hours")
        aCoder.encode(self.entreeCost, forKey: "entree_cost")
        
        aCoder.encode(self.createAt, forKey: "createAt")
        
        aCoder.encode(self.coupons, forKey: "coupons")
    }

    
    
    
    public func getLocationId() -> Int {
        return self.locationID!
    }
    
    
    // MARK: - Location
    
    public func cityStateString() -> String {
        
        let cityStr = city ?? ""
        let stateStr = state ?? ""
        
        if cityStr != "" {
            if stateStr != "" {
                return String(format: "%@, %@", cityStr, stateStr)
            }
            return cityStr
        }
        return stateStr
    }
    
    
    public func hasFeature(type: String) -> String! {
        if let feature = features {
            if feature.contains(type) {
                return Feature.resource(type: type)
            }
        }
        return nil
    }
    
    public func setLogo(toImageView: UIImageView!) {
        self.setImage(toImageView: toImageView, url: self.logoURL)
    }
    
    public func setImage(toImageView: UIImageView!, url: String!) {
        
        if let url = url {
        
            if let img = UIImage(named: url) {
                toImageView.image = img
            }
            else {
                // Reference to an image file in Firebase Storage
                let reference = Storage.storage().reference(withPath: "images/\(url)")
                
                // Placeholder image
                let placeholderImage = UIImage(named: "placeholder")
                
                // Load the image using SDWebImage
                toImageView.sd_setImage(with: reference, placeholderImage: placeholderImage)
            }
        }
        else {
            let placeholderImage = UIImage(named: "placeholder")
            toImageView.image = placeholderImage
        }
    }

    @discardableResult public func getDistanceFromCurrent() -> Double {
        
        self.distance = CLocationController.distanceMiles(from: self.coordinate)
        return self.distance
        
    }
    
    @discardableResult public func getDistance(from coord:CLLocationCoordinate2D) -> Double {
        
        self.distance = Location.getDistance(with: coordinate, and: coord)
        return self.distance
    }
    
    public class func getDistance(with coord1:CLLocationCoordinate2D, and coord2:CLLocationCoordinate2D) -> Double {
        
        let loc1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let loc2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        
        return loc1.distance(from: loc2) / meterPerMile
    }
}
