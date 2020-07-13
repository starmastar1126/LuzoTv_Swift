//
//  AppDelegate.swift
//  LiveTV
//
//  Created by Apple on 02/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import OneSignal
import GoogleCast
import Firebase
import IQKeyboardManagerSwift

import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder,UIApplicationDelegate,GCKSessionManagerListener,GCKLoggerDelegate,GCKUIImagePicker
{
    var window: UIWindow?
    var SettingArray = NSMutableArray()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        FirebaseApp.configure()
        
        
        //registerForPushNotifications()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.enable = true
        Thread.sleep(forTimeInterval:TimeInterval(Settings.SetSplashScreenTime()))
        
        //=====Google Cast Video=======//
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kGCKDefaultMediaReceiverApplicationID))
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        GCKUICastButton.appearance().tintColor = UIColor.white
        
        self.checkBundleIdentifire()
        
        
       
        application.registerForRemoteNotifications()
        //======Copy Database from my document directory======//
        CommonUtils.copyFile("LiveTV.sqlite")
        
        //===========OneSignal Initialization============//
        OneSignal.add(self as? OSSubscriptionObserver)
        //OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: CommonUtils.getOneSignalAppID(),
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            if (accepted) {
                UserDefaults.standard.set(true, forKey: "PROMPT")
            } else {
                UserDefaults.standard.set(false, forKey: "PROMPT")
            }
        })
        
        OneSignal.add(self as? OSPermissionObserver)
        OneSignal.add(self as? OSSubscriptionObserver)
        
        UserDefaults.standard.set(false, forKey: "IS_SKIP")
        
        let isInfoSlider = UserDefaults.standard.bool(forKey: "INFO_SLIDER")
        if (isInfoSlider) {
            let isLogin = UserDefaults.standard.bool(forKey: "LOGIN")
            if (isLogin) {
                self.CallHomeViewController()
            } else {
                self.CallLoginViewController()
            }
        } else {
            self.CallInfoViewController()
        }
        
       
        
        return true
    }

   
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        if Auth.auth().canHandleNotification(userInfo) {
            print("Can Handle Auth")
        }
//            print("userInfo : ",userInfo)
//            let customdata = userInfo[AnyHashable("custom")]! as! NSDictionary
//            let isData = customdata["a"]
//            if ((isData) != nil) {
//                let dict = customdata["a"]! as! NSDictionary
//                let type = dict["type"] as! String
//                let postIDs = dict["post_id"] as! String
//                let post_id : Any? = postIDs
//                if (post_id == nil) {
//                    self.CallHomeViewController()
//                } else /*if (postIDs == "0") {
//                     UserDefaults.standard.set(true, forKey: "TYPE_PERTICULAR_NOTIFICATION")
//                     if (type == "movie") {
//                     self.CallMovieViewController()
//                     } else if (type == "series") {
//                     self.CallTVSeriesViewController()
//                     } else if (type == "channel") {
//                     self.CallTVChannelViewController()
//                     }
//                     } else*/ if (postIDs != "0") {
//                        UserDefaults.standard.set(true, forKey: "PERTICULAR_NOTIFICATION")
//                        if (type == "movie") {
//                            UserDefaults.standard.set(post_id, forKey: "MOVIE_ID")
//                            UserDefaults.standard.set("", forKey: "MOVIE_NAME")
//                            self.CallDetailMovieViewController()
//                        } else if (type == "series") {
//                            UserDefaults.standard.set(post_id, forKey: "SERIES_ID")
//                            UserDefaults.standard.set("", forKey: "SERIES_NAME")
//                            self.CallDetailSeriesViewController()
//                        } else if (type == "channel") {
//                            UserDefaults.standard.set(post_id, forKey: "CHANNEL_ID")
//                            UserDefaults.standard.set("", forKey: "CHANNEL_NAME")
//                            self.CallDetailChannelViewController()
//                        }
//                     } else if (dict["external_link"] is String) {
//                        DispatchQueue.main.async {
//                            let external_link = dict["external_link"] as? String
//                            if let aLink = URL(string: external_link!) {
//                                UIApplication.shared.openURL(aLink)
//                            }
//                        }
//                     } else {
//                        self.CallHomeViewController()
//                }
//            } else {
//                self.CallHomeViewController()
//            }
        
     
    }
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!)
    {
        if (stateChanges.from.status == OSNotificationPermission.notDetermined) {
            if (stateChanges.to.status == OSNotificationPermission.authorized) {
                print("Thanks for accepting notifications!")
            } else if (stateChanges.to.status == OSNotificationPermission.denied) {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        print("PermissionStateChanges: \n\(String(describing: stateChanges))")
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!)
    {
        if (!stateChanges.from.subscribed && stateChanges.to.subscribed) {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(String(describing: stateChanges))")
    }
    
    
    
    func CallInfoViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = InfoView(nibName: "InfoView_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = InfoView(nibName: "InfoView_iPhoneX", bundle: nil)
        } else {
            view = InfoView(nibName: "InfoView", bundle: nil)
        }
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
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
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func CallHomeViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = HomeViewController(nibName: "HomeViewController_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = HomeViewController(nibName: "HomeViewController_iPhoneX", bundle: nil)
        } else {
            view = HomeViewController(nibName: "HomeViewController", bundle: nil)
        }
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
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
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
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
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
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
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
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
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
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
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
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
        let nav = UINavigationController(rootViewController: view)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    
    //=============GCKUIImagePicker Delegate Methods===========//
    func getImageWith(_ imageHints: GCKUIImageHints, from metadata: GCKMediaMetadata) -> GCKImage?
    {
        let images = metadata.images
        guard !images().isEmpty else { print("No images available in media metadata."); return nil }
        if images().count > 1, imageHints.imageType == .background {
            return images()[1] as? GCKImage
        } else {
            return images()[0] as? GCKImage
        }
    }
    
    //=============GCKLoggerDelegate Delegate Methods===========//
    func logMessage(_ message: String, at _: GCKLoggerLevel, fromFunction function: String, location: String)
    {
        print("\(location): \(function) - \(message)")
    }
    
    //=============GCKSessionManagerListener Delegate Methods===========//
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?)
    {
        if (error == nil) {
            if let view = window?.rootViewController?.view {
                Toast.displayMessage("Session ended", for: 3, in: view)
            }
        } else {
            let message = "Session ended unexpectedly:\n\(error?.localizedDescription ?? "")"
            showAlert(withTitle: "Session error", message: message)
        }
    }
    func sessionManager(_: GCKSessionManager, didFailToStart _: GCKSession, withError error: Error)
    {
        let message = "Failed to start session:\n\(error.localizedDescription)"
        showAlert(withTitle: "Session error", message: message)
    }
    func showAlert(withTitle title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //===========Get App Setting Data==========//
    func checkBundleIdentifire()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getSetting(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getSetting(_ requesturl: String?)
    {
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_app_details"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Setting API URL : \(strDict)")
        
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Setting Responce Data : \(responseObject)")
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.SettingArray.add(storeDict as Any)
                    }
                }
                print("SettingArray Count = \(self.SettingArray.count)")
                
                DispatchQueue.main.async {
                    //=====Check Bundle Identifire======//
                    let bundleIdentifier =  Bundle.main.bundleIdentifier
                    //print("Bundle Identifier = \(String(describing: bundleIdentifier))")
                    let packageName = (self.SettingArray.value(forKey: "ios_bundle_identifier") as! NSArray).componentsJoined(by: "")
                    if (packageName == bundleIdentifier) {
                        UserDefaults.standard.set(true, forKey: "PACKAGENAME")
                    } else {
                        UserDefaults.standard.set(false, forKey: "PACKAGENAME")
                        NotificationCenter.default.post(name: Notification.Name("PackageNameNotification"), object: nil)
                    }
                    
                    //====Store Admob all IDs Here====//
                    let publisher_id_ios : String? = (self.SettingArray.value(forKey: "publisher_id_ios") as! NSArray).object(at: 0) as? String
                    UserDefaults.standard.setValue(publisher_id_ios, forKey: "publisher_id_ios")
                    let banner_ad_ios1 : String? = (self.SettingArray.value(forKey: "banner_ad_ios") as! NSArray).object(at: 0) as? String
                    //let banner_ad_ios1 : String? = "false"
                    UserDefaults.standard.setValue(banner_ad_ios1, forKey: "banner_ad_ios")
                    let banner_ad_id_ios : String? = (self.SettingArray.value(forKey: "banner_ad_id_ios") as! NSArray).object(at: 0) as? String
                    UserDefaults.standard.setValue(banner_ad_id_ios, forKey: "banner_ad_id_ios")
                    let interstital_ad_ios : String? = (self.SettingArray.value(forKey: "interstital_ad_ios") as! NSArray).object(at: 0) as? String
                    UserDefaults.standard.setValue(interstital_ad_ios, forKey: "interstital_ad_ios")
                    let interstital_ad_id_ios : String? = (self.SettingArray.value(forKey: "interstital_ad_id_ios") as! NSArray).object(at: 0) as? String
                    UserDefaults.standard.setValue(interstital_ad_id_ios, forKey: "interstital_ad_id_ios")
                    let interstital_ad_click_ios : String? = (self.SettingArray.value(forKey: "interstital_ad_click_ios") as! NSArray).object(at: 0) as? String
                    UserDefaults.standard.setValue(interstital_ad_click_ios, forKey: "interstital_ad_click_ios")
                    UserDefaults.standard.setValue(interstital_ad_click_ios, forKey: "AdCount")
                    
                    UserDefaults.standard.set(true, forKey: "ADMOB")
                    NotificationCenter.default.post(name: Notification.Name("ADMOB"), object: nil)
                }
            }
        }, failure: { operation, error in
            self.Networkfailure()
        })
    }
    
    //=======Internet Connection Not Available=======//
    func InternetConnectionNotAvailable() {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.checkBundleIdentifire()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure() {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.checkBundleIdentifire()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
}

