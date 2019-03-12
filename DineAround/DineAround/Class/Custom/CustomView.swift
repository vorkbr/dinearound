//
//  CustomView.swift
//  DineAround
//
//  Created by iPop on 4/1/18.
//  Copyright © 2017 Cruise. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4.0
        layer.cornerRadius = 1.0
        
        layer.borderColor = UIColor.light1.cgColor
        layer.borderWidth = 0.5

        layer.shadowPath = shadowPath.cgPath
    }
}

class BorderView: UIView {
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        layer.borderColor = UIColor.light1.cgColor
        layer.borderWidth = 0.5
    }
}

class MyTabBar: UITabBar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeThatFits = super.sizeThatFits(size)
        
        return CGSize(width: sizeThatFits.width, height: 60)
    }
}

@IBDesignable class CheckButton: UIButton {
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if self.isSelected == true {
            layer.borderColor = UIColor.orange1.cgColor
            layer.borderWidth = 1
            layer.cornerRadius = 1.0
        }
        else {
            layer.borderWidth = 0
        }
    }
}

class SwitchButton: UIButton {
    
    override open var isSelected: Bool {
        didSet {
            if isEnabled == false {
                backgroundColor = UIColor.light1
            }
            else {
                backgroundColor = isSelected ? UIColor.orange1 : UIColor.white
            }
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            if isEnabled == false {
                backgroundColor = UIColor.light1
            }
            else {
                backgroundColor = isSelected ? UIColor.orange1 : UIColor.white
            }
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        layer.cornerRadius = 0.5 * bounds.size.height
        if isEnabled == true {
            layer.borderColor = UIColor.orange1.cgColor
            layer.borderWidth = 1
        }
        else {
            layer.borderWidth = 0
        }
    }
}

@IBDesignable class BigSwitch: UISwitch {
    
    @IBInspectable var scale : CGFloat = 1{
        didSet{
            setup()
        }
    }
    
    //from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
    
    
}

extension UIButton {
    public func makeRound()
    {
        layer.cornerRadius = 0.5 * bounds.size.height
        clipsToBounds = true
    }
}

extension UIImage {
    
    /// Loads image asynchronously
    ///
    /// - Parameters:
    ///   - url: URL of the image to load
    ///   - callback: What to do with the image
    
    class func load(fromUrl url: NSURL, callback: @escaping (UIImage!)->()) {
        DispatchQueue.global().async {
            let imageData = NSData(contentsOf: url as URL) as Data?
            if let data = imageData {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    callback(image)
                }
            }
            else {
                callback(nil)
            }
        }
    
    }
}


