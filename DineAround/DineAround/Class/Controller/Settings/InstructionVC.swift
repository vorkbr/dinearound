//
//  InstructionVC.swift
//  DineAround
//
//  Created by iPop on 8/10/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class InstructionVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageCtrl: UIPageControl!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isHidden = true
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupImagesView()
        doneButton.makeRound()
    }
    
    func setupImagesView() {
        let tutorNames = ["tutor1", "tutor2", "tutor3", "tutor4"]
        
        pageCtrl.numberOfPages = tutorNames.count
        
        var xCoord: CGFloat = 0
        
        var imageFrame = CGRect(x: xCoord, y: 0,
                                width: g_winSize.width,
                                height: scrollView.bounds.height)
        for name in tutorNames {
            imageFrame.origin.x = xCoord
            
            let imgView = UIImageView(frame: imageFrame)
            imgView.image = UIImage(named: name)
            
            imgView.contentMode = .scaleAspectFit
            
            scrollView.addSubview(imgView)
            
            xCoord += g_winSize.width
        }
        
        scrollView.contentSize = CGSize(width: xCoord, height: 0)
    }
    @IBAction func actionDone(_ sender: Any) {
        if g_isFirst == false {
            g_isFirst = true
            UserDefaults.standard.set(g_isFirst, forKey: "first")
            UserDefaults.standard.synchronize()

            self.dismiss(animated: true, completion: {
                AppDelegate.shared.initLocal()
            })
        }
        else {
            self.navigationController!.popViewController(animated: true)
        }
    }
}


extension InstructionVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging && scrollView.isDecelerating {
            let pageSize: CGFloat = scrollView.contentSize.width / CGFloat(pageCtrl.numberOfPages)
            let offset: Double = Double(scrollView.contentOffset.x) / Double(pageSize)
            
            let imageNumber: Int = lround(offset)
            
            pageCtrl.currentPage = imageNumber
            
            doneButton.isHidden = (imageNumber != 3)
        }
    }
}


