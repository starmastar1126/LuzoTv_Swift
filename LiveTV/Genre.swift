//
//  Genre.swift
//  LiveTV
//
//  Created by Apple on 16/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds

class Genre: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GADBannerViewDelegate,GADInterstitialDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var myCollectionView : UICollectionView?
    @IBOutlet var lblnodatafound : UILabel?
    var GenreArray = NSMutableArray()
    var LoadMoreArray = NSMutableArray()
    
    var pageNo:Int = 1
    var isLoadMore:Bool = false
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "GenreCell_iPad", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "GenreCell", bundle:nil)
            self.myCollectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        //flowLayout.minimumLineSpacing = 0
        //flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.myCollectionView?.collectionViewLayout = flowLayout
        
        //======Get Genre Movies Data======//
        self.myCollectionView?.isHidden = true
        self.getGenreMovies()
    }
    
    //===========Get Genre Movies Data==========//
    func getGenreMovies()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getGenreMovieData(encodedString)
        } else {
            self.InternetConnectionNotAvailable1()
        }
    }
    func getGenreMovieData(_ requesturl: String?)
    {
        let pageNo:String = String(self.pageNo)
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_genre", "page":pageNo]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Genre Movies API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Genre Movie Responce Data : \(responseObject)")
                self.GenreArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.GenreArray.add(storeDict as Any)
                    }
                }
                print("GenreArray Count = \(self.GenreArray.count)")
                
                DispatchQueue.main.async {
                    if (self.GenreArray.count == 0) {
                        self.myCollectionView?.isHidden = true
                        self.lblnodatafound?.isHidden = false
                    } else {
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
        return self.GenreArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! GenreCell
        
        let genre_image = (self.GenreArray.value(forKey: "genre_image") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = genre_image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        cell.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        let genre_name = (self.GenreArray.value(forKey: "genre_name") as! NSArray).object(at: indexPath.row) as? String
        cell.lblGenreName?.text = genre_name
        
        //Lazy loading
        if (isLoadMore) {
            if (indexPath.row == self.GenreArray.count-1) {
                self.pageNo = self.pageNo + 1;
                self.getLoadMoreGenreMovies()
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/4.5)
        } else {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/4.5)
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let genreID = (self.GenreArray.value(forKey: "id") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(genreID, forKey: "GENRE_ID")
        let genreNAME = (self.GenreArray.value(forKey: "genre_name") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(genreNAME, forKey: "GENRE_NAME")
        self.CallGenreMovieListViewController()
    }
    
    //===========Get Load More Genre Movies Data==========//
    func getLoadMoreGenreMovies()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getLoadMoreGenreChannelData(encodedString)
        } else {
            self.InternetConnectionNotAvailable2()
        }
    }
    func getLoadMoreGenreChannelData(_ requesturl: String?)
    {
        let pageNo:String = String(self.pageNo)
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_language", "page":pageNo]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Load More Latest Channel API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Load More Language Movies Responce Data : \(responseObject)")
                self.LoadMoreArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.GenreArray.add(storeDict as Any)
                        self.LoadMoreArray.add(storeDict as Any)
                    }
                }
                print("GenreArray Count = \(self.GenreArray.count)")
                
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
    
    
    func CallGenreMovieListViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = GenreMovieList(nibName: "GenreMovieList_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = GenreMovieList(nibName: "GenreMovieList_iPhoneX", bundle: nil)
        } else {
            view = GenreMovieList(nibName: "GenreMovieList", bundle: nil)
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
                self.myCollectionView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-75)
            } else if (CommonUtils.screenHeight >= 812) {
                self.myCollectionView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-100)
            } else {
                self.myCollectionView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-75)
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
    
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //1.Background Color
        self.view.backgroundColor = UIColor(hexString:Colors.getBackgroundColor())
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
    //1.Genre Movies
    func InternetConnectionNotAvailable1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myCollectionView?.isHidden = true
            self.getGenreMovies()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myCollectionView?.isHidden = true
            self.getGenreMovies()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    //2.Load More Genre Movies
    func InternetConnectionNotAvailable2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getLoadMoreGenreMovies()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getLoadMoreGenreMovies()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
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
