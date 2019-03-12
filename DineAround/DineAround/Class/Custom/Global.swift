//
//  Global.swift
//  DineAround
//
//  Created by iPop on 8/11/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import MapKit

var g_isFirst = false

let cuisineTextArray = ["all", "american", "mexican", "italian", "indian"]

var g_currentLocation = CLLocationCoordinate2DMake(42.277110, -83.746275)

var g_winSize = UIScreen.main.bounds.size

func openMap(_ latitude:Double, _ longitude:Double) {
    let url = "http://maps.apple.com/?ll=\(latitude),\(longitude)"
    
    if let mapUrl = URL(string: url) {
        
    let application:UIApplication = UIApplication.shared
    if (application.canOpenURL(mapUrl)) {
        if #available(iOS 10.0, *) {
            application.open(mapUrl, options: [:], completionHandler: nil)
        } else {
            application.openURL(mapUrl)
        }
    }
    }
}

func callNumber(_ phone: String) {
    
    if let phoneCallURL = URL(string: "tel://\(phone)") {
        
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            if #available(iOS 10.0, *) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                application.openURL(phoneCallURL)
            }
        }
    }
}

func openWeb(_ url: String) {
    var mUrl = url
    if url.contains("http") == false {
        mUrl = "http://\(url)"
    }
    if let webUrl = URL(string: mUrl) {
        
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(webUrl)) {
            if #available(iOS 10.0, *) {
                application.open(webUrl, options: [:], completionHandler: nil)
            } else {
                application.openURL(webUrl)
            }
        }
    }
}

// MARK: - Validate Check


func isValid(email:String!) -> Bool {
    //print("validate emilId: \(email)")
    let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: email)
    return result
}


func isValid(phone: String!) -> Bool {
    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    let result =  phoneTest.evaluate(with: phone)
    return result
}

func isPasswordSame(password: String!, confirmPassword : String!) -> Bool {
    if password == confirmPassword {
        return true
    }
    else{
        return false
    }
}
func isPasswordLenth(password: String!) -> Bool {
    if password.characters.count >= 6 {
        return true
    }
    else{
        return false
    }
}


// MARK: - other

extension UIColor
{
    public class var orange1: UIColor
    {
        return UIColor(red:230/255.0, green:126/255.0, blue:37/255.0, alpha:1.0)
    }
    
    public class var light1: UIColor
    {
        return UIColor(red:224/255.0, green:224/255.0, blue:224/255.0, alpha:1.0)
    }
    
    public class var dark1: UIColor
    {
        return UIColor(red:68/255.0, green:68/255.0, blue:68/255.0, alpha:1.0)
    }
}

func makeRound(_ view: UIView, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.orange1, shadow: Bool = false) {
    let layer = view.layer
    layer.cornerRadius = 0.5 * view.bounds.size.height
    if borderWidth > 0 {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    view.clipsToBounds = true
    
    if shadow == true {
        
        let shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: layer.cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3.0
        layer.shadowPath = shadowPath.cgPath
    }
}
