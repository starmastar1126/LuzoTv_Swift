//
//  DetailChannelView.swift
//  LiveTV
//
//  Created by Apple on 17/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import AVKit
import GoogleCast
import GoogleMobileAds

let kCastControlBarsAnimationDuration2: TimeInterval = 0.20

class DetailChannelView: UIViewController,TPFloatRatingViewDelegate,UIWebViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,GCKSessionManagerListener,GCKRemoteMediaClientListener,GCKUIMiniMediaControlsViewControllerDelegate,GCKRequestDelegate,GADBannerViewDelegate,GADInterstitialDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var ratingView1: TPFloatRatingView!
    var UserRateArray = NSMutableArray()
    var UserUpdateRateArray = NSMutableArray()
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var lblnodatafound : UILabel?
    var DetailChannelArray = NSMutableArray()
    
    @IBOutlet var playerView : UIView?
    @IBOutlet var iconImageView : UIImageView?
    @IBOutlet var loader1 : UIActivityIndicatorView?
    @IBOutlet var loader2 : UIActivityIndicatorView?
    @IBOutlet var btnplay : UIButton?
    
    @IBOutlet var myScrollView : UIScrollView?
    
    @IBOutlet var myView1 : UIView?
    @IBOutlet weak var lblmoviename: MarqueeLabel!
    @IBOutlet var lblLanguageName : UILabel?
    @IBOutlet var lblViews : UILabel?
    @IBOutlet var ratingView: TPFloatRatingView!
    @IBOutlet var lblTotalRate : UILabel?
    @IBOutlet var btnEditRate : UIButton?
    @IBOutlet var btnReport : UIButton?
    @IBOutlet var btnFav : UIButton?
    
    @IBOutlet var myView2 : UIView?
    @IBOutlet var lblOverview : UILabel?
    @IBOutlet var lblOverviewLine : UILabel?
    @IBOutlet var myWebView : UIWebView?
    
    @IBOutlet var myView3 : UIView?
    @IBOutlet var lblRelatedMovies : UILabel?
    @IBOutlet var btnRelatedViewAll : UIButton?
    @IBOutlet var myCollectionView : UICollectionView?
    @IBOutlet var lblnoRelatedMovieFound : UILabel?
    var RelatedArray = NSArray()
    
    @IBOutlet var myView4 : UIView?
    @IBOutlet var lblComments : UILabel?
    @IBOutlet var btnCommentsViewAll : UIButton?
    @IBOutlet var imgCommentLogo : UIImageView?
    @IBOutlet var btnLeaveComment : UIButton?
    @IBOutlet var myTableView : UITableView?
    @IBOutlet var lblNoCommentsFound : UILabel?
    var CommentArray = NSArray()
    
    @IBOutlet var reportView : UIView?
    var ReportArray = NSMutableArray()
    
    @IBOutlet var opacityView : UIView?
    @IBOutlet var commentView : UIView?
    @IBOutlet var imgLogo : UIImageView?
    @IBOutlet var txtcomment : UITextView?
    @IBOutlet var btnsend : UIButton?
    var SendCommentsArray = NSMutableArray()
    
    var view1Height : CGFloat = 0
    var view2Height : CGFloat = 0
    var view3Height : CGFloat = 0
    var view4Height : CGFloat = 0
    
    var rate : Float = 0
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    
    
    var controller = AVPlayerViewController()
    
    private var sessionManager: GCKSessionManager!
    private var castSession: GCKCastSession!
    private var castButton: GCKUICastButton!
    private var castButton1: GCKUICastButton!
    private var castMediaController: GCKUIMediaController!
    private var queueAdded: Bool = false
    @IBOutlet var btnchromcast : UIButton?
    @IBOutlet var lblplaychromcast : UILabel?
    
    @IBOutlet private var _miniMediaControlsContainerView: UIView!
    @IBOutlet private var _miniMediaControlsHeightConstraint: NSLayoutConstraint!
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    
    var miniMediaControlsItemEnabled = false
    var miniMediaControlsViewEnabled = false {
        didSet {
            if isViewLoaded {
                updateControlBarsVisibility()
            }
        }
    }
    func updateControlBarsVisibility()
    {
        if miniMediaControlsViewEnabled, miniMediaControlsViewController.active {
            _miniMediaControlsHeightConstraint.constant = miniMediaControlsViewController.minHeight
            view.bringSubviewToFront(_miniMediaControlsContainerView)
        } else {
            _miniMediaControlsHeightConstraint.constant = 0
        }
        UIView.animate(withDuration: kCastControlBarsAnimationDuration2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        view.setNeedsLayout()
    }
    func installViewController(_ viewController: UIViewController?, inContainerView containerView: UIView)
    {
        if let viewController = viewController {
            addChild(viewController)
            viewController.view.frame = containerView.bounds
            containerView.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
    }
    func uninstallViewController(_ viewController: UIViewController)
    {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    func miniMediaControlsViewController(_: GCKUIMiniMediaControlsViewController, shouldAppear _: Bool)
    {
        updateControlBarsVisibility()
    }
    
    var mediaInfo: GCKMediaInformation? {
        didSet {
            print("setMediaInfo: \(String(describing: mediaInfo))")
        }
    }
    
    @objc func castDeviceDidChange(_: Notification)
    {
        if GCKCastContext.sharedInstance().castState != .noDevicesAvailable {
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if (hasConnectedSession) {
            self.btnchromcast?.isHidden = false
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-190, height: 30)
            } else if (CommonUtils.screenHeight >= 812) {
                self.lblheadername?.frame = CGRect(x: 60, y: 57, width: CommonUtils.screenWidth-190, height: 30)
            } else {
                self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-190, height: 30)
            }
        } else {
            self.btnchromcast?.isHidden = true
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-140, height: 30)
            } else if (CommonUtils.screenHeight >= 812) {
                self.lblheadername?.frame = CGRect(x: 60, y: 57, width: CommonUtils.screenWidth-140, height: 30)
            } else {
                self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-140, height: 30)
            }
        }
        super.viewWillAppear(animated)
    }
    
    
    //=======GCKSessionManager Delegate Methods=======//
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession)
    {
        print("MediaViewController: sessionManager didStartSession \(session)")
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-190, height: 30)
        } else if (CommonUtils.screenHeight >= 812) {
            self.lblheadername?.frame = CGRect(x: 60, y: 57, width: CommonUtils.screenWidth-190, height: 30)
        } else {
            self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-190, height: 30)
        }
        self.btnchromcast?.isHidden = false
        //self.lblplaychromcast?.isHidden = false
        setQueueButtonVisible(true)
        switchToRemotePlayback()
    }
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?)
    {
        print("session ended with error: \(String(describing: error))")
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-140, height: 30)
        } else if (CommonUtils.screenHeight >= 812) {
            self.lblheadername?.frame = CGRect(x: 60, y: 57, width: CommonUtils.screenWidth-140, height: 30)
        } else {
            self.lblheadername?.frame = CGRect(x: 60, y: 33, width: CommonUtils.screenWidth-140, height: 30)
        }
        self.btnchromcast?.isHidden = true
        self.lblplaychromcast?.isHidden = true
        let message = "The Casting session has ended.\n\(String(describing: error))"
        Toast.displayMessage(message, for: 3, in: (UIApplication.shared.delegate?.window)!)
        setQueueButtonVisible(false)
    }
    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession)
    {
        print("MediaViewController: sessionManager didResumeSession \(session)")
        setQueueButtonVisible(true)
        switchToRemotePlayback()
    }
    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?)
    {
        Toast.displayMessage("Failed to start a session.", for: 3, in: self.view)
        setQueueButtonVisible(false)
    }
    func sessionManager(_: GCKSessionManager, didFailToResumeSession _: GCKSession, withError _: Error?)
    {
        if let window = UIApplication.shared.delegate?.window {
            Toast.displayMessage("The Casting session could not be resumed.", for: 3, in: window)
        }
        setQueueButtonVisible(false)
        switchToRemotePlayback()
    }
    
    //#pragma mark - GCKRemoteMediaClientListener
    func remoteMediaClient(_: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?)
    {
        mediaInfo = mediaStatus?.mediaInformation
    }
    
    //#pragma mark - GCKRequestDelegate
    func requestDidComplete(_ request: GCKRequest)
    {
        print("request \(Int(request.requestID)) completed")
    }
    func request(_ request: GCKRequest, didFailWithError error: GCKError)
    {
        print("request \(Int(request.requestID)) failed with error \(error)")
    }
    
    
    //=======Google Chromecast Button Hide & Show=======//
    func setQueueButtonVisible(_ visible: Bool)
    {
        if visible, !queueAdded {
            btnchromcast?.isHidden = false
            //self.lblplaychromcast?.isHidden = false
            queueAdded = true
        } else if !visible, queueAdded {
            btnchromcast?.isHidden = true
            //self.lblplaychromcast?.isHidden = true
            queueAdded = false
        }
    }
    func switchToRemotePlayback()
    {
        print("switchToRemotePlayback; mediaInfo is \(String(describing: mediaInfo))")
        sessionManager.currentCastSession?.remoteMediaClient?.add(self)
        setQueueButtonVisible(true)
    }

    
    //==========Google Cast Play Button Click==========//
    @IBAction func OnPlayGoogleCastButtonClick(sender:UIButton)
    {
        let videoType = (self.DetailChannelArray.value(forKey: "channel_type_ios") as! NSArray).componentsJoined(by: "")
        if (videoType == "youtube") {
            KSToastView.ks_showToast(CommonMessage.YoutubeAndEmbeddedLinkDirectDoesNotCast(), duration: 3.0) {
                print("\("End!")")
            }
        } else if (videoType == "live_url") {
            self.lblplaychromcast?.isHidden = false
            controller.player?.pause()
            
            let movie_title = (self.DetailChannelArray.value(forKey: "channel_title") as! NSArray).componentsJoined(by: "")
            let language_name = (self.DetailChannelArray.value(forKey: "category_name") as! NSArray).componentsJoined(by: "")
            //let movie_desc = (self.DetailChannelArray.value(forKey: "movie_desc") as! NSArray).componentsJoined(by: "")
            let movie_cover = (self.DetailChannelArray.value(forKey: "channel_poster") as! NSArray).componentsJoined(by: "")
            let encodeString = movie_cover.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            let movieImage = URL(string: encodeString!)
            
            let metadata = GCKMediaMetadata(metadataType: .movie)
            metadata.setString(movie_title, forKey: kGCKMetadataKeyTitle)
            ///metadata.setString(movie_desc, forKey: kSecAttrDescription as String)
            metadata.setString(language_name, forKey: kGCKMetadataKeySubtitle)
            metadata.setString("studio", forKey: kGCKMetadataKeyStudio)
            metadata.string(forKey: kGCKMetadataKeyArtist)
            metadata.addImage(GCKImage(url: movieImage!, width: Int(CommonUtils.screenWidth), height: Int(CommonUtils.screenHeight)))
            
            let movie_url = (self.DetailChannelArray.value(forKey: "channel_url_ios") as! NSArray).componentsJoined(by: "")
            let url = URL(string: movie_url)
            let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url!)
            
            mediaInfoBuilder.contentID = url!.absoluteString
            mediaInfoBuilder.streamType = .buffered
            mediaInfoBuilder.streamDuration = TimeInterval(Int(String(format: "%d", "00:00"))!)
            //let duration: Int = Int(String(format: "%d", "00:00"))!
            //mediaInfoBuilder.streamDuration = TimeInterval(duration)
            mediaInfoBuilder.contentType = "video/mp4"
            mediaInfoBuilder.metadata = metadata
            mediaInfoBuilder.mediaTracks = nil
            mediaInfoBuilder.textTrackStyle = nil
            
            mediaInfo = mediaInfoBuilder.build()
            self.loadSelectedItem(byAppending: false)
            GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
        } else if (videoType == "embedded_url") {
            KSToastView.ks_showToast(CommonMessage.YoutubeAndEmbeddedLinkDirectDoesNotCast(), duration: 3.0) {
                print("\("End!")")
            }
        } else if (videoType == "local_url") {
            self.lblplaychromcast?.isHidden = false
            controller.player?.pause()
            
            let movie_title = (self.DetailChannelArray.value(forKey: "channel_title") as! NSArray).componentsJoined(by: "")
            let language_name = (self.DetailChannelArray.value(forKey: "category_name") as! NSArray).componentsJoined(by: "")
            //let movie_desc = (self.DetailChannelArray.value(forKey: "movie_desc") as! NSArray).componentsJoined(by: "")
            let movie_cover = (self.DetailChannelArray.value(forKey: "channel_poster") as! NSArray).componentsJoined(by: "")
            let encodeString = movie_cover.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            let movieImage = URL(string: encodeString!)
            
            let metadata = GCKMediaMetadata(metadataType: .movie)
            metadata.setString(movie_title, forKey: kGCKMetadataKeyTitle)
            ///metadata.setString(movie_desc, forKey: kSecAttrDescription as String)
            metadata.setString(language_name, forKey: kGCKMetadataKeySubtitle)
            metadata.setString("studio", forKey: kGCKMetadataKeyStudio)
            metadata.string(forKey: kGCKMetadataKeyArtist)
            metadata.addImage(GCKImage(url: movieImage!, width: Int(CommonUtils.screenWidth), height: Int(CommonUtils.screenHeight)))
            
            let movie_url = (self.DetailChannelArray.value(forKey: "channel_url_ios") as! NSArray).componentsJoined(by: "")
            let url = URL(string: movie_url)
            let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url!)
            
            mediaInfoBuilder.contentID = url!.absoluteString
            mediaInfoBuilder.streamType = .buffered
            mediaInfoBuilder.streamDuration = TimeInterval(Int(String(format: "%d", "00:00"))!)
            //let duration: Int = Int(String(format: "%d", "00:00"))!
            //mediaInfoBuilder.streamDuration = TimeInterval(duration)
            mediaInfoBuilder.contentType = "video/mp4"
            mediaInfoBuilder.metadata = metadata
            mediaInfoBuilder.mediaTracks = nil
            mediaInfoBuilder.textTrackStyle = nil
            
            mediaInfo = mediaInfoBuilder.build()
            self.loadSelectedItem(byAppending: false)
            GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
        } else {
            self.loader2?.isHidden = true
            self.btnplay?.isHidden = false
            let channel_poster = (self.DetailChannelArray.value(forKey: "channel_poster") as! NSArray).componentsJoined(by: "")
            let encodedString = channel_poster.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let placeImage = UIImage(named: "placeholder_big")
            self.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        }
    }
    
    func loadSelectedItem(byAppending appending: Bool)
    {
        print("Media Info = \(String(describing: self.mediaInfo))")
        //print("enqueue item \(String(describing: loadSelectedItem.mediaInfo))")
        if let remoteMediaClient = sessionManager.currentCastSession?.remoteMediaClient {
            let mediaQueueItemBuilder = GCKMediaQueueItemBuilder()
            mediaQueueItemBuilder.mediaInformation = self.mediaInfo
            mediaQueueItemBuilder.autoplay = true
            mediaQueueItemBuilder.preloadTime = TimeInterval(UserDefaults.standard.integer(forKey: "preload_time_sec"))
            let mediaQueueItem = mediaQueueItemBuilder.build()
            if appending {
                let request = remoteMediaClient.queueInsert(mediaQueueItem, beforeItemWithID: kGCKMediaQueueInvalidItemID)
                request.delegate = self
            } else {
                let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)
                queueDataBuilder.items = [mediaQueueItem]
                queueDataBuilder.repeatMode = remoteMediaClient.mediaStatus?.queueRepeatMode ?? .off
                
                let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
                mediaLoadRequestDataBuilder.queueData = queueDataBuilder.build()
                
                let request = remoteMediaClient.loadMedia(with: mediaLoadRequestDataBuilder.build())
                request.delegate = self
            }
        }
    }
    
    
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
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        //======Self View Touch Event=====//
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        self.opacityView?.addGestureRecognizer(singleFingerTap)
        
        //=======Register UITableView Cell Nib=======//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let nibName = UINib(nibName: "CommentCell_iPad", bundle:nil)
            self.myTableView?.register(nibName, forCellReuseIdentifier: "cell")
        } else {
            let nibName = UINib(nibName: "CommentCell", bundle:nil)
            self.myTableView?.register(nibName, forCellReuseIdentifier: "cell")
        }
        self.myTableView?.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        
        //=======Initialize GCKUIMiniMediaControlsViewController=======//
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        castMediaController = GCKUIMediaController()
        //volumeController = GCKUIDeviceVolumeController()
        sessionManager.add(self)
        
        //=========Initialize Google Cast Button=========//
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            castButton = GCKUICastButton(frame: CGRect(x: CommonUtils.screenWidth-50, y: 35, width: 28, height: 28))
        } else if (CommonUtils.screenHeight >= 812) {
            castButton = GCKUICastButton(frame: CGRect(x: CommonUtils.screenWidth-50, y: 74, width: 28, height: 28))
        } else {
            castButton = GCKUICastButton(frame: CGRect(x: CommonUtils.screenWidth-50, y: 35, width: 28, height: 28))
        }
        castButton.tintColor = UIColor.white
        castButton.contentHorizontalAlignment = .fill
        castButton.contentVerticalAlignment = .fill
        castButton.imageView?.contentMode = .scaleAspectFit
        self.view.addSubview(castButton)
        self.castButton1 = castButton
        
        //=========Cast Button First Time Appear Notification=========//
        NotificationCenter.default.addObserver(self, selector: #selector(castDeviceDidChange), name: NSNotification.Name.gckCastStateDidChange, object: GCKCastContext.sharedInstance())
        
        //======Get Single Channel Data======//
        self.myScrollView?.isHidden = true
        self.getSingleChannel()
    }
    
    //===========Get Single Channel Data==========//
    func getSingleChannel()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getSingleChannelData(encodedString)
        } else {
            self.InternetConnectionNotAvailable1()
        }
    }
    func getSingleChannelData(_ requesturl: String?)
    {
        let channelID : String = UserDefaults.standard.string(forKey: "CHANNEL_ID")!
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_single_channel", "channel_id":channelID]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Single Channel API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Single Channel Responce Data : \(responseObject)")
                self.DetailChannelArray.removeAllObjects()
                let errordict:NSDictionary = responseObject as! NSDictionary
                let storeArr = errordict[CommonUtils.getAPIKeyName()] as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict:NSDictionary = storeArr[i] as! NSDictionary
                    self.DetailChannelArray.add(storeDict)
                    self.RelatedArray = storeDict["related"] as! NSArray
                    self.CommentArray = storeDict["comments"] as! NSArray
                }
                print("DetailChannelArray Count = \(self.DetailChannelArray.count)")
                print("RelatedArray Count = \(self.RelatedArray.count)")
                print("CommentArray Count = \(self.CommentArray.count)")
                
                self.loader1?.isHidden = false
                self.loader2?.isHidden = false
                
                //=======Add To Recently Viewed=======//
                self.AddRecentlyViewed()
                
                DispatchQueue.main.async {
                    if (self.RelatedArray.count == 0) {
                        self.myCollectionView?.isHidden = true
                        self.lblnoRelatedMovieFound?.isHidden = false
                    } else {
                        self.myCollectionView?.isHidden = false
                        self.lblnoRelatedMovieFound?.isHidden = true
                        self.myCollectionView?.reloadData()
                    }
                }
                
                DispatchQueue.main.async {
                    if (self.CommentArray.count == 0) {
                        self.myTableView?.isHidden = true
                        //self.lblNoCommentsFound?.isHidden = false
                    } else {
                        self.myTableView?.isHidden = false
                        //self.lblNoCommentsFound?.isHidden = true
                        self.myTableView?.reloadData()
                    }
                }
                
                DispatchQueue.main.async {
                    if (self.DetailChannelArray.count == 0) {
                        self.myScrollView?.isHidden = true
                        self.lblnodatafound?.isHidden = false
                    } else {
                        self.myScrollView?.isHidden = false
                        self.lblnodatafound?.isHidden = true
                    }
                }
                
                self.setPlayVideo()
                self.setDataIntoScrollView()
                self.CallAdmobBanner()
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure1()
            self.stopSpinner()
        })
    }
    
    //===========Set Play Video==========//
    func setPlayVideo()
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            self.lblplaychromcast?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenWidth/1.7)
            self.playerView?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenWidth/1.7)
            self.myScrollView?.frame = CGRect(x: 0, y: 75+(CommonUtils.screenWidth/1.7), width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-(75+CommonUtils.screenWidth/1.7))
        } else if (CommonUtils.screenHeight >= 812) {
            self.lblplaychromcast?.frame = CGRect(x: 0, y: 100, width: CommonUtils.screenWidth, height: CommonUtils.screenWidth/1.7)
            self.playerView?.frame = CGRect(x: 0, y: 100, width: CommonUtils.screenWidth, height: CommonUtils.screenWidth/1.7)
            self.myScrollView?.frame = CGRect(x: 0, y: 100+(CommonUtils.screenWidth/1.7), width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-(100+CommonUtils.screenWidth/1.7))
        } else {
            self.lblplaychromcast?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenWidth/1.7)
            self.playerView?.frame = CGRect(x: 0, y: 75, width: CommonUtils.screenWidth, height: CommonUtils.screenWidth/1.7)
            self.myScrollView?.frame = CGRect(x: 0, y: 75+(CommonUtils.screenWidth/1.7), width: CommonUtils.screenWidth, height: CommonUtils.screenHeight-(75+CommonUtils.screenWidth/1.7))
        }
        
        let videoType = (self.DetailChannelArray.value(forKey: "channel_type_ios") as! NSArray).componentsJoined(by: "")
        if (videoType == "youtube") {
            let movieUrl = (self.DetailChannelArray.value(forKey: "channel_url_ios") as! NSArray).componentsJoined(by: "")
            let video_id = CommonUtils.extractYoutubeId(fromLink: movieUrl)
            let playerViewController = AVPlayerViewController()
            weak var weakPlayerViewController = playerViewController
            XCDYouTubeClient.default().getVideoWithIdentifier(video_id, completionHandler: { video, error in
                if (video != nil) {
                    var streamURLs = video?.streamURLs
                    let streamURL = streamURLs?[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs?[XCDYouTubeVideoQuality.HD720.rawValue] ?? streamURLs?[XCDYouTubeVideoQuality.medium360.rawValue] ?? streamURLs?[XCDYouTubeVideoQuality.small240.rawValue]
                    weakPlayerViewController!.player = AVPlayer(url: streamURL!)
                    self.addChild(weakPlayerViewController!)
                    self.playerView!.addSubview(weakPlayerViewController!.view)
                    weakPlayerViewController!.view.frame = CGRect(x: 0, y: 0, width: self.playerView!.frame.size.width, height: self.playerView!.frame.size.height)
                    weakPlayerViewController!.player = playerViewController.player
                    weakPlayerViewController!.showsPlaybackControls = true
                    playerViewController.player!.isClosedCaptionDisplayEnabled = false
                    playerViewController.player!.pause()
                    playerViewController.player!.play()
                } else {
                    self.dismiss(animated: true)
                }
            })
        } else if (videoType == "live_url") {
            let movieStr = (self.DetailChannelArray.value(forKey: "channel_url_ios") as! NSArray).componentsJoined(by: "")
            let encodeString = movieStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            let movieUrl = URL(string: encodeString!)
            let player = AVPlayer(url: movieUrl!)
            controller = AVPlayerViewController()
            self.addChild(controller)
            self.playerView?.addSubview(controller.view)
            
            controller.view.frame = CGRect(x: 0, y: 0, width: self.playerView!.frame.size.width, height: self.playerView!.frame.size.height)
            controller.player = player
            controller.showsPlaybackControls = true
            player.isClosedCaptionDisplayEnabled = false
            player.pause()
            player.play()
        } else if (videoType == "embedded_url") {
            self.loader2?.isHidden = true
            self.btnplay?.isHidden = false
            let movie_cover = (self.DetailChannelArray.value(forKey: "channel_thumbnail") as! NSArray).componentsJoined(by: "")
            let encodedString = movie_cover.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let placeImage = UIImage(named: "placeholder_big")
            self.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        } else if (videoType == "local_url") {
            let movieStr = (self.DetailChannelArray.value(forKey: "channel_url_ios") as! NSArray).componentsJoined(by: "")
            let encodeString = movieStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            let movieUrl = URL(string: encodeString!)
            let player = AVPlayer(url: movieUrl!)
            controller = AVPlayerViewController()
            self.addChild(controller)
            self.playerView?.addSubview(controller.view)
            controller.view.frame = CGRect(x: 0, y: 0, width: self.playerView!.frame.size.width, height: self.playerView!.frame.size.height)
            controller.player = player
            controller.showsPlaybackControls = true
            player.isClosedCaptionDisplayEnabled = false
            player.pause()
            player.play()
        } else {
            self.loader2?.isHidden = true
            self.btnplay?.isHidden = false
            let movie_cover = (self.DetailChannelArray.value(forKey: "channel_thumbnail") as! NSArray).componentsJoined(by: "")
            let encodedString = movie_cover.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let placeImage = UIImage(named: "placeholder_big")
            self.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        }
    }
    
    //===========Set Data Into ScrollView==========//
    func setDataIntoScrollView()
    {
        //1.MyView1 Shadow
        self.myView1?.layer.cornerRadius = 6
        //self.myView1?.clipsToBounds = true
        self.myView1?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView1?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView1?.layer.shadowRadius = 1.0
        self.myView1?.layer.shadowOpacity = 1
        self.myView1?.layer.masksToBounds = false
        self.myView1?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView1?.bounds)!, cornerRadius: (self.myView1?.layer.cornerRadius)!).cgPath
        
        //2.Check Channel Favourite or Not
        let modalObj: Modal = Modal()
        modalObj.cid = (self.DetailChannelArray.value(forKey: "id") as! NSArray).componentsJoined(by: "")
        let isNewsExist = Singleton.getInstance().SingleChannelsQueryData(modalObj)
        if (isNewsExist.count == 0) {
            self.btnFav?.setBackgroundImage(UIImage(named: "ic_fav")!, for: UIControl.State.normal)
        } else {
            self.btnFav?.setBackgroundImage(UIImage(named: "ic_fav_hov")!, for: UIControl.State.normal)
        }
        
        //3.Channel Name
        self.lblmoviename.type = .continuous
        self.lblmoviename.animationCurve = .easeInOut
        let channel_title = (self.DetailChannelArray.value(forKey: "channel_title") as! NSArray).componentsJoined(by: "")
        self.lblmoviename?.text = channel_title
        self.lblheadername?.text = channel_title

        //4.Channel Category Name
        let category_name = (self.DetailChannelArray.value(forKey: "category_name") as! NSArray).componentsJoined(by: "")
        self.lblLanguageName?.text = category_name
        
        //4.Channel Total Views
        let total_views = (self.DetailChannelArray.value(forKey: "total_views") as! NSArray).componentsJoined(by: "")
        self.lblViews?.text = String(format: "%@ %@",total_views , CommonMessage.Views())
        
        //6.Rating View
        self.ratingView.delegate = self
        self.ratingView.emptySelectedImage = UIImage(named: "starbigon")
        self.ratingView.fullSelectedImage = UIImage(named: "starbigoff")
        self.ratingView.contentMode = .scaleAspectFit
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 1
        let rate_avg = (self.DetailChannelArray.value(forKey: "rate_avg") as! NSArray).componentsJoined(by: "")
        let rateAvg = Double.init(rate_avg)
        self.ratingView.rating = CGFloat(rateAvg!)
        self.ratingView.editable = false
        self.ratingView.halfRatings = false
        self.ratingView.floatRatings = false
        
        //7.Total Rating
        let total_rate = (self.DetailChannelArray.value(forKey: "total_rate") as! NSArray).componentsJoined(by: "")
        self.lblTotalRate?.text = total_rate
        self.lblTotalRate?.layer.cornerRadius = (self.lblTotalRate?.frame.size.height)!/2
        self.lblTotalRate?.clipsToBounds = true
        
        //8.Report Button
        self.btnReport?.setTitle(CommonMessage.ReportHere(), for: UIControl.State.normal)
        self.btnReport?.layer.cornerRadius = (self.btnReport?.frame.size.height)!/2
        self.btnReport?.clipsToBounds = true
        
        //9.Description
        DispatchQueue.main.async {
            let channel_desc = (self.DetailChannelArray.value(forKey: "channel_desc") as! NSArray).componentsJoined(by: "")
            let htmlData = NSString(format: "<font face='Montserrat-Medium' size='3' color='#808080'>%@", channel_desc)
            self.myWebView?.loadHTMLString(htmlData as String , baseURL:nil)
        }
    }
    
    //========UIWebview Delegate Methods========//
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        print("webViewDidStartLoad")
    }
    internal func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        print("Webview ",error.localizedDescription)
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        //1.myView1
        let web1Height = self.myWebView?.scrollView.contentSize.height
        self.myWebView?.frame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: web1Height!)
        self.myWebView?.scrollView.isScrollEnabled = false
        self.view1Height = 130
        
        //2.myView2
        self.myView2?.frame = CGRect(x: 0, y: self.view1Height, width: UIScreen.main.bounds.width, height: 50+web1Height!)
        let channel_desc = (self.DetailChannelArray.value(forKey: "channel_desc") as! NSArray).componentsJoined(by: "")
        if (channel_desc == "") {
            self.myView2?.isHidden = true
            self.view2Height = 0.0
        } else {
            self.myView2?.isHidden = false
            self.view2Height = (self.myView2?.bounds.height)!
        }
        
        //3.myView3
        self.myView3?.frame = CGRect(x: 0, y: self.view1Height+self.view2Height, width: UIScreen.main.bounds.width, height: 55+(CommonUtils.screenWidth/3.5))
        if (self.RelatedArray.count == 0) {
            self.myView3?.isHidden = true
            self.view3Height = 0.0
        } else {
            self.myView3?.isHidden = false
            self.view3Height = (self.myView3?.bounds.height)!
        }
        
        //4.myView4
        let tblHeight:CGFloat = (self.myTableView?.contentSize.height)!
        self.myView4?.frame = CGRect(x: 0, y: self.view1Height+self.view2Height+self.view3Height, width: UIScreen.main.bounds.width, height: 65+tblHeight+70)
        self.view4Height = (self.myView4?.bounds.height)!
        
        //5.ScrollView Content Size
        let isBannerAd = UserDefaults.standard.value(forKey: "banner_ad_ios") as? String
        if (isBannerAd == "true") {
            self.myScrollView?.contentSize = CGSize(width: UIScreen.main.bounds.width, height: (self.view1Height+self.view2Height+self.view3Height+self.view4Height+50))
        } else {
            self.myScrollView?.contentSize = CGSize(width: UIScreen.main.bounds.width, height: (self.view1Height+self.view2Height+self.view3Height+self.view4Height))
        }
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest,                          navigationType: UIWebView.NavigationType) -> Bool
    {
        if (navigationType == .linkClicked) {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    
    //==========Play Button Click==========//
    @IBAction func OnPlayClick(sender:UIButton)
    {
        let videoType = (self.DetailChannelArray.value(forKey: "channel_type") as! NSArray).componentsJoined(by: "")
        if (videoType == "embedded_url") {
            let channelStr = (self.DetailChannelArray.value(forKey: "channel_url_ios") as! NSArray).componentsJoined(by: "")
            UserDefaults.standard.set(channelStr, forKey:"IFRAME")
            self.CallIframePlayVideoViewController()
        } else {
            let msg = CommonMessage.StreamUrlNotFound()
            KSToastView.ks_showToast(msg, duration: 3.0) {
                print("\("End!")")
            }
        }
    }
    
    //============UICollectionView Delegate & Datasource Methods============//
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.RelatedArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ChannelCell
        
        let strimgpath : String? = (self.RelatedArray.value(forKey: "rel_channel_thumbnail") as! NSArray).object(at: indexPath.row) as? String
        let encodedString = strimgpath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        cell.iconImageView?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        cell.lblChannelName?.text = (self.RelatedArray.value(forKey: "rel_channel_title") as! NSArray).object(at: indexPath.row) as? String
        
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
        let channelID = (self.RelatedArray.value(forKey: "rel_id") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(channelID, forKey: "CHANNEL_ID")
        let channelNAME = (self.RelatedArray.value(forKey: "rel_channel_title") as! NSArray).object(at: indexPath.row) as? String
        UserDefaults.standard.set(channelNAME, forKey: "CHANNEL_NAME")
        self.CallDetailChannelViewController()
    }
    
    
    //=========UITableView Delegate & Datasource Methods========//
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.CommentArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        cell.minHeight = 70.0
        
        cell.imgLogo?.layer.cornerRadius = (cell.imgLogo?.frame.size.height)!/2
        cell.imgLogo?.clipsToBounds = true
        
        //1.User Name
        let userName : String = (self.CommentArray.value(forKey: "user_name") as! NSArray).object(at: indexPath.row) as! String
        cell.lblusername?.text = userName
        //cell.lblusername?.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout."
        
        //2.Comment Date
        let comment_date : String = (self.CommentArray.value(forKey: "comment_date") as! NSArray).object(at: indexPath.row) as! String
        cell.lbldate?.text = comment_date
        
        //3.Comment Text
        let comment_text : String = (self.CommentArray.value(forKey: "comment_text") as! NSArray).object(at: indexPath.row) as! String
        cell.lblcomment?.text = comment_text
        //cell.lblcomment?.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout."
        //cell.lblcomment?.sizeToFit()
        
        return cell
    }
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 0.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //==========Edit Rate Button Click==========//
    @IBAction func OnEditRateClick(sender:UIButton)
    {
        let isLogin = UserDefaults.standard.bool(forKey: "LOGIN")
        if (isLogin) {
            self.getUserAlreadyRating()
        } else {
            UserDefaults.standard.set(true, forKey: "IS_SKIP")
            self.CallLoginViewController()
        }
    }
    //===========Get User's Already Rating Data==========//
    func getUserAlreadyRating()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getUserAlreadyRatingData(encodedString)
        } else {
            self.InternetConnectionNotAvailable2()
        }
    }
    func getUserAlreadyRatingData(_ requesturl: String?)
    {
        let postID = (self.DetailChannelArray.value(forKey: "id") as! NSArray).componentsJoined(by: "")
        let userID : String = UserDefaults.standard.string(forKey: "USER_ID")!
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"my_rating", "post_id":postID, "user_id":userID, "type":"channel"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("User's Already Rating API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("User's Already Rating Responce Data : \(responseObject)")
                self.UserRateArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.UserRateArray.add(storeDict as Any)
                    }
                }
                print("UserRateArray Count = \(self.UserRateArray.count)")
                
                self.stopSpinner()
                self.ShowUserRatingPopup()
            }
        }, failure: { operation, error in
            self.Networkfailure2()
            self.stopSpinner()
        })
    }
    func ShowUserRatingPopup()
    {
        let popupView = createPopupview()
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissTouchBackground = true
        popupConfig.cornerRadius = 8.0
        //popupConfig.overlayColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        //popupConfig.showAnimation = .slideInFromTop
        //popupConfig.dismissAnimation = .slideOutToBottom
        popupConfig.showCompletion = { popupView in
            print("show")
        }
        popupConfig.dismissCompletion = { popupView in
            print("dismiss")
        }
        presentPopupView(popupView, config: popupConfig)
    }
    func createPopupview() -> UIView
    {
        let popupView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        popupView.backgroundColor = UIColor(hexString: "#FEFFFF")
        popupView.layer.cornerRadius = 5.0
        popupView.clipsToBounds = true
        
        //1.Top Background
        let lblback = UILabel(frame: CGRect(x: 0, y: 0, width: popupView.frame.size.width, height: 50))
        lblback.backgroundColor = UIColor(hexString: "#1B6CC3")
        popupView.addSubview(lblback)
        
        //2.Review Header
        let lblname = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 50))
        lblname.text = CommonMessage.Rating()
        lblname.textAlignment = .left
        lblname.font = UIFont(name: "Montserrat-SemiBold", size: 20.0)
        lblname.textColor = UIColor(hexString: "#FFFFFF", alpha: 0.9)
        popupView.addSubview(lblname)
        
        //3.Close Button
        let btnclose = UIButton(type: .custom)
        btnclose.frame = CGRect(x: popupView.frame.size.width-40, y: 10, width: 30, height: 30)
        let img = UIImage(named: "close")
        btnclose.setBackgroundImage(img, for: UIControl.State.normal)
        btnclose.addTarget(self, action: #selector(OnPopupClose), for: UIControl.Event.touchUpInside)
        popupView.addSubview(btnclose)
        
        //4.Description
        let lbldesc = UILabel(frame: CGRect(x: 13, y: 70, width: popupView.frame.size.width-26, height: 50))
        lbldesc.text = CommonMessage.HowLikelyAreYouToRecommentMoovitToAFriend()
        lbldesc.textAlignment = .center
        lbldesc.numberOfLines = 2
        //lbldesc.backgroundColor = UIColor.red
        lbldesc.font = UIFont(name: "Montserrat-SemiBold", size: 15.0)
        lbldesc.textColor = UIColor(hexString: "#000000", alpha: 0.5)
        popupView.addSubview(lbldesc)
        
        //5.Rating View
        self.ratingView1 = TPFloatRatingView()
        self.ratingView1.frame = CGRect(x: 25, y: 135, width: 250, height: 100)
        self.ratingView1.delegate = self
        self.ratingView1.emptySelectedImage = UIImage(named: "starbigon")
        self.ratingView1.fullSelectedImage = UIImage(named: "starbigoff")
        self.ratingView1.contentMode = .scaleAspectFill
        self.ratingView1.maxRating = 5
        self.ratingView1.minRating = 1
        let user_rate = (self.UserRateArray.value(forKey: "user_rate") as! NSArray).componentsJoined(by: "")
        let rateAvg = Double.init(user_rate)
        self.ratingView1.rating = CGFloat(rateAvg!)
        self.ratingView1.editable = true
        self.ratingView1.halfRatings = false
        self.ratingView1.floatRatings = false
        popupView.addSubview(self.ratingView1)
        
        //6.Line
        let lblline = UILabel(frame: CGRect(x: 0, y: 215, width: popupView.frame.size.width, height: 1))
        lblline.backgroundColor = UIColor(hexString: "#000000", alpha: 0.1)
        popupView.addSubview(lblline)
        
        //7.Submit Button Click
        let btnsubmit = UIButton(type: .custom)
        btnsubmit.frame = CGRect(x: (popupView.frame.size.width-110)/2, y: 235, width: 120, height: 45)
        btnsubmit.backgroundColor = UIColor(hexString: "#1B6CC3")
        btnsubmit.setTitle(CommonMessage.Submit(), for: .normal)
        btnsubmit.titleLabel!.font = UIFont(name: "Montserrat-SemiBold", size: 16.0)
        btnsubmit.setTitleColor(UIColor(hexString: "#FFFFFF", alpha: 0.9), for: .normal)
        btnsubmit.addTarget(self, action: #selector(self.OnSubmitRateClick), for: UIControl.Event.touchUpInside)
        btnsubmit.layer.cornerRadius = btnsubmit.frame.size.height/2
        btnsubmit.clipsToBounds = true
        btnsubmit.layer.shadowColor = UIColor.lightGray.cgColor
        btnsubmit.layer.shadowOffset = CGSize(width:0, height:0)
        btnsubmit.layer.shadowRadius = 1.0
        btnsubmit.layer.shadowOpacity = 1
        btnsubmit.layer.masksToBounds = false
        btnsubmit.layer.shadowPath = UIBezierPath(roundedRect: (btnsubmit.bounds), cornerRadius: (btnsubmit.layer.cornerRadius)).cgPath
        popupView.addSubview(btnsubmit)
        
        return popupView
    }
    @objc func OnPopupClose()
    {
        dismissPopupView()
    }
    //==========TPFloatRatingView Delegate Methods==========//
    func floatRatingView(_ ratingView: TPFloatRatingView?, ratingDidChange rating: CGFloat)
    {
        self.rate = Float(rating)
    }
    func floatRatingView(_ ratingView: TPFloatRatingView?, continuousRating rating: CGFloat)
    {
        self.rate = Float(rating)
    }
    
    
    //========Submit Rate Button Click=======//
    @objc func OnSubmitRateClick(sender: UIButton!)
    {
        if (self.rate == 0) {
            KSToastView.ks_showToast(CommonMessage.PleaseSelectRating(), duration: 2.0) {
                print("\("End!")")
            }
        } else {
            dismissPopupView()
            self.SendNewUserRating()
        }
    }
    //======Send New User Rating Data=======//
    func SendNewUserRating()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getNewUserRatingData(encodedString)
        } else {
            self.InternetConnectionNotAvailable3()
        }
    }
    func getNewUserRatingData(_ requesturl: String?)
    {
        let postID = (self.DetailChannelArray.value(forKey: "id") as! NSArray).componentsJoined(by: "")
        let userID : String = UserDefaults.standard.string(forKey: "USER_ID")!
        let rating = String(self.rate)
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"user_rating", "post_id":postID, "user_id":userID, "rate":rating, "type":"channel"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("User New Rating API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("User New Rating Responce Data : \(responseObject)")
                self.UserUpdateRateArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.UserUpdateRateArray.add(storeDict as Any)
                    }
                }
                print("UserUpdateRateArray Count = \(self.UserUpdateRateArray.count)")
                
                //1.Rating Avg
                let rate_avg = (self.UserUpdateRateArray.value(forKey: "rate_avg") as! NSArray).componentsJoined(by: "")
                let rateAvg = Double.init(rate_avg)
                self.ratingView.rating = CGFloat(rateAvg!)
                
                //2.Total Rating
                let total_rate = (self.UserUpdateRateArray.value(forKey: "total_rate") as! NSArray).componentsJoined(by: "")
                self.lblTotalRate?.text = total_rate
                
                //3.Message
                let msg = (self.UserUpdateRateArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
                KSToastView.ks_showToast(msg, duration: 3.0) {
                    print("\("End!")")
                }
                
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure3()
            self.stopSpinner()
        })
    }
    
    
    //==========Report Button Click==========//
    @IBAction func OnReportClick(sender:UIButton)
    {
        let isLogin = UserDefaults.standard.bool(forKey: "LOGIN")
        if (isLogin) {
            let alertController = KOAlertController(title,CommonMessage.ReportMessage())
            alertController.alertTextField = CustomTextField(frame: CGRect(x: 0, y: 0, width: 0, height: 150))
            alertController.addTextField { (textField) in
                print(textField.text as Any)
            }
            alertController.addAction(KOAlertButton(.default, title:CommonMessage.Submit()))
            {
                self.getUserReport()
            }
            self.present(alertController, animated: false) {}
        } else {
            UserDefaults.standard.set(true, forKey: "IS_SKIP")
            self.CallLoginViewController()
        }
    }
    func getUserReport()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.sendUserReportData(encodedString)
        } else {
            self.InternetConnectionNotAvailable4()
        }
    }
    func sendUserReportData(_ requesturl: String?)
    {
        let userID : String = UserDefaults.standard.string(forKey: "USER_ID")!
        let postID = (self.DetailChannelArray.value(forKey: "id") as! NSArray).componentsJoined(by: "")
        let reportText = UserDefaults.standard.value(forKey: "REPORT_TEXT")
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"user_report", "user_id":userID, "post_id":postID, "report":reportText, "type":"channel"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("User Report API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("User Report Responce Data : \(responseObject)")
                self.ReportArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.ReportArray.add(storeDict as Any)
                    }
                }
                print("ReportArray Count = \(self.ReportArray.count)")
                
                UserDefaults.standard.set("", forKey: "REPORT_TEXT")
                
                //1.Message
                let msg = (self.ReportArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
                KSToastView.ks_showToast(msg, duration: 3.0) {
                    print("\("End!")")
                }
                
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure4()
            self.stopSpinner()
        })
    }
    
    
    //==========Favourite Button Click==========//
    @IBAction func OnFavouriteClick(sender:UIButton)
    {
        let modalObj: Modal = Modal()
        modalObj.cid = (self.DetailChannelArray.value(forKey: "id") as! NSArray).componentsJoined(by: "")
        modalObj.channel_title = (self.DetailChannelArray.value(forKey: "channel_title") as! NSArray).componentsJoined(by: "")
        modalObj.channel_thumbnail = (self.DetailChannelArray.value(forKey: "channel_thumbnail") as! NSArray).componentsJoined(by: "")
        let isNewsExist = Singleton.getInstance().SingleChannelsQueryData(modalObj)
        if (isNewsExist.count != 0)
        {
            let isDeleted = Singleton.getInstance().DeleteChannelsQueryData(modalObj)
            if (isDeleted) {
                self.btnFav?.setBackgroundImage(UIImage(named: "ic_fav")!, for: UIControl.State.normal)
                KSToastView.ks_showToast(CommonMessage.RemoveToFavourite(), duration: 2.0) {
                    print("\("End!")")
                }
            }
        } else {
            let isInserted = Singleton.getInstance().InsertChannelsQueryData(modalObj)
            if (isInserted) {
                self.btnFav?.setBackgroundImage(UIImage(named: "ic_fav_hov")!, for: UIControl.State.normal)
                KSToastView.ks_showToast(CommonMessage.AddToFavourite(), duration: 2.0) {
                    print("\("End!")")
                }
            }
        }
    }
    
    //==========Related Channel View All Click==========//
    @IBAction func OnRelatedMoviesViewAllClick(sender:UIButton)
    {
        let cat_id = (self.DetailChannelArray.value(forKey: "cat_id") as! NSArray).componentsJoined(by: "")
        UserDefaults.standard.set(cat_id, forKey: "CATEGORY_ID")
        self.CallRelatedChannelsViewController()
    }
    
    //==========Comments View All Button Click==========//
    @IBAction func OnCommentsViewAllClick(sender:UIButton)
    {
        self.CallAllChannelCommentsViewController()
    }
    
    //==========Leave Your Comment Click==========//
    @IBAction func OnLeaveYourCommentClick(sender:UIButton)
    {
        let isLogin = UserDefaults.standard.bool(forKey: "LOGIN")
        if (isLogin) {
            self.opacityView?.isHidden = false
            self.myCollectionView?.isUserInteractionEnabled = false
            self.txtcomment?.text = ""
            self.txtcomment?.becomeFirstResponder()
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        } else {
            UserDefaults.standard.set(true, forKey: "IS_SKIP")
            self.CallLoginViewController()
        }
    }
    
    //==========Send Comments Button Click==========//
    @IBAction func OnSendCommentsClick(sender:UIButton)
    {
        if (self.txtcomment?.text == "") {
            //[KSToastView ks_showToast:@"Please enter text for comment!" duration:3.0f];
        } else {
            self.opacityView?.isHidden = true
            self.txtcomment?.resignFirstResponder()
            self.commentView?.isHidden = true
            self.myCollectionView?.isUserInteractionEnabled = true
            self.sendComment()
        }
    }
    @objc func keyboardWasShown(_ notification: Notification?)
    {
        let keyboardSize = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        let hh = (keyboardSize.height) + 85
        let width = Int(keyboardSize.width)
        self.commentView?.frame = CGRect(x: 5, y: Int(CommonUtils.screenHeight-hh) , width: width-10, height: 80)
        self.commentView?.isHidden = false
    }
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer?)
    {
        self.txtcomment?.text = ""
        self.opacityView?.isHidden = true
        self.txtcomment?.resignFirstResponder()
        self.commentView?.isHidden = true
        self.myCollectionView?.isUserInteractionEnabled = true
    }
    func sendComment()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.setUserCommentData(encodedString)
        } else {
            self.InternetConnectionNotAvailable5()
        }
    }
    func setUserCommentData(_ requesturl: String?)
    {
        let postID = (self.DetailChannelArray.value(forKey: "id") as! NSArray).componentsJoined(by: "")
        let userID : String = UserDefaults.standard.string(forKey: "USER_ID")!
        let commentText:String = self.txtcomment!.text
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign as Any, "method_name":"user_comment", "post_id":postID, "user_id":userID, "comment_text":commentText, "type":"channel", "is_limit":"true"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("User Comment API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Send User Comment Responce Data : \(responseObject)")
                self.SendCommentsArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.SendCommentsArray.add(storeDict as Any)
                    }
                }
                print("SendCommentsArray Count = \(self.SendCommentsArray.count)")
                
                self.stopSpinner()
                
                //======Get Single Channel Data======//
                DispatchQueue.main.async {
                    self.getSingleChannel()
                }
            }
        }, failure: { operation, error in
            self.Networkfailure5()
            self.stopSpinner()
        })
    }
    
    
    //=========Push View Controller=========//
    func CallIframePlayVideoViewController()
    {
        let view : IframePlayVideo
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = IframePlayVideo(nibName: "IframePlayVideo_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = IframePlayVideo(nibName: "IframePlayVideo_iPhoneX", bundle: nil)
        } else {
            view = IframePlayVideo(nibName: "IframePlayVideo", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: false)
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
        self.navigationController?.pushViewController(view, animated: true)
    }
    func CallRelatedChannelsViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = RelatedChannels(nibName: "RelatedChannels_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = RelatedChannels(nibName: "RelatedChannels_iPhoneX", bundle: nil)
        } else {
            view = RelatedChannels(nibName: "RelatedChannels", bundle: nil)
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
    func CallAllChannelCommentsViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = AllChannelComments(nibName: "AllChannelComments_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = AllChannelComments(nibName: "AllChannelComments_iPhoneX", bundle: nil)
        } else {
            view = AllChannelComments(nibName: "AllChannelComments", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    func AddRecentlyViewed()
    {
        let modalObj: Modal = Modal()
        modalObj.rid = (self.DetailChannelArray.value(forKey: "id") as! NSArray).componentsJoined(by: "")
        modalObj.title = (self.DetailChannelArray.value(forKey: "channel_title") as! NSArray).componentsJoined(by: "")
        modalObj.cover_image = (self.DetailChannelArray.value(forKey: "channel_thumbnail") as! NSArray).componentsJoined(by: "")
        modalObj.type = "channel"
        let isNewsExist = Singleton.getInstance().SingleRecentlyViewedQueryData(modalObj)
        if (isNewsExist.count == 0)
        {
            _ = Singleton.getInstance().InsertRecentlyViewedQueryData(modalObj)
        }
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
        //let channelNAME : String = UserDefaults.standard.string(forKey: "CHANNEL_NAME")!
        //self.lblheadername?.text = channelNAME
        
        //5.Related Channels
        self.lblRelatedMovies?.text = CommonMessage.RelatedChannels()
        
        //6.Related Channels View All
        self.btnRelatedViewAll?.setTitle(CommonMessage.ViewAll(), for: .normal)
        
        //7.No Related Channels Found
        self.lblnoRelatedMovieFound?.text = CommonMessage.NoRelatedChannelsFound()
        
        //8.Comments
        self.lblComments?.text = CommonMessage.Comments()
        
        //9.Comments View All
        self.btnCommentsViewAll?.setTitle(CommonMessage.ViewAll(), for: .normal)
        
        //10.No Comments Found
        self.lblNoCommentsFound?.text = CommonMessage.NoCommentsFound()
        
        //11.Comment Logo
        self.imgCommentLogo?.layer.cornerRadius = (self.imgCommentLogo?.frame.size.height)!/2
        self.imgCommentLogo?.clipsToBounds = true
        
        //12.Leave Your Comment
        self.btnLeaveComment?.setTitle(CommonMessage.LeaveYourComments(), for: .normal)
        
        //13.Comment ImageView
        self.imgLogo?.layer.cornerRadius = (self.imgLogo?.frame.size.height)! / 2
        self.imgLogo?.layer.shadowColor = UIColor.lightGray.cgColor
        self.imgLogo?.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.imgLogo?.layer.shadowRadius = 1.0
        self.imgLogo?.layer.shadowOpacity = 2
        self.imgLogo?.layer.masksToBounds = false
        self.imgLogo?.layer.shadowPath = UIBezierPath(roundedRect: self.imgLogo!.bounds, cornerRadius: (self.imgLogo?.layer.cornerRadius)!).cgPath
        self.imgLogo?.clipsToBounds = true
        
        //14.Comment View
        self.commentView?.layer.shadowColor = UIColor.lightGray.cgColor
        self.commentView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.commentView?.layer.shadowOpacity = 4.0
        self.commentView?.layer.shadowRadius = 4.0
        self.commentView?.layer.borderWidth = 0.5
        self.commentView?.layer.borderColor = UIColor(hexString: "#093B5F").cgColor
        self.commentView?.layer.shadowPath = UIBezierPath(rect: self.commentView!.bounds).cgPath
        self.commentView?.layer.cornerRadius = 5.0
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
    //1.Single Channel
    func InternetConnectionNotAvailable1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myScrollView?.isHidden = true
            self.getSingleChannel()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myScrollView?.isHidden = true
            self.getSingleChannel()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    //2.User Already Rating
    func InternetConnectionNotAvailable2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUserAlreadyRating()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUserAlreadyRating()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    //3.User Update Rating
    func InternetConnectionNotAvailable3()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.SendNewUserRating()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure3()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.SendNewUserRating()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    //4.User Report
    func InternetConnectionNotAvailable4()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUserReport()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure4()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUserReport()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    //5.Send Comment
    func InternetConnectionNotAvailable5()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.sendComment()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure5()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.sendComment()
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
    
    
    @IBAction func OnBackClick(sender:UIButton)
    {
        let isNotication = UserDefaults.standard.bool(forKey: "PERTICULAR_NOTIFICATION")
        if (isNotication) {
            let userDefaults = Foundation.UserDefaults.standard
            userDefaults.set(false, forKey:"PERTICULAR_NOTIFICATION")
            let screenRect: CGRect = UIScreen.main.bounds
            let screenHeight: CGFloat = screenRect.size.height
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                let view = HomeViewController(nibName: "HomeViewController_iPad", bundle: nil)
                let nav = UINavigationController(rootViewController: view)
                nav.isNavigationBarHidden = true
                let window: UIWindow? = UIApplication.shared.keyWindow
                window?.rootViewController = nav
                window?.makeKeyAndVisible()
            } else if (screenHeight >= 812) {
                let view = HomeViewController(nibName: "HomeViewController_iPhoneX", bundle: nil)
                let nav = UINavigationController(rootViewController: view)
                nav.isNavigationBarHidden = true
                let window: UIWindow? = UIApplication.shared.keyWindow
                window?.rootViewController = nav
                window?.makeKeyAndVisible()
            } else {
                let view = HomeViewController(nibName: "HomeViewController", bundle: nil)
                let nav = UINavigationController(rootViewController: view)
                nav.isNavigationBarHidden = true
                let window: UIWindow? = UIApplication.shared.keyWindow
                window?.rootViewController = nav
                window?.makeKeyAndVisible()
            }
        } else {
            _ = navigationController?.popViewController(animated:true)
        }
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
