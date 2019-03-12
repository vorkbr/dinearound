//
//  RatingView.swift
//  DineAround
//
//  Created by iPop on 8/15/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import Foundation
import UIKit

let kRatingPadding: CGFloat = 2.0
let kMaxRatingControlStars: CGFloat = 5.0

@IBDesignable class RatingView: UIView {
    @IBInspectable var rating : CGFloat {
        get { return _rating }
        set (newRating) {
            if (newRating >= kMaxRatingControlStars) {
                _rating = kMaxRatingControlStars
            } else {
                _rating = newRating
            }
        }
    }
    
    @IBInspectable var emptyStarImage: UIImage! {
        didSet { updateImageViews() }
    }
    @IBInspectable var starImage: UIImage! {
        didSet { updateImageViews() }
    }
    
    private var _rating : CGFloat = 0.0 {
        didSet { updateImageViews() }
    }
    
    private lazy var starViews: [StarView] = {
        var lazyImageViews: [StarView] = []
        for x in stride(from: 0, to: kMaxRatingControlStars, by: 1) {
            let imageView = StarView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            lazyImageViews.append(imageView)
        }
        return lazyImageViews
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStarViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStarViewConstraints()
    }
    
    func setupStarViewConstraints() {
        var lastStarView: StarView?
        for starView in starViews {
            addSubview(starView)
            
            if lastStarView != nil {
                let relationalConstraints = [
                    NSLayoutConstraint(item: starView, attribute: .left, relatedBy: .equal, toItem: lastStarView, attribute: .right, multiplier: 1.0, constant: kRatingPadding),
                    NSLayoutConstraint(item: starView, attribute: .top, relatedBy: .equal, toItem: lastStarView, attribute: .top, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: starView, attribute: .width, relatedBy: .equal, toItem: lastStarView, attribute: .width, multiplier: 1.0, constant: 0.0),
                    ]
                NSLayoutConstraint.activate(relationalConstraints)
            } else {
                let leftEdgeConstraints = [
                    NSLayoutConstraint(item: starView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: starView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                    ]
                NSLayoutConstraint.activate(leftEdgeConstraints)
            }
            
            lastStarView = starView
        }
        
        if let furtherstStarOnTheRight = lastStarView {
            let rightEdgeConstraints = [
                NSLayoutConstraint(item: furtherstStarOnTheRight, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
            ]
            NSLayoutConstraint.activate(rightEdgeConstraints)
        }
    }
    
    func updateImageViews() {
        if emptyStarImage != nil && starImage != nil {
            invalidateIntrinsicContentSize()
            
            let lastFullStar = floor(rating)
            let remainingStarFillPercentage = rating - lastFullStar
            
            for (index, starView) in starViews.enumerated() {
                if index < Int(lastFullStar) {
                    starView.percentFill = 1.0
                } else if index == Int(lastFullStar) {
                    starView.percentFill = remainingStarFillPercentage
                } else {
                    starView.percentFill = 0.0
                }
                
                starView.setFullStarImage(fullStarImage: starImage, emptyStarImage: emptyStarImage)
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        if emptyStarImage != nil && starImage != nil {
            let tallestImageHeight = max(emptyStarImage.size.height, starImage.size.height)
            return CGSize(width: (tallestImageHeight * kMaxRatingControlStars) + (kRatingPadding * (kMaxRatingControlStars - 1)), height: tallestImageHeight)
        } else {
            return CGSize(width: (10.0 * kMaxRatingControlStars) + (kRatingPadding * (kMaxRatingControlStars - 1)), height: 10.0)
        }
    }
}

class StarView: UIView {
    var percentFill: CGFloat = 0.0
    var emptyStarImageView = UIImageView()
    var starImageView = UIImageView()
    
    private var starContainerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        starContainerView.clipsToBounds = true
        
        starContainerView.addSubview(starImageView)
        addSubview(emptyStarImageView)
        addSubview(starContainerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setFullStarImage(fullStarImage: UIImage, emptyStarImage: UIImage) {
        emptyStarImageView.image = emptyStarImage
        starImageView.image = fullStarImage
        
        emptyStarImageView.sizeToFit()
        starImageView.sizeToFit()
        
        //Because of the order of functions above, we can assume that we have a percent fill at this point
        starContainerView.frame = CGRect(x: 0, y: 0, width: intrinsicContentSize.width * percentFill, height: intrinsicContentSize.height)
    }
    
    override public var intrinsicContentSize: CGSize {
        if emptyStarImageView.image != nil && starImageView.image != nil {
            let tallestImageHeight = max(emptyStarImageView.image?.size.height ?? 0, starImageView.image?.size.height ?? 0)
            return CGSize(width: tallestImageHeight, height: tallestImageHeight)
        } else {
            return CGSize(width: (10.0 * kMaxRatingControlStars) + (kRatingPadding * (kMaxRatingControlStars - 1)), height: 10.0)
        }
    }
}

