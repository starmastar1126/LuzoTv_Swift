//
//  AboutUs.swift
//  LiveTV
//
//  Created by Apple on 15/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class AboutUs: UIViewController,UIWebViewDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    var AboutArray = NSMutableArray()
    
    @IBOutlet var myScrollview : UIScrollView?
    @IBOutlet var myView1 : UIView?
    @IBOutlet var myView2 : UIView?
    @IBOutlet var myView3 : UIView?
    @IBOutlet var myView4 : UIView?
    @IBOutlet var myView5 : UIView?
    @IBOutlet var myView6 : UIView?
    @IBOutlet var myView7 : UIView?
    @IBOutlet var imglogo : UIImageView?
    @IBOutlet var lblappname : UILabel?
    @IBOutlet var lblappversion : UILabel?
    @IBOutlet var lblappwebsite : UILabel?
    @IBOutlet var lblappemail : UILabel?
    @IBOutlet var lblappmobno : UILabel?
    @IBOutlet var lblcompany : UILabel?
    @IBOutlet var lblappdesc : UILabel?
    @IBOutlet var mywebview:UIWebView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=========Get About Us Data==========//
        self.getAboutUs()
    }

    //===========Get About Us Data==========//
    func getAboutUs()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getAboutUs(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getAboutUs(_ requesturl: String?)
    {
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_app_details"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("AboutUs API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("AboutUs Responce Data : \(responseObject)")
                self.AboutArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.AboutArray.add(storeDict as Any)
                    }
                }
                print("AboutArray Count = \(self.AboutArray.count)")
                
                DispatchQueue.main.async {
                    self.setDataIntoScrollView()
                }
            }
        }, failure: { operation, error in
            self.Networkfailure()
            self.stopSpinner()
        })
    }
    
    //========Set All Data Into Scrollview=======//
    func setDataIntoScrollView()
    {
        //1.Image Logo
        let applogo : String? = (self.AboutArray.value(forKey: "app_logo") as! NSArray).object(at: 0) as? String
        let strimgname : String = CommonUtils.getBaseUrl()+"images/"+applogo!
        let encodedString = strimgname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedString!)
        let placeImage = UIImage(named: "placeholder_small")
        self.imglogo?.sd_setImage(with: url, placeholderImage: placeImage, options: .continueInBackground, completed: nil)
        
        //2.App Name
        let appnamestr : String? = (self.AboutArray.value(forKey: "app_name") as! NSArray).object(at: 0) as? String
        self.lblappname?.text = appnamestr
        
        //3.App Version
        let appversionstr : String? = (self.AboutArray.value(forKey: "app_version") as! NSArray).object(at: 0) as? String
        self.lblappversion?.text = appversionstr
        
        //4.App Company
        let appompanystr : String? = (self.AboutArray.value(forKey: "app_developed_by") as! NSArray).object(at: 0) as? String
        self.lblcompany?.text = appompanystr
        
        //5.App Website
        let appwebsitestr : String? = (self.AboutArray.value(forKey: "app_website") as! NSArray).object(at: 0) as? String
        self.lblappwebsite?.text = appwebsitestr
        
        //6.App Email
        let appemailstr : String? = (self.AboutArray.value(forKey: "app_email") as! NSArray).object(at: 0) as? String
        self.lblappemail?.text = appemailstr
        
        //7.App Contact No.
        let appmobnostr : String? = (self.AboutArray.value(forKey: "app_contact") as! NSArray).object(at: 0) as? String
        self.lblappmobno?.text = appmobnostr
        
        //8.App Description
        let appdescstr : String? = (self.AboutArray.value(forKey: "app_description") as! NSArray).object(at: 0) as? String
        self.mywebview?.loadHTMLString(appdescstr!, baseURL: nil)
        self.mywebview?.scrollView.isScrollEnabled = false
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
        let descHieght = self.mywebview?.scrollView.contentSize.height
        self.mywebview?.frame = CGRect(x: 5, y: 45, width: (self.myView7?.frame.size.width)!-10, height: descHieght!)
        self.myView7?.frame = CGRect(x: 10, y: 430, width: UIScreen.main.bounds.size.width-20, height: descHieght!+45)
        self.myScrollview?.contentSize = CGSize(width: (self.myScrollview?.frame.size.width)!, height: 430+descHieght!+55)
        self.stopSpinner()
        self.myScrollview?.isHidden = false
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest,                          navigationType: UIWebView.NavigationType) -> Bool
    {
        if navigationType == .linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //1.Background Color
        self.view.backgroundColor = UIColor(hexString: Colors.getBackgroundColor())
        
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
        self.lblheadername?.text = CommonMessage.AboutUs()
        
        //5.UIView 1
        self.myView1?.layer.cornerRadius = 5.0
        self.myView1?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView1?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView1?.layer.shadowRadius = 1.0
        self.myView1?.layer.shadowOpacity = 1
        self.myView1?.layer.masksToBounds = false
        self.myView1?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView1?.bounds)!, cornerRadius: (self.myView1?.layer.cornerRadius)!).cgPath
        
        //6.UIView 2
        self.myView2?.layer.cornerRadius = 5.0
        self.myView2?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView2?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView2?.layer.shadowRadius = 1.0
        self.myView2?.layer.shadowOpacity = 1
        self.myView2?.layer.masksToBounds = false
        self.myView2?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView2?.bounds)!, cornerRadius: (self.myView2?.layer.cornerRadius)!).cgPath
        
        //7.UIView 3
        self.myView3?.layer.cornerRadius = 5.0
        self.myView3?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView3?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView3?.layer.shadowRadius = 1.0
        self.myView3?.layer.shadowOpacity = 1
        self.myView3?.layer.masksToBounds = false
        self.myView3?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView3?.bounds)!, cornerRadius: (self.myView3?.layer.cornerRadius)!).cgPath
        
        //8.UIView 4
        self.myView4?.layer.cornerRadius = 5.0
        self.myView4?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView4?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView4?.layer.shadowRadius = 1.0
        self.myView4?.layer.shadowOpacity = 1
        self.myView4?.layer.masksToBounds = false
        self.myView4?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView4?.bounds)!, cornerRadius: (self.myView4?.layer.cornerRadius)!).cgPath
        
        //9.UIView 5
        self.myView5?.layer.cornerRadius = 5.0
        self.myView5?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView5?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView5?.layer.shadowRadius = 1.0
        self.myView5?.layer.shadowOpacity = 1
        self.myView5?.layer.masksToBounds = false
        self.myView5?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView5?.bounds)!, cornerRadius: (self.myView5?.layer.cornerRadius)!).cgPath
        
        //10.UIView 6
        self.myView6?.layer.cornerRadius = 5.0
        self.myView6?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView6?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView6?.layer.shadowRadius = 1.0
        self.myView6?.layer.shadowOpacity = 1
        self.myView6?.layer.masksToBounds = false
        self.myView6?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView6?.bounds)!, cornerRadius: (self.myView6?.layer.cornerRadius)!).cgPath
        
        //11.UIView 7
        self.myView7?.layer.cornerRadius = 5.0
        self.myView7?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView7?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView7?.layer.shadowRadius = 1.0
        self.myView7?.layer.shadowOpacity = 1
        self.myView7?.layer.masksToBounds = false
        self.myView7?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView7?.bounds)!, cornerRadius: (self.myView7?.layer.cornerRadius)!).cgPath
        
        //12.Image Logo
        self.imglogo?.layer.cornerRadius = 5.0
        self.imglogo?.clipsToBounds = true
    }
    
    //=======Start & Stop Spinner=======//
    func startSpinner()
    {
        let screenRect: CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenRect.size.width
        let screenHeight: CGFloat = screenRect.size.height
        self.spinner = SWActivityIndicatorView(frame: CGRect(x:(screenWidth-60)/2, y:(screenHeight-60)/2, width: 60, height: 60))
        self.spinner.backgroundColor = UIColor.clear
        self.spinner.lineWidth = 3.5
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
    func InternetConnectionNotAvailable() {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getAboutUs()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure() {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getAboutUs()
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






//let videoType : String? = (self.EpisodesArray.value(forKey: "episode_type") as! NSArray).object(at: self.episodeINDEX) as? String
//if (videoType == "youtube_url") {
//    let SeriesUrl = (self.EpisodesArray.value(forKey: "episode_url") as! NSArray).object(at: self.episodeINDEX) as! String
//} else if (videoType == "server_url") {
//    let SeriesStr = (self.DetailSeriesArray.value(forKey: "episode_url") as! NSArray).componentsJoined(by: "")
//} else if (videoType == "embedded_url") {

