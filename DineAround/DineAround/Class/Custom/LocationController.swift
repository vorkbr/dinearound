//
//  LocationController.swift
//  DineAround
//
//  Created by iPop on 8/30/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import CoreLocation

let meterPerMile = 1609.344

class CLocationController: NSObject {
    
    var locationManager: CLLocationManager!
    
    var tmpCurrentLocation: CLLocation!
    
    var started: Bool = false
    
    var currentLocation: CLLocation!
    var lastLocation: CLLocation!
    
    var loctionUnknown: Bool {
        return currentLocation == nil
    }
    
    public static var _shared: CLocationController! = nil
    
    public class var shared: CLocationController {
        if _shared == nil {
            _shared = CLocationController()
        }
        return _shared
    }
    
    
    override init() {

        super.init()
        
        self.currentLocation = nil
        self.lastLocation = nil
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
    }
    
    public class func distanceMiles(from location:CLLocationCoordinate2D) -> Double {
        if let currLoc = CLocationController.shared.currentLocation {
            let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            return currLoc.distance(from: loc) / meterPerMile
        }
        else {
            return -1
        }
    }
    
    func start() {
        if (self.started) {
            return
        }
    
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        DispatchQueue.main.async {
            self.started = true
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stop() {
        DispatchQueue.main.async {
            self.locationManager.stopUpdatingLocation()
            self.started = false
        }
    }

    
    func resetLocation() {
        self.currentLocation = nil
    }
}

extension CLocationController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLoc = locations.last else {
            return
        }
        
        if self.currentLocation != nil &&
            (lastLoc.coordinate.latitude == self.currentLocation.coordinate.latitude &&  lastLoc.coordinate.longitude == self.currentLocation.coordinate.longitude) {
            return
        }
        
        print("location = \(lastLoc)")
        
        var dist = 20.0
        if let curLoc = self.currentLocation {
            dist = curLoc.distance(from: lastLoc) / meterPerMile
        }
        if dist > 10.0 {
            self.currentLocation = lastLoc
            self.tmpCurrentLocation = lastLoc
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        self.currentLocation = nil
        self.started = false
    }
    
    
}
