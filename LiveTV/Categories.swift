//
//  Categories.swift
//  LiveTV
//
//  Created by Apple on 13/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds

class Categories: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,GADBannerViewDelegate,GADInterstitialDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var myCollectionView : UICollectionView?
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var lblnodatafound : UILabel?
    var CategoriesArray = NSMutableArray()
    var LoadMoreArray = NSMutableArray()

    @IBOutlet var btnsearch : UIButton?
    @IBOutlet var searchBar : UISearchBar?
    @IBOutlet var btnback : UIButton?
    @IBOutlet var btnbacksearch : UIButton?

    var pageNo:Int = 1
    var isLoadMore:Bool = false
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "CategoryCell_iPad", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "CategoryCell", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        //flowLayout.minimumLineSpacing = 0
        //flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.myCollectionView?.collectionViewLayout = flowLayout
        
        //======Get TV Categories Data======//
        self.myCollectionView?.isHidden = true
        self.getTVCategories()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.searchBar?.resignFirstResponder()
        self.searchBar?.isHidden = true
        self.btnbacksearch?.isHidden = true
        self.searchBar?.text = ""
        self.btnback?.isHidden = false
    }
    
    //===========Get TV Categories Data==========//
    func getTVCategories()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getTVCategoriesData(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getTVCategoriesData(_ requesturl: String?)
    {
        let pageNo:String = String(self.pageNo)
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_category", "page":pageNo]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("TV Categories API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("TV Categories Responce Data : \(responseObject)")
                self.CategoriesArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.CategoriesArray.add(storeDict as Any)
                    }
                }
                print("CategoriesArray Count = \(self.CategoriesArray.count)")
                
                DispatchQueue.main.async {
                    if (self.CategoriesArray.count == 0) {
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
            self.Networkfailure()
            self.stopSpinner()
        })
    }
    
    //============UICollectionView Delegate & Datasource Methods============//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.CategoriesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CategoryCell
        
        let strimgpath : String? = (self.CategoriesArray.value(forKey: "category_image") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = strimgpath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        cell.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        cell.lblCatName?.text = (self.CategoriesArray.value(forKey: "category_name") as! NSArray).object(at: indexPath.row) as? String
        
        //Lazy loading
        if (isLoadMore) {
            if (indexPath.row == self.CategoriesArray.count-1) {
                self.pageNo = self.pageNo + 1;
                self.getLoadMoreTVCategories()
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/2.5)
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
        let catID = (self.CategoriesArray.value(forKey: "cid") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(catID, forKey: "CAT_ID")
        let catNAME = (self.CategoriesArray.value(forKey: "category_name") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(catNAME, forKey: "CAT_NAME")
        self.CallCatListViewController()
    }
    func CallCatListViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = CategoryList(nibName: "CategoryList_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = CategoryList(nibName: "CategoryList_iPhoneX", bundle: nil)
        } else {
            view = CategoryList(nibName: "CategoryList", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    //===========Get Load More TV Categories Data==========//
    func getLoadMoreTVCategories()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getLoadMoreTVCategoriesData(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getLoadMoreTVCategoriesData(_ requesturl: String?)
    {
        let pageNo:String = String(self.pageNo)
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_category", "page":pageNo]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Load More TV Categories API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("TV Categories Responce Data : \(responseObject)")
                self.LoadMoreArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.CategoriesArray.add(storeDict as Any)
                        self.LoadMoreArray.add(storeDict as Any)
                    }
                }
                print("CategoriesArray Count = \(self.CategoriesArray.count)")
                
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
            self.Networkfailure()
            self.stopSpinner()
        })
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
        self.lblheadername?.text = CommonMessage.TVCategories()
        self.searchBar?.barTintColor = UIColor.clear
        //5.UISearchbar Clear Background Color
//        for subView in (self.searchBar?.subviews)! {
//            for view in subView.subviews {
//                if view.isKind(of: NSClassFromString("UISearchBarBackground")!) {
//                    let imageView = view as! UIImageView
//                    imageView.removeFromSuperview()
//                }
//            }
//        }
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
    func InternetConnectionNotAvailable()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getTVCategories()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getTVCategories()
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
