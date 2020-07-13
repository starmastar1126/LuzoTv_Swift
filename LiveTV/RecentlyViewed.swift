//
//  RecentlyViewed.swift
//  LiveTV
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RecentlyViewed: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,GADBannerViewDelegate,GADInterstitialDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var myCollectionView : UICollectionView?
    @IBOutlet var lblnodatafound : UILabel?
    var RecentlyViewAllArray = NSMutableArray()
    
    @IBOutlet var btnsearch : UIButton?
    @IBOutlet var searchBar : UISearchBar?
    @IBOutlet var btnback : UIButton?
    @IBOutlet var btnbacksearch : UIButton?
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var interstitial: GADInterstitial!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "RecentlyViewedCell_iPad", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "RecentlyViewedCell", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        //flowLayout.minimumLineSpacing = 0
        //flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.myCollectionView?.collectionViewLayout = flowLayout
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //=======Get Recently View All Data========//
        self.RecentlyViewAllArray.removeAllObjects()
        self.getAllRecentlyViewData()
    }
    
    func getAllRecentlyViewData()
    {
        self.RecentlyViewAllArray = Singleton.getInstance().getAllRecentlyViewedQueryData()
        self.RecentlyViewAllArray =  NSMutableArray(array: self.RecentlyViewAllArray.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
        print("RecentlyViewAllArray Count = \(self.RecentlyViewAllArray.count)")
        
        DispatchQueue.main.async {
            if (self.RecentlyViewAllArray.count == 0) {
                self.myCollectionView?.isHidden = true
                self.lblnodatafound?.isHidden = false
            } else {
                self.myCollectionView?.isHidden = false
                self.lblnodatafound?.isHidden = true
                self.myCollectionView?.reloadData()
                self.CallAdmobBanner()
            }
        }
    }
    
    //============UICollectionView Delegate & Datasource Methods============//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.RecentlyViewAllArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! RecentlyViewedCell
        
        let strimgpath : String? = (self.RecentlyViewAllArray.value(forKey: "cover_image") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = strimgpath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        cell.coverImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        cell.lblTitle?.text = (self.RecentlyViewAllArray.value(forKey: "title") as! NSArray).object(at: indexPath.row) as? String
        
        let isType:String = (self.RecentlyViewAllArray.value(forKey: "type") as! NSArray).object(at: indexPath.row) as! String
        if (isType == "channel") {
            cell.coverImageView?.contentMode = .scaleAspectFit
        } else if (isType == "series") {
            cell.coverImageView?.contentMode = .scaleToFill
        } else if (isType == "movie") {
            cell.coverImageView?.contentMode = .scaleToFill
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/2.5)
        } else {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/2.5)
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.CallAdmobInterstitial()
        
        let rID = (self.RecentlyViewAllArray.value(forKey: "id") as! NSArray).object(at: indexPath.row) as? String
        let rNAME = (self.RecentlyViewAllArray.value(forKey: "title") as! NSArray).object(at: indexPath.row) as? String
        let isType:String = (self.RecentlyViewAllArray.value(forKey: "type") as! NSArray).object(at: indexPath.row) as! String
        if (isType == "channel") {
            UserDefaults.standard.set(rID, forKey: "CHANNEL_ID")
            UserDefaults.standard.set(rNAME, forKey: "CHANNEL_NAME")
            self.CallDetailChannelViewController()
        } else if (isType == "series") {
            UserDefaults.standard.set(rID, forKey: "SERIES_ID")
            UserDefaults.standard.set(rNAME, forKey: "SERIES_NAME")
            self.CallDetailSeriesViewController()
        } else if (isType == "movie") {
            UserDefaults.standard.set(rID, forKey: "MOVIE_ID")
            UserDefaults.standard.set(rNAME, forKey: "MOVIE_NAME")
            self.CallDetailMovieViewController()
        }
    }
    
    
    //============Search Button Click============//
    @IBAction func OnSearchClick(sender:UIButton)
    {
        self.searchBar?.becomeFirstResponder()
        self.searchBar?.isHidden = false
        self.btnbacksearch?.isHidden = false
        self.btnback?.isHidden = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if (self.searchBar?.text != "")
        {
            UserDefaults.standard.set(self.searchBar?.text, forKey: "SEARCH_TEXT")
            self.searchBar?.resignFirstResponder()
            self.searchBar?.isHidden = true
            self.btnbacksearch?.isHidden = true
            self.btnback?.isHidden = false
            self.searchBar?.text = ""
            self.CallSearchViewController()
        }
    }
    @IBAction func OnBackSearchClick(sender:UIButton)
    {
        self.searchBar?.resignFirstResponder()
        self.searchBar?.isHidden = true
        self.btnbacksearch?.isHidden = true
        self.searchBar?.text = ""
        self.btnback?.isHidden = false
    }
    
    func CallSearchViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = SearchView(nibName: "SearchView_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = SearchView(nibName: "SearchView_iPhoneX", bundle: nil)
        } else {
            view = SearchView(nibName: "SearchView", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallDetailMovieViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = DetailMovieView(nibName: "DetailMovieView_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = DetailMovieView(nibName: "DetailMovieView_iPhoneX", bundle: nil)
        } else {
            view = DetailMovieView(nibName: "DetailMovieView", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallDetailSeriesViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = DetailSeriesView(nibName: "DetailSeriesView_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = DetailSeriesView(nibName: "DetailSeriesView_iPhoneX", bundle: nil)
        } else {
            view = DetailSeriesView(nibName: "DetailSeriesView", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallDetailChannelViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = DetailChannelView(nibName: "DetailChannelView_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = DetailChannelView(nibName: "DetailChannelView_iPhoneX", bundle: nil)
        } else {
            view = DetailChannelView(nibName: "DetailChannelView", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    //================Admob Banner Ads===============//
    func CallAdmobBanner() {
        let isBannerAd = UserDefaults.standard.value(forKey: "banner_ad_ios") as? String
        if (isBannerAd == "true") {
            let isGDPR_STATUS: Bool = UserDefaults.standard.bool(forKey: "GDPR_STATUS")
            if (isGDPR_STATUS) {
                let request = DFPRequest()
                let extras = GADExtras()
                extras.additionalParameters = ["npa": "1"]
                request.register(extras)
                self.setAdmob()
            } else {
                self.setAdmob()
            }
        } else {
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                self.myCollectionView?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-75)
            } else if (CommonUtils.screenHeight >= 812) {
                self.myCollectionView?.frame = CGRect(x: 0, y: 100, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-100)
            } else {
                self.myCollectionView?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-75)
            }
        }
    }
    func setAdmob()
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-50, width:CommonUtils.screenWidth-20, height:50))
        } else if (CommonUtils.screenHeight >= 812) {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-65, width:CommonUtils.screenWidth-20, height:50))
        } else {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-50, width:CommonUtils.screenWidth-20, height:50))
        }
        addBannerView(to: bannerView)
        let banner_ad_id_ios = UserDefaults.standard.value(forKey: "banner_ad_id_ios") as? String
        bannerView.adUnitID = banner_ad_id_ios
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    func adViewDidReceiveAd(_ adView: GADBannerView)
    {
        // We've received an ad so lets show the banner
        print("adViewDidReceiveAd")
    }
    func adView(_ adView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        // Failed to receive an ad from AdMob so lets hide the banner
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription )")
    }
    func addBannerView(to bannerView: UIView?)
    {
        if let aView = bannerView {
            view.addSubview(aView)
        }
        if let aView = bannerView {
            view.addConstraints([NSLayoutConstraint(item: aView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0), NSLayoutConstraint(item: aView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
        }
    }
    
    
    //================Admob Interstitial Ads===============//
    func CallAdmobInterstitial()
    {
        //1.Interstitial Ad Click
        let ad_click: Int = UserDefaults.standard.integer(forKey: "ADClick")
        UserDefaults.standard.set(ad_click + 1, forKey: "ADClick")
        //2.Load Interstitial
        let isInterstitialAd = UserDefaults.standard.value(forKey: "interstital_ad_ios") as? String
        if (isInterstitialAd == "true") {
            let interstital_ad_click_ios = UserDefaults.standard.value(forKey: "interstital_ad_click_ios") as? String
            let adminCount = Int(interstital_ad_click_ios!)
            let ad_click1: Int = UserDefaults.standard.integer(forKey: "ADClick")
            print("ad_click1 : \(ad_click1)")
            if (ad_click1 % adminCount! == 0) {
                let isGDPR_STATUS: Bool = UserDefaults.standard.bool(forKey: "GDPR_STATUS")
                if (isGDPR_STATUS) {
                    let request = DFPRequest()
                    let extras = GADExtras()
                    extras.additionalParameters = ["npa": "1"]
                    request.register(extras)
                    self.createAndLoadInterstitial()
                } else {
                    self.createAndLoadInterstitial()
                }
            }
        }
    }
    func createAndLoadInterstitial()
    {
        let interstitialAdId = UserDefaults.standard.value(forKey: "interstital_ad_id_ios") as? String
        interstitial = GADInterstitial(adUnitID: interstitialAdId!)
        let request = GADRequest()
        interstitial.delegate = self
        //request.testDevices = @[ kGADSimulatorID ];
        interstitial.load(request)
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        if (interstitial.isReady) {
            interstitial.present(fromRootViewController: self)
        }
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial)
    {
        print("interstitialWillDismissScreen")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("didFailToReceiveAdWithError")
    }
    
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //1.Background Color
        self.view.backgroundColor = UIColor(hexString:Colors.getBackgroundColor())
        
        //2.StatusBar Color
        self.lblstatusbar?.backgroundColor = UIColor(hexString: Colors.getStatusBarColor())
        
        //3.Header Color
        self.lblheader?.backgroundColor = UIColor.clear
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = (self.lblheader?.bounds)!
        gradientLayer.colors = [UIColor(hexString: Colors.getHeaderColor1()).cgColor, UIColor(hexString: Colors.getHeaderColor2()).cgColor]
        self.lblheader?.layer.insertSublayer(gradientLayer, at: 0)
        
        //4.Header Name
        self.lblheadername?.text = CommonMessage.RecentlyViewed()
        self.searchBar?.barTintColor = UIColor.clear

        //5.UISearchbar Clear Background Color
//        for subView in (self.searchBar?.subviews)! {
//            for view in subView.subviews {
//                if view.isKind(of: NSClassFromString("UISearchBarBackground")!) {
//                    let imageView = view as! UIImageView
//                   imageView.removeFromSuperview()
//                }
//            }
//        }
    }
    
    
    //=====Status Bar Hidden & Style=====//
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func OnBackClick(sender:UIButton) {
        _ = navigationController?.popViewController(animated:true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
