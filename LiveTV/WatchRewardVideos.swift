//
//  WatchRewardVideos.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 18/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AVKit
import AVFoundation

class WatchRewardVideos: UIViewController,LCBannerViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate  {
    var status:Int = Int()
    
    var spinner: SWActivityIndicatorView!
    var selectedVideo:Int = Int()
    @IBOutlet weak var collectionView: UICollectionView!
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var interstitial: GADInterstitial!
    var showVideo:Bool = false;
    
    var RewardVideosData:[[String:Any]] = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAdmob()
        self.getRewardVideos()
       

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.clear
      
       
        
        //=======Register UICollectionView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "RewardVideoCell_iPad", bundle:nil)
            self.collectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "RewardVideoCell", bundle:nil)
            self.collectionView?.register(nibName, forCellWithReuseIdentifier: "cell")
        }
    }
    func getRewardVideos(){
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
           
            self.getAllVideos()
        } else {
            self.InternetConnectionNotAvailable1()
        }
    }


    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func getAllVideos(){
        //http://luzotv.com/api/ads/outstream
        self.RewardVideosData.removeAll()
        let url = NSURL(string: "http://luzotv.com/api/ads/outstream")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] {
                
                if jsonObj["status"] as! Int == 1 {
                    
                    
                    if let videoData = jsonObj["data"] as? [[String:Any]] {
                       
                        var temp:[String:Any] = [String:Any]()
                        
                            for item in videoData{
                                if let id = item["id"] as? Int {
                                    temp.updateValue(id, forKey: "id")
                                }
                                if let video = item["video"] as? String {
                                    let url = URL(string: video)
                                    temp.updateValue(video, forKey: "video")
                                    
                                    if let thumbnail = self.getThumbnailImage(forUrl: url!) as? UIImage {
                                        temp.updateValue(thumbnail, forKey: "thumbnail")
                                    } else {
                                        temp.updateValue(UIImage(named: "about_logo") as! UIImage, forKey: "thumbnail")
                                    }
                                    
                                }
                                if let action_url = item["action_url"] as? String {
                                    temp.updateValue(action_url, forKey: "action_url")
                                }
                                if let reward_point = item["reward_point"] as? Int {
                                    temp.updateValue(reward_point, forKey: "reward_point")
                                }
                                self.RewardVideosData.append(temp)
                        }
                    }
                    
                }
                
                
            }
            
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                self.stopSpinner()
                print("Reward Video Array: \(self.RewardVideosData)")
                self.collectionView.reloadData()
            }
        }).resume()
    }
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
  
    func createAndLoadInterstitial() -> GADInterstitial
    {
        let interstitialAdId = UserDefaults.standard.value(forKey: "interstital_ad_id_ios") as? String
        interstitial = GADInterstitial(adUnitID: interstitialAdId!)
        let request = GADRequest()
        interstitial.delegate = self

        interstitial.load(request)
        
        return interstitial
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        if (interstitial.isReady) {
            interstitial.present(fromRootViewController: self)
        }
    }
    private func playVideo(fileURL: String) {
        
        // Create RUL object
        let url = URL(string: fileURL)
        
        // Create Player Item object
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        // Assign Item to Player
        let player = AVPlayer(playerItem: playerItem)
        
        // Prepare AVPlayerViewController
        let videoPlayer = AVPlayerViewController()
        // Assign Video to AVPlayerViewController
        videoPlayer.player = player
        
        NotificationCenter.default.addObserver(self, selector: #selector(WatchRewardVideos.finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Present the AVPlayerViewController
        present(videoPlayer, animated: true, completion: {
            // Play the Video
            player.play()
        })
        
    }
    
    @objc func finishVideo()
    {

        self.addPoints()
    }
    func addPoints()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            
            self.sendPoints()
        } else {
            self.InternetConnectionNotAvailable()
        }
        
    }
    
    func sendPoints() {
        let userID:String = UserDefaults.standard.string(forKey: "USER_ID")!
        let videoID:Int = self.RewardVideosData[selectedVideo]["id"] as! Int
        
        let url = URL(string: "http://luzotv.com/api/ads/reward_point/add?uid=\(userID)&vid=\(videoID)")!

        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
       
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            print(response)
            
            let responseString = String(data: data, encoding: .utf8)
          
            let jsonData = responseString!.data(using: .utf8)!
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as? [String:Any]
                {
                    if let status = jsonArray["status"] as? Int {
                        self.status = status
                    }
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
            
            DispatchQueue.main.async{
                self.stopSpinner()
                if self.status == 0 {
                    let alert = SCLAlertView()
                    
                    _ = alert.showError("Unable to add reward points")
                } else {
                    let alert = SCLAlertView()
                    
                    _ = alert.showInfo("Reward Point Added")
                    
                }
                
                
            }
        }
        
        task.resume()
    }
    
 
    
    //=======Internet Connection Not Available=======//
    func InternetConnectionNotAvailable()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.addPoints()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getRewardVideos()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        
            self.playVideo(fileURL: self.RewardVideosData[self.selectedVideo]["video"] as! String)
        
        
        
        
    }
    
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
    //1.Latest Movies
    func InternetConnectionNotAvailable1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.collectionView?.isHidden = true
            self.getRewardVideos()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.collectionView?.isHidden = true
            self.getAllVideos()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    
}

extension WatchRewardVideos:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RewardVideosData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! RewardVideoCell
        cell.delegate = self
        
        let temp:[String:Any] = self.RewardVideosData[indexPath.row]
        
        cell.iconImageView?.image = temp["thumbnail"] as? UIImage

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            print(CommonUtils.screenWidth)
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/2.5)
        } else {
            return CGSize(width: (CommonUtils.screenWidth-40)/3, height: CommonUtils.screenWidth/3.5)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedVideo = indexPath.row
        interstitial = createAndLoadInterstitial()
        interstitial.present(fromRootViewController: self)
        
        
    }
    
    
}
extension WatchRewardVideos:adDelegate{
    func visitAdvertiser(_ sender: RewardVideoCell) {
        guard let tappedIndexPath = self.collectionView.indexPath(for: sender) else { return }
        
        guard let url = URL(string: self.RewardVideosData[tappedIndexPath.row]["action_url"] as! String) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            // Fallback on earlier versions
        }
    }
    
}
