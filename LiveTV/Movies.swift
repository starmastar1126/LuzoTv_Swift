//
//  Movies.swift
//  LiveTV
//
//  Created by Apple on 05/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class Movies: TYTabPagerController,TYTabPagerControllerDataSource,TYTabPagerControllerDelegate,UISearchBarDelegate
{
    var TabArray = NSMutableArray()

    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    
    @IBOutlet var btnsearch : UIButton?
    @IBOutlet var searchBar : UISearchBar?
    @IBOutlet var btnback : UIButton?
    @IBOutlet var btnbacksearch : UIButton?
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        self.lblheadername?.text = CommonMessage.Movies()
        self.searchBar?.barTintColor = UIColor.clear

        //5.UISearchbar Clear Background Color
//        for subView in (self.searchBar?.subviews)! {
//            for view in subView.subviews {
//                if view.isKind(of: NSClassFromString("UISearchBarBackground")!) {
//                    let imageView = view as! UIImageView
//                   imageView.removeFromSuperview()
//                }
//            }
//        }
        
        //6.Tab Pager
        self.tabBarHeight = 50
        self.tabBar.layout.barStyle = .progressView
        self.tabBar.layout.cellWidth = self.view.frame.width / 2
        self.tabBar.layout.cellSpacing = 0
        self.tabBar.layout.cellEdging = 0
        self.tabBar.layout.adjustContentCellsCenter = true
        self.tabBar.isUserInteractionEnabled = true
        self.dataSource = self
        self.delegate = self
        self.loadData()
    }
    
    //===========TYPagerController Delegate Methods===========//
    func loadData()
    {
        self.TabArray = [CommonMessage.Language(),CommonMessage.Genre()]
        self.scrollToController(at: 0, animate: true)
        self.reloadData()
    }
    func numberOfControllersInTabPagerController() -> Int
    {
        return self.TabArray.count
    }
    func tabPagerController(_ tabPagerController: TYTabPagerController, controllerFor index: Int, prefetching: Bool) -> UIViewController
    {
        if (index == 0) {
            let view : Language
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                view = Language(nibName: "Language_iPad", bundle: nil)
            } else if (CommonUtils.screenHeight >= 812) {
                view = Language(nibName: "Language_iPhoneX", bundle: nil)
            } else {
                view = Language(nibName: "Language", bundle: nil)
            }
            return view
        } else {
            let view : Genre
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                view = Genre(nibName: "Genre_iPad", bundle: nil)
            } else if (CommonUtils.screenHeight >= 812) {
                view = Genre(nibName: "Genre_iPhoneX", bundle: nil)
            } else {
                view = Genre(nibName: "Genre", bundle: nil)
            }
            return view
        }
    }
    func tabPagerController(_ tabPagerController: TYTabPagerController, titleFor index: Int) -> String
    {
        let title = (TabArray[index] as? String)!
        return title
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
        let isNotication = UserDefaults.standard.bool(forKey: "TYPE_PERTICULAR_NOTIFICATION")
        if (isNotication) {
            let userDefaults = Foundation.UserDefaults.standard
            userDefaults.set(false, forKey:"TYPE_PERTICULAR_NOTIFICATION")
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
