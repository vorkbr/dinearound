//
//  DetailVC.swift
//  DineAround
//
//  Created by iPop on 8/11/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import MapKit

class DetailVC: UIViewController {

    @IBOutlet weak var offerButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    
    // MARK: - Offer View
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var offerImageScrollView: UIScrollView!
    
    @IBOutlet weak var offerPageCtrl: UIPageControl!
    
    
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet var entreeButtons: [SwitchButton]!
    
    // MARK: - Detail View
    @IBOutlet weak var detailScrollView: UIScrollView!
    
    @IBOutlet weak var detailImageScrollView: UIScrollView!
    @IBOutlet weak var detailPageCtrl: UIPageControl!
    
    @IBOutlet weak var detailPhoneButton: UIButton!
    @IBOutlet weak var detailMenuButton: UIButton!
    @IBOutlet weak var detailWebsiteButton: UIButton!
    
    @IBOutlet weak var detailOpenTimeLabel: UILabel!
    
    @IBOutlet weak var detailReviewView: UIView!
    @IBOutlet weak var ratingView: RatingView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBOutlet weak var featureButtonScrollView: UIScrollView!
    
    @IBOutlet weak var detailMapView: MKMapView!
    // other
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var couponRedeemButton: UIButton!
    
    var entreeIndex = 0
    
    
    private var offerScrollingTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    private var detailScrollingTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    var restaurant: Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = restaurant.name?.uppercased()
        self.navigationController?.navigationBar.backItem?.title = " "

        self.offerInit()
        
        self.detailInit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = 64 + 144 + 44 + 108 + 254 + g_winSize.width * 0.5 + 40
        self.detailScrollView.contentSize = CGSize(width: 0, height: height)
        
        print("detailview = \(self.detailImageScrollView.bounds)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // add for redeem success
        if ApiManager.shared.tempVerifyCode == "success" {
            ApiManager.shared.tempVerifyCode = ""
            
            self.entreeButtons[entreeIndex].isSelected = false
            self.entreeButtons[entreeIndex].isEnabled = false
            
            ApiManager.shared.putPurchases(self.restaurant!, entree: self.entreeIndex, completion: nil)
            
        }
        
        self.offerInitScrollTimer()
        self.detailInitScrollTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        offerScrollingTimer?.invalidate()
        detailScrollingTimer?.invalidate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMenu" {
            if let loc = sender as? Location, let vc = segue.destination as? MenuImageVC {
                
                vc.location = loc
            }
        }
    }
    
    // MARK: - OfferView Action
    
    @IBAction func actionSelect(_ sender: UIButton) {
        self.selectView(sender.tag - 1)
    }
    
    @IBAction  func actionEntry(_ sender: UIButton) {
        
        if backView.isHidden == false {
            return
        }
        
        entreeIndex = sender.tag - 3
        
        backView.isHidden = false
        
        var rect = couponView.frame
        rect.origin.y = g_winSize.height
        couponView.frame = rect
        
        couponView.isHidden = false
        
        let y0 = g_winSize.height * 0.25
        
        UIView.animate(withDuration: 0.5, delay: 0.05, options: [.curveEaseOut], animations: {
            
            rect.origin.y = y0
            self.couponView.frame = rect
        }, completion: {_ in
            sender.isEnabled = true
        })
    }
    
    @IBAction func actionLocation(_ sender: UIButton) {
        openMap(restaurant.coordinate.latitude, restaurant.coordinate.longitude)
    }

    
    // select one of Offer and Detail
    
    func offerInit() {
        selectView(0)
        
        if let imageURLs = restaurant.pictureURLs {
            offerPageCtrl.numberOfPages = imageURLs.count
            
            offerBuildLocationImages()
        }
        
        cityLabel.text = restaurant.city
        infoLabel.text = restaurant.createAt
        
        restaurant.getDistanceFromCurrent()
        if restaurant.distance >= 0 {
            distanceLabel.text = String(format: "%01.02f mi", restaurant.distance)
        }
        else {
            distanceLabel.text = "N/A"
        }
        
        for btn in entreeButtons {
            btn.isHidden = true
            btn.isSelected = true
        }
        
        let entrees = ApiManager.shared.getPurchases(fromLocation: restaurant.key, andUser: UserInfo.shared.key) ?? []
        
        for cop in restaurant.coupons {
            if cop.key > 2 { break }
            
            let btn = entreeButtons[cop.key - 1]
            btn.isHidden = false
            
            let res = entrees.filter({$0.couponIndex == cop.key})
            if res.count > 0 {
                btn.isSelected = false
                btn.isEnabled = false
            }
        }
    }
    
    
    func selectView(_ index: Int) {
        offerButton.isSelected = index == 0
        detailButton.isSelected = index != 0
        
        offerView.isHidden = index != 0
        detailScrollView.isHidden = index == 0
    }
    
    func setReeemed(_ button: UIButton) {
        button.isEnabled = false
    }
    
    
    private func offerBuildLocationImages() {
        if let urlArray = self.restaurant.pictureURLs {
            var xCoord: CGFloat = 0
            
            var imageFrame = CGRect(x: xCoord, y: 0, width: g_winSize.width, height: g_winSize.width*0.6)
            for url in urlArray {
                imageFrame.origin.x = xCoord
                let imgView = UIImageView(frame: imageFrame)
                imgView.contentMode = .scaleAspectFill
                
                self.restaurant.setImage(toImageView: imgView, url: url)
                self.offerImageScrollView.addSubview(imgView)
                
                xCoord += g_winSize.width
            }
            
            self.offerInitScrollTimer()
            self.offerImageScrollView.contentSize = CGSize(width: xCoord, height: 0)
            
        }
    }
    
    func offerInitScrollTimer() {
        offerScrollingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(offerScrollTimerFired), userInfo: nil, repeats: true)
    }
    
    func offerScrollTimerFired() {
        var scrollPage = self.offerPageCtrl.currentPage + 1
        
        var xCoord = CGFloat(scrollPage) * g_winSize.width
        
        if let imageCount = self.restaurant.pictureURLs?.count {
            if scrollPage == imageCount {
                xCoord = 0
                scrollPage = 0
            }
        }
        let scrollPoint = CGPoint(x: xCoord, y: 0)
        
        self.offerImageScrollView.setContentOffset(scrollPoint, animated: true)
        
        self.offerPageCtrl.currentPage = scrollPage
        
    }
    
    // MARK: - DetailView Action
    
    @IBAction func actionDetailPhone(_ sender: UIButton) {
        if let phone = restaurant.phone {
            callNumber(phone)
        }
        else {
            print("phone is empty")
        }
    }

    @IBAction func actionDetailMenu(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showMenu", sender: self.restaurant)
    }
    
    @IBAction func actionDetailWebsite(_ sender: UIButton) {
        if let url = restaurant.website {
            openWeb(url)
        }
        else {
            print("website is empty")
        }
    }
    
    
    // MARK: - DetailView method
    func detailInit() {
        
        makeRound(detailPhoneButton)
        makeRound(detailMenuButton)
        makeRound(detailWebsiteButton)
        
        self.detailInitFeatures()
        
        if let imageURLs = restaurant.pictureURLs {
            self.detailPageCtrl.numberOfPages = imageURLs.count + 1
        }
        else {
            self.detailPageCtrl.numberOfPages = 1
        }
        self.detailBuildLocationImages()
        
        detailOpenTimeLabel.text = self.restaurant.hours
        
        let coord = self.restaurant.coordinate
        let viewRegion = MKCoordinateRegionMakeWithDistance(coord, 250, 250)
        self.detailMapView.setRegion(viewRegion, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        
        self.detailMapView.addAnnotation(annotation)
        
        if restaurant.rating >= 0 {
            ratingView.rating = CGFloat(restaurant.rating)
            ratingLabel.text = String(format: "%.1f", restaurant.rating)
            if restaurant.reviewCount == 1 {
                reviewLabel.text = "1 Review"
            }
            else if restaurant.reviewCount > 1 {
                reviewLabel.text = "\(restaurant.reviewCount) Reviews"
            }
            else {
                reviewLabel.text = ""
            }
            
        }
        else {
            ratingView.rating = 0
            ratingLabel.text = ""
            reviewLabel.text = ""
            ApiManager.shared.getReview(from: restaurant, completion: { (res) in
                if res == true {
                    self.ratingView.rating = CGFloat(self.restaurant.rating)
                    self.ratingLabel.text = String(format: "%.1f", self.restaurant.rating)
                    
                    if self.restaurant.reviewCount == 1 {
                        self.reviewLabel.text = "1 Review"
                    }
                    else if self.restaurant.reviewCount > 1 {
                        self.reviewLabel.text = "\(self.restaurant.reviewCount) Reviews"
                    }
                }
            })
            

        }
        //
    }
    
    func detailInitFeatures() {
        var x: CGFloat = 8
        
        x = (g_winSize.width - 48 * 6 - 8 * 7) * 0.5
        if x < 8 {
            x = 8
        }
        
        var rect = CGRect(x: 8, y: 6, width: 48, height: 48)
        var tag = 21
        for feature in Feature.names() {
            
            rect.origin.x = x
            
            let imgView = UIImageView(frame: rect)
            imgView.image = UIImage(named: Feature.resource(type: feature))
            imgView.backgroundColor = UIColor.white
            imgView.contentMode = .center
            
            imgView.layer.cornerRadius = 8
            imgView.layer.borderWidth = 0.5
            imgView.layer.borderColor = UIColor(white: 235/255.0, alpha: 1.0).cgColor
            
            if self.restaurant.hasFeature(type: feature) == nil {
                imgView.alpha = 0.3
            }
            
            imgView.tag = tag
            
            self.featureButtonScrollView.addSubview(imgView)
            
            x += 48 + 8
            tag += 1
        }
        
        featureButtonScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: x)
    }
    
    private func detailBuildLocationImages() {
        
        var xCoord: CGFloat = 0
        
        let winSize = g_winSize

        var imageFrame = CGRect(x: xCoord, y: 0, width: winSize.width, height: CGFloat( Int(winSize.width*0.6 + 0.5) ))
        
        // Add Logo Info
        
        let logoView = UIView(frame: imageFrame)
        
        // add BlurImageView
        let blurImgView = UIImageView(frame: imageFrame)
        blurImgView.image = UIImage(named: "res_info4")
        blurImgView.contentMode = .scaleToFill
        logoView.addSubview(blurImgView)
        
        let blackView = UIView(frame: imageFrame)
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0.8
        logoView.addSubview(blackView)
        
        
        // add LogoView
        
        if let _ = restaurant.logoURL {
            let rect = CGRect(x: winSize.width * 0.1, y: imageFrame.size.height * 0.5 - 40, width: 80, height: 80)
            let logoImgView = UIImageView(frame: rect)

            logoImgView.contentMode = .scaleAspectFill
            logoView.addSubview(logoImgView)
            logoImgView.backgroundColor = UIColor.white
            
            restaurant.setLogo(toImageView: logoImgView)
            
            makeRound(logoImgView)
        }
        
        var rect1 = CGRect(x: winSize.width * 0.35, y: imageFrame.size.height * 0.5 - 40, width: winSize.width * 0.5, height: 24)
        let locNameLabel = UILabel(frame: rect1)
        locNameLabel.text = restaurant.name?.uppercased()
        locNameLabel.textColor = UIColor.orange1
        locNameLabel.font = UIFont(name: "Comfortaa-Bold", size: 20)!
        
        logoView.addSubview(locNameLabel)
        
        
        rect1 = CGRect(x: winSize.width * 0.35, y: imageFrame.size.height * 0.5 - 10, width: winSize.width * 0.6 - 10, height: 20)
        let locAddrLabel = UILabel(frame: rect1)
        locAddrLabel.text = restaurant.address?.uppercased()
        locAddrLabel.textColor = UIColor.white
        locAddrLabel.minimumScaleFactor = 0.8
        locAddrLabel.font = UIFont(name: "Comfortaa-Bold", size: 13)!
        
        logoView.addSubview(locAddrLabel)
        
        rect1 = CGRect(x: winSize.width * 0.35, y: imageFrame.size.height * 0.5 + 16, width: winSize.width * 0.6 - 10, height: 20)
        let locCityLabel = UILabel(frame: rect1)
        locCityLabel.text = restaurant.cityStateString()
        locCityLabel.textColor = UIColor.white
        locCityLabel.font = UIFont(name: "Comfortaa-Bold", size: 13)!
        
        logoView.addSubview(locCityLabel)
        
        rect1.origin.y = imageFrame.size.height * 0.5 + 40
        let locCuisineLabel = UILabel(frame: rect1)
        
        locCuisineLabel.text = restaurant.cuisines?.uppercased()
        
        locCuisineLabel.textColor = UIColor.white
        locCuisineLabel.font = UIFont(name: "Comfortaa-Bold", size: 14)!
        
        logoView.addSubview(locCuisineLabel)
        
        
        self.detailImageScrollView.addSubview(logoView)
        xCoord += winSize.width

        // Add Photo
        if let urlArray = self.restaurant.pictureURLs {
            for url in urlArray {
                imageFrame.origin.x = xCoord
                let imgView = UIImageView(frame: imageFrame)
                imgView.contentMode = .scaleAspectFill
                
                self.restaurant.setImage(toImageView: imgView, url: url)
                
                self.detailImageScrollView.addSubview(imgView)
                
                xCoord += winSize.width
            }
        }
        self.detailInitScrollTimer()
        self.detailImageScrollView.contentSize = CGSize(width: xCoord, height: 0)
    }
    
    func detailInitScrollTimer() {
        detailScrollingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(detailScrollTimerFired), userInfo: nil, repeats: true)
    }
    
    func detailScrollTimerFired() {
        var scrollPage = self.detailPageCtrl.currentPage + 1
        
        var xCoord = CGFloat(scrollPage) * g_winSize.width
        
        var imgCount = self.restaurant.pictureURLs?.count ?? 0
        imgCount = imgCount + 1
        if scrollPage == imgCount {
            xCoord = 0
            scrollPage = 0
        }
    
        let scrollPoint = CGPoint(x: xCoord, y: 0)
        
        self.detailImageScrollView.setContentOffset(scrollPoint, animated: true)
        
        self.detailPageCtrl.currentPage = scrollPage
        
    }

    // MARK: - 
    
    @IBAction func actionCouponRedeem(_ sender: Any) {
        
        if !UserInfo.shared.isLogin {
            self.hideCouponView {
                self.performSegue(withIdentifier: "showPurchase", sender: self)
            }
        }
        else {
            self.showRedeemAlert("Give phone to server")
        }
        
    }
    
    @IBAction func actionCouponClose(_ sender: Any) {
        
        self.hideCouponView()
        
        var rect = couponView.frame
        let y0:CGFloat = -200.0
        
        UIView.animate(withDuration: 0.5, delay: 0.05, options: [.curveEaseOut], animations: {
            
            rect.origin.y = y0
            self.couponView.frame = rect
            
        }, completion: {_ in
            self.backView.isHidden = true
        })
    }
    
    func showRedeemAlert(_ message: String!) {
        let alertVC = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.hideCouponView {
                SwiftLoader.show(animated: true)
                
                ApiManager.shared.tempPhone = UserInfo.shared.phone
                ApiManager.shared.tempVerifyCode = "\(self.restaurant.coupons[self.entreeIndex].code)"
                
                ApiManager.shared.sendSMS(ApiManager.shared.tempVerifyCode, toPhone: UserInfo.shared.phone)
                
                SwiftLoader.hide()
                
                self.performSegue(withIdentifier: "showVerify", sender: self)
            }
            
        }))
        alertVC.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action) in
            self.hideCouponView()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func hideCouponView(_ process: (() -> ())? = nil) {
        var rect = couponView.frame
        let y0:CGFloat = -200.0
        
        UIView.animate(withDuration: 0.5, delay: 0.05, options: [.curveEaseOut], animations: {
            
            rect.origin.y = y0
            self.couponView.frame = rect
            
        }, completion: {_ in
            self.backView.isHidden = true
            
            if let process = process {
                process()
            }
        })
    }
}

// MARK: - UIScrollView Delegate

extension DetailVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 && scrollView.isDragging && scrollView.isDecelerating {
            let pageSize: CGFloat = scrollView.contentSize.width / CGFloat(self.offerPageCtrl.numberOfPages)
            let offset: Double = Double(scrollView.contentOffset.x) / Double(pageSize)
            
            let imageNumber: Int = lround(offset)
            
            self.offerPageCtrl.currentPage = imageNumber
            
            self.offerInitScrollTimer()
        }
        else if scrollView.tag == 3 && scrollView.isDragging && scrollView.isDecelerating {
            let pageSize: CGFloat = scrollView.contentSize.width / CGFloat(self.detailPageCtrl.numberOfPages)
            let offset: Double = Double(scrollView.contentOffset.x) / Double(pageSize)
            
            let imageNumber: Int = lround(offset)
            
            self.detailPageCtrl.currentPage = imageNumber
            
            self.detailInitScrollTimer()
        }
    }
}
