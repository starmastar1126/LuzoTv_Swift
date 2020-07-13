//
//  FavMovies.swift
//  LiveTV
//
//  Created by Apple on 01/08/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FavMovies: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GADBannerViewDelegate,GADInterstitialDelegate
{
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var myCollectionView : UICollectionView?
    @IBOutlet var lblnodatafound : UILabel?
    var FavouriteArray = NSMutableArray()
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var interstitial: GADInterstitial!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "MovieCell_iPad", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "MovieCell", bundle:nil)
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
        
        //=======Get Favourite Movies Data========//
        self.FavouriteArray.removeAllObjects()
        self.getAllMoviesData()
    }
    
    func getAllMoviesData()
    {
        self.FavouriteArray = Singleton.getInstance().getAllMoviesQueryData()
        print("FavouriteArray Count = \(self.FavouriteArray.count)")
        
        DispatchQueue.main.async {
            if (self.FavouriteArray.count == 0) {
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
        return self.FavouriteArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MovieCell
        
        let strimgpath : String? = (self.FavouriteArray.value(forKey: "movie_poster") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = strimgpath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        cell.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        let language_name = ((self.FavouriteArray.value(forKey: "language_name") as! NSArray).object(at: indexPath.row) as? String)?.uppercased()
        let aStr = String(format: "   %@   ", language_name!)
        cell.lblLanguageName?.text = aStr
        
        let language_background = (self.FavouriteArray.value(forKey: "language_background") as! NSArray).object(at: indexPath.row) as? String
        cell.lblLanguageName?.backgroundColor = UIColor(hexString: language_background)
        
        cell.lblMovieName?.text = (self.FavouriteArray.value(forKey: "movie_title") as! NSArray).object(at: indexPath.row) as? String
        
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
        let movieID = (self.FavouriteArray.value(forKey: "id") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(movieID, forKey: "MOVIE_ID")
        let movieNAME = (self.FavouriteArray.value(forKey: "movie_title") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(movieNAME, forKey: "MOVIE_NAME")
        self.CallAdmobInterstitial()
        self.CallDetailMovieViewController()
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
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-200, width:CommonUtils.screenWidth-20, height:50))
        } else if (CommonUtils.screenHeight >= 812) {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-220, width:CommonUtils.screenWidth-20, height:50))
        } else {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-175, width:CommonUtils.screenWidth-20, height:50))
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
