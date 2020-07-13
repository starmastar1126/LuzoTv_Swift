//
//  InfoView.swift
//  LiveTV
//
//  Created by Apple on 03/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class InfoView: UIViewController,ViewPagerDataSource
{
    @IBOutlet weak var viewPager: ViewPager!
    @IBOutlet var btnskip : UIButton?
    @IBOutlet var btnnext : UIButton?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //========PackageName Notification========//
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivePackageNameNotification(_:)), name: NSNotification.Name("PackageNameNotification"), object: nil)
        
        self.viewPager.dataSource = self;
        //self.viewPager.animationNext()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UserDefaults.standard.set(true, forKey: "INFO_SLIDER")
        ///self.viewPager.scrollToPage(index: 0)
    }
    
    //======Skip Button Click======//
    @IBAction func OnSkipClick(sender:UIButton)
    {
        self.CallLoginViewController()
    }
    
    //======Next Button Click======//
    @IBAction func OnNextClick(sender:UIButton)
    {
        self.CallLoginViewController()
        /*var index:Int = self.viewPager.currentPosition
        if (index == 0) {
            index = index + 1
        } else if (index == 3) {
            UserDefaults.standard.set(true, forKey: "INFO_SLIDER")
            self.CallLoginViewController()
        }
        self.viewPager.scrollToPage(index: index + 1)*/
    }
    
    //==========ViewPager Delegate Methods=========//
    func numberOfItems(viewPager:ViewPager) -> Int
    {
        return 3;
    }
    func viewAtIndex(viewPager:ViewPager, index:Int, view:UIView?) -> UIView
    {
        if (index == 0) {
            let view1 : UIView
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                view1 = Bundle.main.loadNibNamed("View1_iPad", owner: nil, options: nil)?[0] as! UIView
            } else if (CommonUtils.screenHeight >= 812) {
                view1 = Bundle.main.loadNibNamed("View1_iPhoneX", owner: nil, options: nil)?[0] as! UIView
            } else {
                view1 = Bundle.main.loadNibNamed("View1", owner: nil, options: nil)?[0] as! UIView
            }
            return view1
        } else if (index == 2) {
            let view2 : UIView
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                view2 = Bundle.main.loadNibNamed("View2_iPad", owner: nil, options: nil)?[0] as! UIView
            } else if (CommonUtils.screenHeight >= 812) {
                view2 = Bundle.main.loadNibNamed("View2_iPhoneX", owner: nil, options: nil)?[0] as! UIView
            } else {
                view2 = Bundle.main.loadNibNamed("View2", owner: nil, options: nil)?[0] as! UIView
            }
            return view2
        } else {
            let view3 : UIView
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                view3 = Bundle.main.loadNibNamed("View3_iPad", owner: nil, options: nil)?[0] as! UIView
            } else if (CommonUtils.screenHeight >= 812) {
                view3 = Bundle.main.loadNibNamed("View3_iPhoneX", owner: nil, options: nil)?[0] as! UIView
            } else {
                view3 = Bundle.main.loadNibNamed("View3", owner: nil, options: nil)?[0] as! UIView
            }
            return view3
        }
    }
    func didSelectedItem(index: Int)
    {
        print("select index \(index)")
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
        self.navigationController?.pushViewController(view, animated: true)
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
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //1.Skip & Next Button
        self.btnskip?.layer.cornerRadius = (self.btnskip?.frame.size.height)!/2
        self.btnskip?.clipsToBounds = true
        self.btnnext?.setTitle(CommonMessage.SKIP(), for: UIControl.State.normal)
        
        //2.Next Button
        self.btnnext?.layer.cornerRadius = (self.btnnext?.frame.size.height)!/2
        self.btnnext?.clipsToBounds = true
        self.btnnext?.setTitle(CommonMessage.NEXT(), for: UIControl.State.normal)
    }
    
    //=====Status Bar Hidden & Style=====//
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
