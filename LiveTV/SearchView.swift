//
//  SearchView.swift
//  LiveTV
//
//  Created by Apple on 01/08/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SearchView: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,GADInterstitialDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var myTableView : UITableView?
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var lblnodatafound : UILabel?
    var SearchArray = NSMutableArray()
    
    var SearchMoviesArray = NSArray()
    var SearchSeriesArray = NSArray()
    var SearchChannelArray = NSArray()
    var SectionNameArray = NSArray()
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //======Set UITableView Section Name======//
        self.SectionNameArray = [CommonMessage.Movies(), CommonMessage.TVSeries(), CommonMessage.TVChannel()]
        
        //======Get Search List Data======//
        self.myTableView?.isHidden = true
        self.getSearchList()
    }
    
    //===========Get All Search List Data==========//
    func getSearchList()
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
        let searchTEXT : String = UserDefaults.standard.string(forKey: "SEARCH_TEXT")!
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"search_all", "search_text":searchTEXT]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Search List API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("All Search List Responce Data : \(responseObject)")
                self.SearchArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as AnyObject?
                
                //=======Fill Array======//
                //1.Search Movies Arra
                self.SearchMoviesArray = storeArr?.object(forKey: "search_movies") as! NSArray
                print("SearchMoviesArray Count = \(self.SearchMoviesArray.count)")
                //2.Search Series Array
                self.SearchSeriesArray = storeArr?.object(forKey: "search_series") as! NSArray
                print("SearchSeriesArray Count = \(self.SearchSeriesArray.count)")
                //3.Search Channel Array
                self.SearchChannelArray = storeArr?.object(forKey: "search_channels") as! NSArray
                print("SearchChannelArray Count = \(self.SearchChannelArray.count)")
                
                
                //let dict : NSDictionary = ["id" : id as Any]
                    
                //========Add Array Into Search Array=========//
                /*if (self.SearchMoviesArray.count != 0) {
                    let moviesArr = storeArr?.object(forKey: "search_movies") as! NSArray
                    self.SearchArray.add(moviesArr)
                }
                if (self.SearchSeriesArray.count != 0) {
                    let seriesArr = storeArr?.object(forKey: "search_series") as! NSArray
                    self.SearchArray.add(seriesArr)
                }
                if (self.SearchChannelArray.count != 0) {
                    let channelsArr = storeArr?.object(forKey: "search_channels") as! NSArray
                    self.SearchArray.add(channelsArr)
                }
                print("SearchArray Count = \(self.SearchArray.count)")*/
                
                
                let moviesArr = storeArr?.object(forKey: "search_movies") as! NSArray
                self.SearchArray.add(moviesArr)
                let seriesArr = storeArr?.object(forKey: "search_series") as! NSArray
                self.SearchArray.add(seriesArr)
                let channelsArr = storeArr?.object(forKey: "search_channels") as! NSArray
                self.SearchArray.add(channelsArr)
                print("SearchArray Count = \(self.SearchArray.count)")
                
                DispatchQueue.main.async {
                    if (self.SearchArray.count == 0) {
                        self.myTableView?.isHidden = true
                        self.lblnodatafound?.isHidden = false
                    } else {
                        self.myTableView?.isHidden = false
                        self.lblnodatafound?.isHidden = true
                        self.myTableView?.reloadData()
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
    
    
    //============UITableView Delegate & Datasource Methods============//
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.SearchArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0) {
            if (self.SearchMoviesArray.count == 0) {
                return UITableViewCell()
            } else {
                var cell:MovieTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? MovieTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("MovieTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? MovieTableCell
                }
                cell?.setCollectionData(self.SearchMoviesArray as? [Any])
                return cell!
            }
        } else if (indexPath.section == 1) {
            if (self.SearchSeriesArray.count == 0) {
                return UITableViewCell()
            } else {
                var cell:SeriesTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? SeriesTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "SeriesTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("SeriesTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? SeriesTableCell
                }
                cell?.setCollectionData(self.SearchSeriesArray as? [Any])
                return cell!
            }
        } else {
            if (self.SearchChannelArray.count == 0) {
                return UITableViewCell()
            } else {
                var cell:ChannelTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? ChannelTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "ChannelTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("ChannelTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? ChannelTableCell
                }
                cell?.setCollectionData(self.SearchChannelArray as? [Any])
                return cell!
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0) {
            if (self.SearchMoviesArray.count == 0) {
                return nil
            } else {
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 80))
                
                let lblline = UILabel()
                lblline.frame = CGRect.init(x: 10, y: 20, width: 3, height: 30)
                lblline.backgroundColor = UIColor(hexString: Colors.getButtonColor2())
                lblline.layer.cornerRadius = lblline.frame.size.width/2
                lblline.clipsToBounds = true
                headerView.addSubview(lblline)
                
                let lbltitle = UILabel()
                lbltitle.frame = CGRect.init(x: 25, y: 20, width: 200, height: 30)
                lbltitle.text = self.SectionNameArray[section] as? String
                lbltitle.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
                lbltitle.textColor = UIColor(hexString: "#FFFFFF", alpha: 0.7)
                //lbltitle.backgroundColor = UIColor.red
                headerView.addSubview(lbltitle)
                
                let btnseeall = UIButton()
                btnseeall.frame = CGRect.init(x: tableView.frame.width-90, y: 20, width: 80, height: 30)
                btnseeall.setTitle(CommonMessage.ViewAll(), for: .normal)
                btnseeall.contentHorizontalAlignment = .right
                btnseeall.titleLabel?.font =  UIFont(name: "Montserrat-SemiBold", size: 15.0)
                btnseeall.setTitleColor(UIColor(hexString: Colors.getButtonColor2()), for: .normal)
                btnseeall.addTarget(self, action:#selector(self.OnViewAllClick), for: .touchUpInside)
                btnseeall.tag = section
                headerView.addSubview(btnseeall)
                
                return headerView
            }
        } else if (section == 1) {
            if (self.SearchSeriesArray.count == 0) {
                return nil
            } else {
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 80))
                
                let lblline = UILabel()
                lblline.frame = CGRect.init(x: 10, y: 20, width: 3, height: 30)
                lblline.backgroundColor = UIColor(hexString: Colors.getButtonColor2())
                lblline.layer.cornerRadius = lblline.frame.size.width/2
                lblline.clipsToBounds = true
                headerView.addSubview(lblline)
                
                let lbltitle = UILabel()
                lbltitle.frame = CGRect.init(x: 25, y: 20, width: 200, height: 30)
                lbltitle.text = self.SectionNameArray[section] as? String
                lbltitle.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
                lbltitle.textColor = UIColor(hexString: "#FFFFFF", alpha: 0.7)
                //lbltitle.backgroundColor = UIColor.red
                headerView.addSubview(lbltitle)
                
                let btnseeall = UIButton()
                btnseeall.frame = CGRect.init(x: tableView.frame.width-90, y: 20, width: 80, height: 30)
                btnseeall.setTitle(CommonMessage.ViewAll(), for: .normal)
                btnseeall.contentHorizontalAlignment = .right
                btnseeall.titleLabel?.font =  UIFont(name: "Montserrat-SemiBold", size: 15.0)
                btnseeall.setTitleColor(UIColor(hexString: Colors.getButtonColor2()), for: .normal)
                btnseeall.addTarget(self, action:#selector(self.OnViewAllClick), for: .touchUpInside)
                btnseeall.tag = section
                headerView.addSubview(btnseeall)
                
                return headerView
            }
        } else if (section == 2) {
            if (self.SearchChannelArray.count == 0) {
                return nil
            } else {
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 80))
                
                let lblline = UILabel()
                lblline.frame = CGRect.init(x: 10, y: 20, width: 3, height: 30)
                lblline.backgroundColor = UIColor(hexString: Colors.getButtonColor2())
                lblline.layer.cornerRadius = lblline.frame.size.width/2
                lblline.clipsToBounds = true
                headerView.addSubview(lblline)
                
                let lbltitle = UILabel()
                lbltitle.frame = CGRect.init(x: 25, y: 20, width: 200, height: 30)
                lbltitle.text = self.SectionNameArray[section] as? String
                lbltitle.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
                lbltitle.textColor = UIColor(hexString: "#FFFFFF", alpha: 0.7)
                //lbltitle.backgroundColor = UIColor.red
                headerView.addSubview(lbltitle)
                
                let btnseeall = UIButton()
                btnseeall.frame = CGRect.init(x: tableView.frame.width-90, y: 20, width: 80, height: 30)
                btnseeall.setTitle(CommonMessage.ViewAll(), for: .normal)
                btnseeall.contentHorizontalAlignment = .right
                btnseeall.titleLabel?.font =  UIFont(name: "Montserrat-SemiBold", size: 15.0)
                btnseeall.setTitleColor(UIColor(hexString: Colors.getButtonColor2()), for: .normal)
                btnseeall.addTarget(self, action:#selector(self.OnViewAllClick), for: .touchUpInside)
                btnseeall.tag = section
                headerView.addSubview(btnseeall)
                
                return headerView
            }
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0) {
            if (self.SearchMoviesArray.count == 0) {
                return 0
            } else {
                return 70
            }
        } else if (section == 1) {
            if (self.SearchSeriesArray.count == 0) {
                return 0
            } else {
                return 70
            }
        } else if (section == 2) {
            if (self.SearchChannelArray.count == 0) {
                return 0
            } else {
                return 70
            }
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0) {
            if (self.SearchMoviesArray.count == 0) {
                return 0
            } else {
                return CommonUtils.screenWidth/2.5
            }
        } else if (indexPath.section == 1) {
            if (self.SearchSeriesArray.count == 0) {
                return 0
            } else {
                return CommonUtils.screenWidth/2.5
            }
        } else if (indexPath.section == 2) {
            if (self.SearchChannelArray.count == 0) {
                return 0
            } else {
                return CommonUtils.screenWidth/3.5
            }
        } else {
            return 0
        }
    }
    @objc func OnViewAllClick(sender: UIButton!)
    {
        switch (sender.tag)
        {
            case 0:
                self.CallSearchMoviesViewController()
                break
            case 1:
                self.CallSearchSeriesViewController()
                break
            case 2:
                self.CallSearchChannelsViewController()
                break
            default:
                break
        }
    }
    
    func CallSearchMoviesViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = SearchMovies(nibName: "SearchMovies_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = SearchMovies(nibName: "SearchMovies_iPhoneX", bundle: nil)
        } else {
            view = SearchMovies(nibName: "SearchMovies", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallSearchSeriesViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = SearchSeries(nibName: "SearchSeries_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = SearchSeries(nibName: "SearchSeries_iPhoneX", bundle: nil)
        } else {
            view = SearchSeries(nibName: "SearchSeries", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallSearchChannelsViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = SearchChannels(nibName: "SearchChannels_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = SearchChannels(nibName: "SearchChannels_iPhoneX", bundle: nil)
        } else {
            view = SearchChannels(nibName: "SearchChannels", bundle: nil)
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
                self.myTableView?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-75)
            } else if (CommonUtils.screenHeight >= 812) {
                
            } else {
                self.myTableView?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-75)
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
        self.lblheadername?.text = CommonMessage.Search()
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
            self.myTableView?.isHidden = true
            self.getSearchList()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myTableView?.isHidden = true
            self.getSearchList()
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
