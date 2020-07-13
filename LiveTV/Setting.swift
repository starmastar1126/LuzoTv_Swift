//
//  Setting.swift
//  LiveTV
//
//  Created by Apple on 05/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import OneSignal

class Setting: UIViewController
{
    @IBOutlet private weak var myScrollview: UIScrollView!
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var lblenablepush : UILabel?
    @IBOutlet var btnrateapp : UIButton?
    @IBOutlet var btnmoreapp : UIButton?
    @IBOutlet var btnshareapp : UIButton?
    @IBOutlet var btnprivacy : UIButton?
    @IBOutlet var btnaboutus : UIButton?
    @IBOutlet var privateSwitch : UISwitch?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======Check Notification Status========//
        let isPushAccepted = UserDefaults.standard.bool(forKey: "PROMPT")
        if (isPushAccepted) {
            self.privateSwitch?.setOn(true, animated: true)
        } else {
            self.privateSwitch?.setOn(false, animated: true)
        }
    }
    
    //======Switch Button Click======//
    @IBAction func OnSwitchValueChanged(sender: UISwitch)
    {
        if (sender.isOn) {
            UserDefaults.standard.set(true, forKey: "PROMPT")
            OneSignal.setSubscription(true)
        } else {
            UserDefaults.standard.set(false, forKey: "PROMPT")
            OneSignal.setSubscription(false)
        }
    }
    
    //======Rate App Click======//
    @IBAction func OnRateAppClick(sender:UIButton)
    {
        DispatchQueue.main.async {
            let str : String = CommonUtils.getRateAppURL()
            let url = NSURL(string: str)
            UIApplication.shared.openURL(url! as URL)
        }
    }
    
    //======More Apps Click======//
    @IBAction func OnMoreAppsClick(sender:UIButton)
    {
        DispatchQueue.main.async {
            let str : String = CommonUtils.getMoreAppURL()
            let url = NSURL(string: str)
            UIApplication.shared.openURL(url! as URL)
        }
    }
    
    //======Share Apps Click======//
    @IBAction func OnShareAppClick(sender:UIButton)
    {
        self.shareApp()
    }
    
    //======Privacy Policy Click======//
    @IBAction func OnPrivacyPolicyClick(sender:UIButton)
    {
        let view:UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = PrivacyPolicy(nibName: "PrivacyPolicy_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = PrivacyPolicy(nibName: "PrivacyPolicy_iPhoneX", bundle: nil)
        } else {
            view = PrivacyPolicy(nibName: "PrivacyPolicy", bundle: nil)
        }
        self.navigationController?.pushViewController(view,animated:true)
    }
    
    //======About Us Click======//
    @IBAction func OnAboutUsClick(sender:UIButton)
    {
        let view:UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = AboutUs(nibName: "AboutUs_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = AboutUs(nibName: "AboutUs_iPhoneX", bundle: nil)
        } else {
            view = AboutUs(nibName: "AboutUs", bundle: nil)
        }
        self.navigationController?.pushViewController(view,animated:true)
    }
    
    //============Share App============//
    func shareApp()
    {
        let appName = CommonMessage.ApplicationName() as NSString
        let appLINK: NSString = NSString(format:CommonUtils.getShareAppURL() as NSString)
        let url = URL(string: appLINK as String)
        let appText = CommonMessage.ShareAppText() as NSString
        let objectsToShare = [appName,appText, url as Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
        activityVC.excludedActivityTypes = objectsToShare as? [UIActivity.ActivityType]
        DispatchQueue.main.async(execute: {
            if UI_USER_INTERFACE_IDIOM() == .pad {
                DispatchQueue.main.async(execute: {
                    if let popoverController = activityVC.popoverPresentationController {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                        self.present(activityVC, animated: true)
                    }
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.present(activityVC, animated: true)
                })
            }
        })
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
        self.lblheadername?.text = CommonMessage.Settings()
        
        //5.Enable Push Name
        self.lblenablepush?.text = CommonMessage.EnablePushNotification()
        
        //6.Rate Apps
        self.btnrateapp?.setTitle(CommonMessage.RateApp(), for:UIControl.State.normal)
        
        //7.More Apps
        self.btnmoreapp?.setTitle(CommonMessage.MoreApps(), for:UIControl.State.normal)
        
        //8.Share Apps
        self.btnshareapp?.setTitle(CommonMessage.ShareApp(), for:UIControl.State.normal)
        
        //9.Privacy Policy
        self.btnprivacy?.setTitle(CommonMessage.PrivacyPolicy(), for:UIControl.State.normal)
        
        //10.About Us
        self.btnaboutus?.setTitle(CommonMessage.AboutUs(), for:UIControl.State.normal)
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
