//
//  HomeViewController.swift
//  LiveTV
//
//  Created by Apple on 03/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import AdSupport
import PersonalizedAdConsent
import GoogleMobileAds
import AVFoundation

class HomeViewController: UIViewController,VKSideMenuDelegate,VKSideMenuDataSource,LCBannerViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate
{
    var spinner: SWActivityIndicatorView!
    
    var menuLeft: VKSideMenu?
    var LeftMenuArray : NSArray = NSMutableArray()
    var LeftMenuIconArray : NSArray = NSMutableArray()
    
    @IBOutlet private weak var myScrollview: UIScrollView!
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var btnleftmenu : UIButton?
    
    @IBOutlet var btnsearch : UIButton?
    @IBOutlet var searchBar : UISearchBar?
    @IBOutlet var btnbacksearch : UIButton?
    
    var HomeArray = NSMutableArray()
    var SliderArray = NSArray()
    var RecentlyViewedArray = NSArray()
    var TVCategoryArray = NSArray()
    var LatestMoviesArray = NSArray()
    var TVSeriesArray = NSArray()
    var LatestChannelArray = NSArray()
    var SectionNameArray = NSArray()
    var RewardVideosArray = NSArray()
    
    @IBOutlet var myView : UIView?
    @IBOutlet var myTableView : UITableView?
    var sliderHeight : CGFloat = 0.0
    var tableHeight : CGFloat = 0.0
    
    @IBOutlet weak var baseBannerView: LCBannerView!
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var interstitial: GADInterstitial!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //========PackageName Notification========//
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivePackageNameNotification(_:)), name: NSNotification.Name("PackageNameNotification"), object: nil)
        
        //========Admob GDPR Banner========//
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveAdmobNotification(_:)), name: NSNotification.Name("ADMOB"), object: nil)
        let isADMOB = UserDefaults.standard.bool(forKey: "ADMOB")
        if (isADMOB) {
            self.getAdmobIDs()
        }
        
        //======Call Category Cell Notification======//
        //1.Recently Viewed Cell Click
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnRecentlyViewedCellClick), name: NSNotification.Name(rawValue: "RecentlyViewedCellClick"), object: nil)
        //2.Category Cell Click
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnCategoryCellClick), name: NSNotification.Name(rawValue: "CategoryCellClick"), object: nil)
        //3.Series Cell Click
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnSeriesCellClick), name: NSNotification.Name(rawValue: "SeriesCellClick"), object: nil)
        //4.Movie Cell Click
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnMovieCellClick), name: NSNotification.Name(rawValue: "MovieCellClick"), object: nil)
        //5.Channel Cell Click
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnChannelCellClick), name: NSNotification.Name(rawValue: "ChannelCellClick"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnRewardCellClick), name: NSNotification.Name(rawValue: "RewardCellClick"), object: nil)
        
        //========Get Home Page Data========//
        self.myScrollview.isHidden = true
        self.getHomeData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.searchBar?.resignFirstResponder()
        self.searchBar?.isHidden = true
        self.btnbacksearch?.isHidden = true
        self.searchBar?.text = ""
        self.btnleftmenu?.isHidden = false
        
        //=========VKSide Left Menu Inialization=========//
        let isLogin = UserDefaults.standard.bool(forKey: "LOGIN")
        if (isLogin) {
            self.LeftMenuArray = [CommonMessage.Home(),
                                  CommonMessage.Movies(),
                                  CommonMessage.RewardVideos(),
                                  CommonMessage.GetRewards(),
                                  CommonMessage.TVSeries(),
                                  CommonMessage.TVChannel(),
                                  CommonMessage.Favourite(),
                                  CommonMessage.Profile(),
                                  CommonMessage.Settings(),
                                  CommonMessage.Logout()]
            self.LeftMenuIconArray = ["home", "moview","rewardvideos","getreward", "series", "channel", "favourite", "profile", "setting", "logout"]
        } else {
            self.LeftMenuArray = [CommonMessage.Home(), CommonMessage.Movies(), CommonMessage.TVSeries(), CommonMessage.TVChannel(), CommonMessage.Favourite(), CommonMessage.Settings(), CommonMessage.Login()]
            self.LeftMenuIconArray = ["home", "moview", "series", "channel", "favourite", "setting", "login"]
        }
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            self.menuLeft = VKSideMenu(size: 400, andDirection:.fromLeft)
        } else {
            self.menuLeft = VKSideMenu(size: 290, andDirection:.fromLeft)
        }
        self.menuLeft?.dataSource = self
        self.menuLeft?.delegate = self
        self.menuLeft?.addSwipeGestureRecognition(self.view)
    }
    
    //===========Get Home Screen Data==========//
    func getHomeData()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            self.getRewardVideos()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                 self.getHomePageData(encodedString)
            }
           
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getHomePageData(_ requesturl: String?)
    {
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_home"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Home Page API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Home Responce Data : \(responseObject)")
                self.HomeArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as AnyObject?
                
                //1.Slider Array
                self.SliderArray = storeArr?.object(forKey: "banner") as! NSArray
                print("SliderArray Count = \(self.SliderArray.count)")
                
                //2.TV Category Array
                self.TVCategoryArray = storeArr?.object(forKey: "cat_list") as! NSArray
                print("TVCategoryArray Count = \(self.TVCategoryArray.count)")
                //3.Latest Movies Array
                self.LatestMoviesArray = storeArr?.object(forKey: "latest_movies") as! NSArray
                print("LatestMoviesArray Count = \(self.LatestMoviesArray.count)")
                //4.TV Series Array
                self.TVSeriesArray = storeArr?.object(forKey: "tv_series") as! NSArray
                print("TVSeriesArray Count = \(self.TVSeriesArray.count)")
                
                //self.RewardVideosArray = storeArr?.object(forKey: "tv_series") as! NSArray
                print("Reward Array Count = \(self.RewardVideosArray.count)")
                //5.Latest Channel Array
                self.LatestChannelArray = storeArr?.object(forKey: "latest_channels") as! NSArray
                print("LatestChannelArray Count = \(self.LatestChannelArray.count)")
                //6.Recently Viewed Array
                self.getRecentlyViewedData()
                
                if (self.RecentlyViewedArray.count != 0) {
                    self.RecentlyViewedArray =  NSMutableArray(array: self.RecentlyViewedArray.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
                    self.HomeArray.add(self.RecentlyViewedArray)
                }
            
                let tvCategoryArr = storeArr?.object(forKey: "cat_list") as! NSArray
                self.HomeArray.add(tvCategoryArr)
                
                let latestMovieArr = storeArr?.object(forKey: "latest_movies") as! NSArray
                self.HomeArray.add(latestMovieArr)
            
                self.HomeArray.add(self.RewardVideosArray)
                
                let latestChannelArr = storeArr?.object(forKey: "latest_channels") as! NSArray
                self.HomeArray.add(latestChannelArr)
                
                print("HomeArray Count = \(self.HomeArray.count)")
                
                //8.Featured Slider
                self.sliderHeight = CommonUtils.screenWidth/1.7
                self.SetSliderImageViewData()
                
                //9.Reload TableView Data
                DispatchQueue.main.async {
                    self.myTableView?.reloadData()
                    self.tableHeight = (self.myTableView?.contentSize.height)!
                    print(self.tableHeight)
                    self.SetScrollViewHeight()
                   // self.getRewardVideos()
                }
                
                self.stopSpinner()
                self.myScrollview.isHidden = false
            }
        }, failure: { operation, error in
            self.Networkfailure()
            self.stopSpinner()
        })
    }
    
    
    //======Get Recently Viewed Data======//
    func getRecentlyViewedData()
    {
        self.RecentlyViewedArray = Singleton.getInstance().getAllRecentlyViewedQueryData()
        print("RecentlyViewedArray Count = \(self.RecentlyViewedArray.count)")
        
        //======Set UITableView Section Name======//
        if (self.RecentlyViewedArray.count == 0) {
            self.SectionNameArray = [CommonMessage.RewardVideos(),CommonMessage.TVCategories(), CommonMessage.LatestMovies(), CommonMessage.TVSeries(), CommonMessage.LatestChannel()]
        } else {
            self.SectionNameArray = [CommonMessage.RewardVideos(),CommonMessage.RecentlyViewed(),CommonMessage.TVCategories(), CommonMessage.LatestMovies(), CommonMessage.TVSeries(), CommonMessage.LatestChannel()]
        }
    }
    
    
    //============Set Slider ImageView Data============//
    func SetSliderImageViewData()
    {
        self.baseBannerView.addSubview(self.AddBannerView(bannerView: self.baseBannerView, imageUrlArray: (self.SliderArray.value(forKey: "slide_image") as! [String]), titleArray: (self.SliderArray.value(forKey: "title") as! [String]), subtitleArray: (self.SliderArray.value(forKey: "sub_title") as! [String]), idArray: (self.SliderArray.value(forKey: "id") as! [String]), typeArray: (self.SliderArray.value(forKey: "type") as! [String])))
    }
    func AddBannerView(bannerView: UIView, imageUrlArray: [String], titleArray: [String], subtitleArray: [String], idArray: [String], typeArray: [String]) -> LCBannerView
    {
        let banner = LCBannerView.init(frame: CGRect(x: 0, y: 0, width: bannerView.frame.size.width, height: self.sliderHeight), delegate: self, imageURLs: imageUrlArray, titleArray: titleArray, subTitleArray: subtitleArray, idArray: idArray, typeArray: typeArray, placeholderImageName: "placeholder_big", timeInterval: Settings.SetHomeSliderTime(), currentPageIndicatorTintColor: UIColor(hexString: Colors.getButtonColor2()), pageIndicatorTintColor: UIColor.lightGray)
        banner?.clipsToBounds = true
        return banner!
    }
    func bannerView(_ bannerView: LCBannerView?, didScrollTo index: Int)
    {
        //print("Slider Scroll Index = \(index)")
    }
    func bannerView(_ bannerView: LCBannerView?, didClickedImageIndex index: Int)
    {
        let bannerTYPE : String = ((self.SliderArray.value(forKey: "type") as! NSArray).object(at: index) as? String)!
        if (bannerTYPE == "series") {
            let seriesID = (self.SliderArray.value(forKey: "id") as! NSArray).object(at: index) as? String
            UserDefaults.standard.set(seriesID, forKey: "SERIES_ID")
            let seriesNAME = (self.SliderArray.value(forKey: "title") as! NSArray).object(at: index) as? String
            UserDefaults.standard.set(seriesNAME, forKey: "SERIES_NAME")
            self.CallAdmobInterstitial()
            self.CallDetailSeriesViewController()
        } else if (bannerTYPE == "movie") {
            let movieID = (self.SliderArray.value(forKey: "id") as! NSArray).object(at: index) as? String
            UserDefaults.standard.set(movieID, forKey: "MOVIE_ID")
            let movieNAME = (self.SliderArray.value(forKey: "title") as! NSArray).object(at: index) as? String
            UserDefaults.standard.set(movieNAME, forKey: "MOVIE_NAME")
            self.CallAdmobInterstitial()
            self.CallDetailMovieViewController()
        } else if (bannerTYPE == "channel") {
            let channelID = (self.SliderArray.value(forKey: "id") as! NSArray).object(at: index) as? String
            UserDefaults.standard.set(channelID, forKey: "CHANNEL_ID")
            let channelNAME = (self.SliderArray.value(forKey: "title") as! NSArray).object(at: index) as? String
            UserDefaults.standard.set(channelNAME, forKey: "CHANNEL_NAME")
            self.CallAdmobInterstitial()
            self.CallDetailChannelViewController()
        }
    }
    
    
    //============UITableView Delegate & Datasource Methods============//
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.HomeArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (self.RecentlyViewedArray.count == 0) {
            if (indexPath.section == 0) {
                var cell:RewardVideoTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? RewardVideoTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "RewardVideoTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("RewardVideoTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? RewardVideoTableCell
                }
                cell?.setCollectionData(self.RewardVideosArray as? [Any])
                return cell!
            } else if (indexPath.section == 1) {
                var cell:CategoryTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? CategoryTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "CategoryTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("CategoryTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? CategoryTableCell
                }
                cell?.setCollectionData(self.TVCategoryArray as? [Any])
                return cell!
            } else if (indexPath.section == 2) {
                var cell:MovieTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? MovieTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("MovieTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? MovieTableCell
                }
                cell?.setCollectionData(self.LatestMoviesArray as? [Any])
                return cell!
            } else if (indexPath.section == 3) {
                var cell:SeriesTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? SeriesTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "SeriesTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("SeriesTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? SeriesTableCell
                }
                cell?.setCollectionData(self.TVSeriesArray as? [Any])
                return cell!
            } else if (indexPath.section == 4) {
                var cell:ChannelTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? ChannelTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "ChannelTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("ChannelTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? ChannelTableCell
                }
                cell?.setCollectionData(self.LatestChannelArray as? [Any])
                return cell!
            } else {
                var cell:CategoryTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? CategoryTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "CategoryTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("CategoryTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? CategoryTableCell
                }
                cell?.setCollectionData(self.TVCategoryArray as? [Any])
                return cell!
            }
        } else {
            if (indexPath.section == 0) {
                var cell:RewardVideoTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? RewardVideoTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "RewardVideoTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("RewardVideoTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? RewardVideoTableCell
                }
                cell?.setCollectionData(self.RewardVideosArray as? [Any])
                return cell!
            } else if (indexPath.section == 2) {
                var cell:CategoryTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? CategoryTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "CategoryTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("CategoryTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? CategoryTableCell
                }
                cell?.setCollectionData(self.TVCategoryArray as? [Any])
                return cell!
            }else if (indexPath.section == 1) {
                var cell:RecentlyViewedTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? RecentlyViewedTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "RecentlyViewedTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("RecentlyViewedTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? RecentlyViewedTableCell
                }
                cell?.setCollectionData(self.RecentlyViewedArray as? [Any])
                return cell!
            } else if (indexPath.section == 3) {
                var cell:MovieTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? MovieTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("MovieTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? MovieTableCell
                }
                cell?.setCollectionData(self.LatestMoviesArray as? [Any])
                return cell!
            } else if (indexPath.section == 4) {
                var cell:SeriesTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? SeriesTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "SeriesTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("SeriesTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? SeriesTableCell
                }
                cell?.setCollectionData(self.TVSeriesArray as? [Any])
                return cell!
            } else if (indexPath.section == 5) {
                var cell:ChannelTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? ChannelTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "ChannelTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("ChannelTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? ChannelTableCell
                }
                cell?.setCollectionData(self.LatestChannelArray as? [Any])
                return cell!
            } else {
                var cell:CategoryTableCell? = tableView.dequeueReusableCell(withIdentifier:"cell") as? CategoryTableCell
                if (cell == nil) {
                    tableView.register(UINib.init(nibName: "CategoryTableCell", bundle: nil), forCellReuseIdentifier: "cell")
                    let arrNib:Array = Bundle.main.loadNibNamed("CategoryTableCell",owner: self, options: nil)!
                    cell = arrNib.first as? CategoryTableCell
                }
                cell?.setCollectionData(self.TVCategoryArray as? [Any])
                return cell!
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (self.RecentlyViewedArray.count == 0) {
            if (indexPath.section == 0) {
                return CommonUtils.screenWidth/3.5
            } else if (indexPath.section == 1) {
                return CommonUtils.screenWidth/3.5
            } else if (indexPath.section == 2) {
                return CommonUtils.screenWidth/2.5
            } else if (indexPath.section == 3) {
                return CommonUtils.screenWidth/2.5
            } else if (indexPath.section == 4) {
                return CommonUtils.screenWidth/3.5
            } else {
                return 145
            }
        } else {
            if (indexPath.section == 0) {
                return CommonUtils.screenWidth/3.5
            } else if (indexPath.section == 1) {
                return CommonUtils.screenWidth/2.5
            } else if (indexPath.section == 2) {
                return CommonUtils.screenWidth/3.5
            } else if (indexPath.section == 3) {
                return CommonUtils.screenWidth/2.5
            } else if (indexPath.section == 4) {
                return CommonUtils.screenWidth/2.5
            } else if (indexPath.section == 5) {
                return CommonUtils.screenWidth/3.5
            } else {
                return 145
            }
        }
    }
    @objc func OnViewAllClick(sender: UIButton!)
    {
        if (self.RecentlyViewedArray.count == 0) {
            switch (sender.tag)
            {
            case 0:
                self.CallWatchRewardVideosViewController()
                break
            case 1:
                self.CallCategoriesViewController()
                break
            case 2:
                self.CallLatestMoviesViewController()
                break
            case 3:
                self.CallTVSeriesViewController()
                break
            case 4:
                self.CallLatestChannelViewController()
                break
            default:
                break
            }
        } else {
            switch (sender.tag)
            {
            case 0:
                self.CallWatchRewardVideosViewController()
                break
            case 1:
                self.CallRecentlyViewedViewController()
                break
            case 2:
                self.CallCategoriesViewController()
                break
            case 3:
                self.CallLatestMoviesViewController()
                break
            case 4:
                self.CallTVSeriesViewController()
                break
            case 5:
                self.CallLatestChannelViewController()
                break
            default:
                break
            }
        }
    }
    
    
    //============Set ScrollView Content Height============//
    func SetScrollViewHeight()
    {
        if (self.RecentlyViewedArray.count == 0) {
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                //1.Set TableView Height
                self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+150+550)
                
                //2.Set MyView Height
                self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+350+550)
                
                //3.Set UIScrollView Content Size
                self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
            } else {
                //1.Set TableView Height
                self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+150)
                
                //2.Set MyView Height
                self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+350)
                
                //3.Set UIScrollView Content Size
                self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
            }
        } else {
            let isGDPR_STATUS: Bool = UserDefaults.standard.bool(forKey: "GDPR_STATUS")
            if (isGDPR_STATUS) {
                if (UI_USER_INTERFACE_IDIOM() == .pad) {
                    //1.Set TableView Height
                    self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+250+710)
                    
                    //2.Set MyView Height
                    self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+450+710)
                    
                    //3.Set UIScrollView Content Size
                    self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
                } else if (CommonUtils.screenHeight >= 812) {
                    //1.Set TableView Height
                    self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+250)
                    
                    //2.Set MyView Height
                    self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+450)
                    
                    //3.Set UIScrollView Content Size
                    self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
                } else {
                    //1.Set TableView Height
                    self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+250)
                    
                    //2.Set MyView Height
                    self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+450)
                    
                    //3.Set UIScrollView Content Size
                    self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
                }
            } else {
                if (UI_USER_INTERFACE_IDIOM() == .pad) {
                    //1.Set TableView Height
                    self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+250+710)
                    
                    //2.Set MyView Height
                    self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+450+710)
                    
                    //3.Set UIScrollView Content Size
                    self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
                } else if (CommonUtils.screenHeight >= 812) {
                    //1.Set TableView Height
                    self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+250)
                    
                    //2.Set MyView Height
                    self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+450)
                    
                    //3.Set UIScrollView Content Size
                    self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
                } else {
                    //1.Set TableView Height
                    self.myTableView?.frame = CGRect(x: 0, y: self.sliderHeight+20, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+250)
                    
                    //2.Set MyView Height
                    self.myView?.frame = CGRect(x: 0, y: 0, width: CommonUtils.screenWidth, height: self.sliderHeight+20+self.tableHeight+450)
                    
                    //3.Set UIScrollView Content Size
                    self.myScrollview?.contentSize = CGSize(width: CommonUtils.screenWidth, height: (self.myView?.frame.size.height)!)
                }
            }
        }
    }
    
    
    //======Call Recently Viewed Cell Notification======//
    @objc private func OnRecentlyViewedCellClick(notification: NSNotification)
    {
        let rID = notification.userInfo?["id"]
        let rNAME = notification.userInfo?["title"]
        let isType:String = notification.userInfo?["type"] as! String
        if (isType == "channel") {
            UserDefaults.standard.set(rID, forKey: "CHANNEL_ID")
            UserDefaults.standard.set(rNAME, forKey: "CHANNEL_NAME")
            self.CallAdmobInterstitial()
            self.CallDetailChannelViewController()
        } else if (isType == "series") {
            UserDefaults.standard.set(rID, forKey: "SERIES_ID")
            UserDefaults.standard.set(rNAME, forKey: "SERIES_NAME")
            self.CallAdmobInterstitial()
            self.CallDetailSeriesViewController()
        } else if (isType == "movie") {
            UserDefaults.standard.set(rID, forKey: "MOVIE_ID")
            UserDefaults.standard.set(rNAME, forKey: "MOVIE_NAME")
            self.CallAdmobInterstitial()
            self.CallDetailMovieViewController()
        }
    }
    
    
    //======Call Category Cell Notification======//
    @objc private func OnCategoryCellClick(notification: NSNotification)
    {
        let catID = notification.userInfo?["cid"]
        UserDefaults.standard.set(catID, forKey: "CAT_ID")
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
    
    //======Call Movie Cell Notification======//
    @objc private func OnMovieCellClick(notification: NSNotification)
    {
        self.CallAdmobInterstitial()
        self.CallDetailMovieViewController()
    }
    
    //======Call Series Cell Notification======//
    @objc private func OnSeriesCellClick(notification: NSNotification)
    {
        self.CallAdmobInterstitial()
        self.CallDetailSeriesViewController()
    }
    //======Call Series Cell Notification======//
    @objc private func OnRewardCellClick(notification: NSNotification)
    {
        self.CallAdmobInterstitial()
        self.CallWatchRewardVideosViewController()
    }
    
    //======Call Channel Cell Notification======//
    @objc private func OnChannelCellClick(notification: NSNotification)
    {
        self.CallAdmobInterstitial()
        self.CallDetailChannelViewController()
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RecentlyViewedCellClick"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CategoryCellClick"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SeriesCellClick"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "MovieCellClick"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ChannelCellClick"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RewardCellClick"), object: nil)
    }
    
    //============Left Menu Button Click============//
    @IBAction func OnLeftMenuClick(sender:UIButton)
    {
        self.menuLeft?.show()
    }
    func numberOfSections(in sideMenu: VKSideMenu!) -> Int
    {
        return 1
    }
    func sideMenu(_ sideMenu: VKSideMenu!, numberOfRowsInSection section: Int) -> Int
    {
        return LeftMenuArray.count
    }
    func sideMenu(_ sideMenu: VKSideMenu!, itemForRowAt indexPath: IndexPath!) -> VKSideMenuItem!
    {
        let item = VKSideMenuItem()
        let imgname = LeftMenuIconArray[indexPath.row] as? String
        item.icon = UIImage(named: imgname ?? "")
        item.title = (LeftMenuArray[indexPath.row] as! String)
        return item
    }
    func sideMenuDidShow(_ sideMenu: VKSideMenu?)
    {
        var menu = ""
        if sideMenu == menuLeft {
            menu = "LEFT"
        }
        print("\(menu) VKSideMenue did show")
    }
    func sideMenuDidHide(_ sideMenu: VKSideMenu?)
    {
        var menu = ""
        if sideMenu == menuLeft {
            menu = "LEFT"
        }
        print("\(menu) VKSideMenue did hide")
    }
    func sideMenu(_ sideMenu: VKSideMenu?, titleForHeaderInSection section: Int) -> String?
    {
        return nil
    }
    func sideMenu(_ sideMenu: VKSideMenu?, didSelectRowAt indexPath: IndexPath?)
    {
        let isLogin = UserDefaults.standard.bool(forKey: "LOGIN")
        if (isLogin) {
            switch (indexPath?.row)
            {
                case 0:
                    print("Home Click")
                    break
                case 1:
                    self.CallMovieViewController()
                    break
                case 2:
                    self.CallWatchRewardVideosViewController()
                    break
                case 3:
                    self.CallGetRewardViewController()
                    break
                case 4:
                    self.CallTVSeriesViewController()
                    break
                case 5:
                    self.CallTVChannelViewController()
                    break
                case 6:
                    self.CallFavouriteViewController()
                    break
                case 7:
                    self.CallProfileViewController()
                    break
                case 8:
                    self.CallSettingViewController()
                    break
                case 9:
                    self.CallLogoutViewController()
                    break;
                
                default:
                    break
            }
        } else {
            switch (indexPath?.row)
            {
                case 0:
                    print("Home Click")
                    break
                case 1:
                    self.CallMovieViewController()
                    break
                case 2:
                    self.CallTVSeriesViewController()
                    break
                case 3:
                    self.CallTVChannelViewController()
                    break
                case 4:
                    self.CallFavouriteViewController()
                    break
                case 5:
                    self.CallSettingViewController()
                    break
                case 6:
                    self.CallLoginViewController()
                    break
                default:
                    break
            }
        }
    }
    
    func CallMovieViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = Movies(nibName: "Movies_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = Movies(nibName: "Movies_iPhoneX", bundle: nil)
        } else {
            view = Movies(nibName: "Movies", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    func CallGetRewardViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = GetRewards(nibName: "GetRewards_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = GetRewards(nibName: "GetRewards_iPhoneX", bundle: nil)
        } else {
            view = GetRewards(nibName: "GetRewards", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    func CallWatchRewardVideosViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = WatchRewardVideos(nibName: "WatchRewardVideos_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = WatchRewardVideos(nibName: "WatchRewardVideos_iPhoneX", bundle: nil)
        } else {
            view = WatchRewardVideos(nibName: "WatchRewardVideos", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallTVSeriesViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = TVSeries(nibName: "TVSeries_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = TVSeries(nibName: "TVSeries_iPhoneX", bundle: nil)
        } else {
            view = TVSeries(nibName: "TVSeries", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallTVChannelViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = TVChannel(nibName: "TVChannel_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = TVChannel(nibName: "TVChannel_iPhoneX", bundle: nil)
        } else {
            view = TVChannel(nibName: "TVChannel", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallFavouriteViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = Favourite(nibName: "Favourite_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = Favourite(nibName: "Favourite_iPhoneX", bundle: nil)
        } else {
            view = Favourite(nibName: "Favourite", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallProfileViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = Profile(nibName: "Profile_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = Profile(nibName: "Profile_iPhoneX", bundle: nil)
        } else {
            view = Profile(nibName: "Profile", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallSettingViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = Setting(nibName: "Setting_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = Setting(nibName: "Setting_iPhoneX", bundle: nil)
        } else {
            view = Setting(nibName: "Setting", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallLogoutViewController()
    {
        let uiAlert = UIAlertController(title: nil, message: CommonMessage.AreYouSureToLogout(), preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        uiAlert.addAction(UIAlertAction(title: CommonMessage.YES(), style: .default, handler: { action in
            UserDefaults.standard.set(false, forKey: "LOGIN")
            let view : UIViewController
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                view = Login(nibName: "Login_iPad", bundle: nil)
            } else if (CommonUtils.screenHeight >= 812) {
                view = Login(nibName: "Login_iPhoneX", bundle: nil)
            } else {
                view = Login(nibName: "Login", bundle: nil)
            }
            let nav = UINavigationController(rootViewController: view)
            nav.isNavigationBarHidden = true
            let window: UIWindow? = UIApplication.shared.keyWindow
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
        }))
        uiAlert.addAction(UIAlertAction(title: CommonMessage.NO(), style: .default, handler: { action in
            print("Click of NO button")
        }))
    }
    
    func CallLoginViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = Login(nibName: "Login_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = Login(nibName: "Login_iPhoneX", bundle: nil)
        } else {
            view = Login(nibName: "Login", bundle: nil)
        }
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        let window: UIWindow? = UIApplication.shared.keyWindow
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
    
    func CallCategoriesViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = Categories(nibName: "Categories_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = Categories(nibName: "Categories_iPhoneX", bundle: nil)
        } else {
            view = Categories(nibName: "Categories", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallLatestMoviesViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = LatestMovies(nibName: "LatestMovies_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = LatestMovies(nibName: "LatestMovies_iPhoneX", bundle: nil)
        } else {
            view = LatestMovies(nibName: "LatestMovies", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallLatestChannelViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = LatestChannel(nibName: "LatestChannel_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = LatestChannel(nibName: "LatestChannel_iPhoneX", bundle: nil)
        } else {
            view = LatestChannel(nibName: "LatestChannel", bundle: nil)
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
    
    func CallRecentlyViewedViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = RecentlyViewed(nibName: "RecentlyViewed_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = RecentlyViewed(nibName: "RecentlyViewed_iPhoneX", bundle: nil)
        } else {
            view = RecentlyViewed(nibName: "RecentlyViewed", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    //============Search Button Click============//
    @IBAction func OnSearchClick(sender:UIButton)
    {
        self.searchBar?.becomeFirstResponder()
        self.searchBar?.isHidden = false
        self.btnbacksearch?.isHidden = false
        self.btnleftmenu?.isHidden = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if (self.searchBar?.text != "")
        {
            UserDefaults.standard.set(self.searchBar?.text, forKey: "SEARCH_TEXT")
            self.searchBar?.resignFirstResponder()
            self.searchBar?.isHidden = true
            self.btnbacksearch?.isHidden = true
            self.btnleftmenu?.isHidden = false
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
        self.btnleftmenu?.isHidden = false
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
        self.lblheadername?.text = CommonMessage.Home()
        
        //5.Banner View Shadow Color
        self.baseBannerView?.layer.cornerRadius = 5.0
        self.baseBannerView?.clipsToBounds = true
//        self.baseBannerView?.layer.shadowColor = UIColor.darkGray.cgColor
//        self.baseBannerView?.layer.shadowOffset = CGSize(width:0, height:0)
//        self.baseBannerView?.layer.shadowRadius = 1.0
//        self.baseBannerView?.layer.shadowOpacity = 1
//        self.baseBannerView?.layer.masksToBounds = false
//        self.baseBannerView?.layer.shadowPath = UIBezierPath(roundedRect: (self.baseBannerView?.bounds)!, cornerRadius: (self.baseBannerView?.layer.cornerRadius)!).cgPath
        
        self.searchBar?.barTintColor = UIColor.clear
//        self.searchBar?.backgroundColor = UIColor.clear
        //6.UISearchbar Clear Background Color
//        for subView in (self.searchBar?.subviews)! {
//            for view in subView.subviews {
//                if view.isKind(of: NSClassFromString("UISearchBarBackground")!) {
//                    let imageView = view as! UIImageView
//                    imageView.removeFromSuperview()
//                }
//            }
//        }
    }
    
    
    //========Recive PackageName Notification========//
    @objc func receivePackageNameNotification(_ notification: Notification?)
    {
        if ((notification?.name)!.rawValue == "PackageNameNotification")
        {
            let isPackageNameSame = UserDefaults.standard.bool(forKey: "PACKAGENAME")
            if (!isPackageNameSame) {
                let msg = "You are using invalid License or Package name is already in use, for more information contact us: info@viaviweb.com or viaviwebtech@gmail.com"
                let uiAlert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertController.Style.alert)
                self.present(uiAlert, animated: true, completion: nil)
            }
        }
    }
    
    
    //========Recive Admob Notification========//
    @objc func receiveAdmobNotification(_ notification: Notification?)
    {
        if ((notification?.name)!.rawValue == "ADMOB")
        {
            self.getAdmobIDs()
        }
    }
    
    //=========Google Admobm Initialize==========//
    func getAdmobIDs()
    {
        //======Open Admob GDPR Popup======//
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let banner_ad_ios = UserDefaults.standard.value(forKey: "banner_ad_ios") as? String
        if (banner_ad_ios == "true")
        {
            let isSelect_GDPR: Bool = UserDefaults.standard.bool(forKey: "GDPR")
            if (isSelect_GDPR) {
                self.setAdmob()
            } else {
                self.checkAdmobGDPR()
            }
        } else {
            DispatchQueue.main.async {
                let screenRect: CGRect = UIScreen.main.bounds
                let screenWidth: CGFloat = screenRect.size.width
                let screenHeight: CGFloat = screenRect.size.height
                if (UI_USER_INTERFACE_IDIOM() == .pad) {
                    self.myScrollview?.frame = CGRect(x: 0, y: 75, width: screenWidth, height: screenHeight-75)
                } else if (screenHeight >= 812) {
                    self.myScrollview?.frame = CGRect(x: 0, y: 100, width: screenWidth, height: screenHeight-100)
                } else {
                    self.myScrollview?.frame = CGRect(x: 0, y: 75, width: screenWidth, height: screenHeight-75)
                }
            }
        }
    }
    func checkAdmobGDPR()
    {
        let deviceid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        PACConsentInformation.sharedInstance.debugIdentifiers = [deviceid]
        PACConsentInformation.sharedInstance.debugGeography = .EEA
        
        let publisher_id_ios = UserDefaults.standard.value(forKey: "publisher_id_ios") as? String
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: [publisher_id_ios!])
        { error in
            if (error != nil) {
                print("Consent info update failed.")
            } else {
                let isSuccess: Bool = PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown
                if (isSuccess) {
                    guard let privacyUrl = URL(string: "https://www.your.com/privacyurl"),
                        let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                            print("incorrect privacy URL.")
                            return
                    }
                    form.shouldOfferPersonalizedAds = true
                    form.shouldOfferNonPersonalizedAds = true
                    form.shouldOfferAdFree = true
                    form.load { error in
                        if let error = error {
                            print("Error loading form: \(error.localizedDescription)")
                        } else {
                            //Form Load successful.
                            let isSelect_GDPR: Bool = UserDefaults.standard.bool(forKey: "GDPR")
                            if (isSelect_GDPR) {
                                self.setAdmob()
                            } else {
                                form.present(from: self) { (error, userPrefersAdFree) in
                                    if error != nil {
                                        print("Error loading form: \(String(describing: error?.localizedDescription))")
                                    } else if userPrefersAdFree {
                                        print("User Select Free Ad from Form")
                                    } else {
                                        let status: PACConsentStatus = PACConsentInformation.sharedInstance.consentStatus;                                     switch(status)
                                        {
                                        case .unknown :
                                            print("PACConsentStatusUnknown")
                                            UserDefaults.standard.set(false, forKey: "GDPR_STATUS")
                                            UserDefaults.standard.set(true, forKey: "GDPR")
                                            self.setAdmob()
                                            break
                                        case .nonPersonalized :
                                            print("PACConsentStatusNonPersonalized")
                                            UserDefaults.standard.set(true, forKey: "GDPR_STATUS")
                                            UserDefaults.standard.set(true, forKey: "GDPR")
                                            let request = DFPRequest()
                                            let extras = GADExtras()
                                            extras.additionalParameters = ["npa": "1"]
                                            request.register(extras)
                                            self.setAdmob()
                                            break
                                        case .personalized :
                                            print("PACConsentStatusPersonalized")
                                            UserDefaults.standard.set(false, forKey: "GDPR_STATUS")
                                            UserDefaults.standard.set(true, forKey: "GDPR")
                                            self.setAdmob()
                                            break
                                        @unknown default:
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //================Admob Banner Ads===============//
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
            self.myScrollview.isHidden = true
            self.getHomeData()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myScrollview.isHidden = true
            self.getHomeData()
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
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
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
extension HomeViewController {
    func getRewardVideos(){
        //http://luzotv.com/api/ads/outstream
        //creating a NSURL
        let url = NSURL(string: "http://luzotv.com/api/ads/outstream")
       
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] {
                
                if jsonObj["status"] as! Int == 1 {
                    
                    
                    if let videoData = jsonObj["data"] as? NSArray {
                        self.RewardVideosArray = videoData
//                        var temp:[String:Any] = [String:Any]()
//
//                        for item in videoData{
//                            if let id = item["id"] as? Int {
//                                temp.updateValue(id, forKey: "id")
//                            }
//                            if let video = item["video"] as? String {
//                                let url = URL(string: video)
//                                temp.updateValue(video, forKey: "video")
//                                temp.updateValue(self.getThumbnailImage(forUrl: url!) as! UIImage, forKey: "thumbnail")
//                            }
//                            if let action_url = item["action_url"] as? String {
//                                temp.updateValue(action_url, forKey: "action_url")
//                            }
//                            if let reward_point = item["reward_point"] as? Int {
//                                temp.updateValue(reward_point, forKey: "reward_point")
//                            }
//                            tempRewardArray.append(temp)
//                        }
                    }
                    
                }
                
                
            }
            
            DispatchQueue.main.async {
                print("Reward Video Array: \(self.RewardVideosArray)")
            }
        }).resume()
    }
}

extension HomeViewController {
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
