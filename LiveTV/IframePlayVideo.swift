//
//  IframePlayVideo.swift
//  LiveTV
//
//  Created by Apple on 23/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class IframePlayVideo: UIViewController,UIWebViewDelegate
{
    @IBOutlet var myWebView : UIWebView?
    @IBOutlet var loader : UIActivityIndicatorView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            let strIframe:String = UserDefaults.standard.value(forKey: "IFRAME") as! String
            let encodedString = strIframe.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: encodedString!)
            let request = URLRequest(url: url!)
            self.myWebView?.loadRequest(request)
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
        self.loader?.isHidden = true
    }
    
    //=====Status Bar Hidden & Style=====//
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func OnBackClick(sender:UIButton) {
        _ = navigationController?.popViewController(animated:false)
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
