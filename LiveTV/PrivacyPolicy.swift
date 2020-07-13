//
//  PrivacyPolicy.swift
//  LiveTV
//
//  Created by Apple on 15/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class PrivacyPolicy: UIViewController,UIWebViewDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var myView : UIView?
    @IBOutlet var myWebView : UIWebView?
    var PrivacyArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //======Get TV Channel Data======//
        self.myView?.isHidden = true
        self.getPrivacyPolicy()
    }
    
    //===========Get Privacy Policy Data==========//
    func getPrivacyPolicy()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getTVChannelData(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getTVChannelData(_ requesturl: String?)
    {
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_app_details"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Privacy Policy API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Privacy Policy Responce Data : \(responseObject)")
                self.PrivacyArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.PrivacyArray.add(storeDict as Any)
                    }
                }
                print("PrivacyArray Count = \(self.PrivacyArray.count)")
                
                DispatchQueue.main.async {
                    let htmlStr = (self.PrivacyArray.value(forKey: "app_privacy_policy") as! NSArray).object(at: 0)
                    self.myWebView?.loadHTMLString(htmlStr as! String, baseURL:nil)
                }
            }
        }, failure: { operation, error in
            self.Networkfailure()
            self.stopSpinner()
        })
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
        self.stopSpinner()
        self.myView?.isHidden = false
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
        self.lblheadername?.text = CommonMessage.PrivacyPolicy()
        
        //5.My View
        self.myView?.layer.cornerRadius = 5.0
        self.myView?.layer.shadowColor = UIColor.darkGray.cgColor
        self.myView?.layer.shadowOffset = CGSize(width:0, height:0)
        self.myView?.layer.shadowRadius = 1.0
        self.myView?.layer.shadowOpacity = 1
        self.myView?.layer.masksToBounds = false
        self.myView?.layer.shadowPath = UIBezierPath(roundedRect: (self.myView?.bounds)!, cornerRadius: (self.myView?.layer.cornerRadius)!).cgPath
        
        //6.UIWebView
        self.myWebView?.layer.cornerRadius = 5.0
        self.myWebView?.clipsToBounds = true
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
            self.getPrivacyPolicy()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getPrivacyPolicy()
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

    /*let playerViewController = AVPlayerViewController()
     present(playerViewController, animated: true)
     weak var weakPlayerViewController: AVPlayerViewController? = playerViewController
     XCDYouTubeClient.default().getVideoWithIdentifier(video_id, completionHandler: { video, error in
     if (video != nil) {
     var streamURLs = video?.streamURLs
     let streamURL = streamURLs?[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs?[XCDYouTubeVideoQuality.HD720.rawValue] ?? streamURLs?[XCDYouTubeVideoQuality.medium360.rawValue] ?? streamURLs?[XCDYouTubeVideoQuality.small240.rawValue]
     if let anURL = streamURL {
     weakPlayerViewController?.player = AVPlayer(url: anURL)
     }
     weakPlayerViewController?.player?.play()
     } else {
     self.dismiss(animated: true)
     }
     })*/
    
}
