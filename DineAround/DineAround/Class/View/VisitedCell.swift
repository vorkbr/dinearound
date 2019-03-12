//
//  VisitedCell.swift
//  DineAround
//
//  Created by iPop on 8/12/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class VisitedCell : UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var showButton: UIButton!
    
    var delegate: ViewCellDelegate?
    
    var purchase: Purchase! {
        didSet {
            if let nameStr = purchase.locationName {
                nameLabel.text = nameStr.uppercased()
            }
            
            if let loc = purchase.location {
                typeLabel.text = loc.cuisines?.uppercased()
                loc.setLogo(toImageView: logoImgView)
            }
            
            infoLabel.text = purchase.dateStr
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    class func reuseIdentifier() -> String {
        return "VisitedCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        logoImgView.image = nil
        nameLabel.text = ""
        typeLabel.text = ""
        infoLabel.text = ""
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()

        makeRound(mainView, borderWidth: 1, borderColor: UIColor.light1, shadow: true)
        makeRound(logoImgView)
        makeRound(showButton, borderWidth: 2, borderColor: UIColor.orange1)
    }
    
    @IBAction func actionShow(_ sender: UIButton) {
        if let del = delegate {
            del.openView(self.tag)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
