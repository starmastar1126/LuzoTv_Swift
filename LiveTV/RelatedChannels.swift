//
//  RelatedChannels.swift
//  LiveTV
//
//  Created by Apple on 26/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RelatedChannels: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GADBannerViewDelegate,GADInterstitialDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var myCollectionView : UICollectionView?
    @IBOutlet var lblnodatafound : UILabel?
    var RelatedChannelsArray = NSMutableArray()
    var LoadMoreArray = NSMutableArray()
    
    var pageNo:Int = 1
    var isLoadMore:Bool = false
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var interstitial: GADInterstitial!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "ChannelCell_iPad", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "ChannelCell", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        //flowLayout.minimumLineSpacing = 0
        //flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.myCollectionView?.collectionViewLayout = flowLayout
        
        //======Get Related Channels Data======//
        self.myCollectionView?.isHidden = true
        self.getRelatedChannels()
    }
    
    //===========Get Related Channels Data==========//
    func getRelatedChannels()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getRelatedChannelsData(encodedString)
        } else {
            self.InternetConnectionNotAvailable1()
        }
    }
    func getRelatedChannelsData(_ requesturl: String?)
    {
        let channelID : String = UserDefaults.standard.string(forKey: "CHANNEL_ID")!
        let categoryID : String = UserDefaults.standard.string(forKey: "CATEGORY_ID")!
        let pageNo:String = String(self.pageNo)
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_related_post", "post_id":channelID, "type":"channel", "cat_id":categoryID, "page":pageNo]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Related Channels API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Related Channels Responce Data : \(responseObject)")
                self.RelatedChannelsArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.RelatedChannelsArray.add(storeDict as Any)
                    }
                }
                print("RelatedChannelsArray Count = \(self.RelatedChannelsArray.count)")
                
                DispatchQueue.main.async {
                    if (self.RelatedChannelsArray.count == 0) {
                        self.myCollectionView?.isHidden = true
                        self.lblnodatafound?.isHidden = false
                    } else {
                        self.isLoadMore = true
                        self.myCollectionView?.isHidden = false
                        self.lblnodatafound?.isHidden = true
                        self.myCollectionView?.reloadData()
                        self.CallAdmobBanner()
                    }
                }
                
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure1()
            self.stopSpinner()
        })
    }
    
    //============UICollectionView Delegate & Datasource Methods============//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.RelatedChannelsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ChannelCell
        
        let strimgpath : String? = (self.RelatedChannelsArray.value(forKey: "rel_channel_thumbnail") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = strimgpath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        cell.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        cell.lblChannelName?.text = (self.RelatedChannelsArray.value(forKey: "rel_channel_title") as! NSArray).object(at: indexPath.row) as? String
        
        //Lazy loading
        if (isLoadMore) {
            if (indexPath.row == self.RelatedChannelsArray.count-1) {
                self.pageNo = self.pageNo + 1;
                self.getLoadMoreRelatedChannels()
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/3.5)
        } else {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/3.5)
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let channelID = (self.RelatedChannelsArray.value(forKey: "rel_id") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(channelID, forKey: "CHANNEL_ID")
        let channelNAME = (self.RelatedChannelsArray.value(forKey: "rel_channel_title") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(channelNAME, forKey: "CHANNEL_NAME")
        self.CallAdmobInterstitial()
        self.CallDetailChannelViewController()
    }
    
    //===========Get Load More Related Channel Data==========//
    func getLoadMoreRelatedChannels()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getLoadMoreRelatedChannelsData(encodedString)
        } else {
            self.InternetConnectionNotAvailable2()
        }
    }
    func getLoadMoreRelatedChannelsData(_ requesturl: String?)
    {
        let channelID : String = UserDefaults.standard.string(forKey: "CHANNEL_ID")!
        let categoryID : String = UserDefaults.standard.string(forKey: "CATEGORY_ID")!
        let pageNo:String = String(self.pageNo)
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_related_post", "post_id":channelID, "type":"channel", "cat_id":categoryID, "page":pageNo]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Load More Related Channels API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Load More Related Channels Responce Data : \(responseObject)")
                self.LoadMoreArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.RelatedChannelsArray.add(storeDict as Any)
                        self.LoadMoreArray.add(storeDict as Any)
                    }
                }
                print("RelatedChannelsArray Count = \(self.RelatedChannelsArray.count)")
                
                DispatchQueue.main.async {
                    if (self.LoadMoreArray.count == 0) {
                        self.isLoadMore = false
                    } else {
                        self.isLoadMore = true
                        self.myCollectionView?.reloadData()
                    }
                }
                
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure2()
            self.stopSpinner()
        })
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
        self.lblheadername?.text = CommonMessage.RelatedChannels()
    }
    
    //=======Start & Stop Spinner=======//
    func startSpinner()
    {
        self.spinner = SWActivityIndicatorView(frame: CGRect(x:(CommonUtils.screenWidth-60)/2, y:(CommonUtils.screenHeight-60)/2, width: 60, height: 60))
        self.spinner.backgroundColor = UIColor.clear
        self.spinner.lineWidth = 5.0
        self.spinner.color = UIColor(hexString: Colors.getSpinnerColor())!
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
    }
    func stopSpinner()
    {
        self.spinner.stopAnimating()
        self.spinner.removeFromSuperview()
    }
    
    //=======Internet Connection Not Available=======//
    //1.Related Channels
    func InternetConnectionNotAvailable1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myCollectionView?.isHidden = true
            self.getRelatedChannels()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myCollectionView?.isHidden = true
            self.getRelatedChannels()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    //2.Load More Channels
    func InternetConnectionNotAvailable2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getLoadMoreRelatedChannels()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getLoadMoreRelatedChannels()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
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
