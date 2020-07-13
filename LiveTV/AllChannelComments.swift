//
//  AllChannelComments.swift
//  LiveTV
//
//  Created by Apple on 29/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class AllChannelComments: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var myTableView : UITableView?
    @IBOutlet var lblnodatafound : UILabel?
    var AllCommentsArray = NSMutableArray()
    
    @IBOutlet var opacityView : UIView?
    @IBOutlet var commentView : UIView?
    @IBOutlet var imgLogo : UIImageView?
    @IBOutlet var txtcomment : UITextView?
    @IBOutlet var lblPlaceholderText : UILabel?
    @IBOutlet var btnsend : UIButton?
    var SendCommentsArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        
        //======Self View Touch Event=====//
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        self.opacityView?.addGestureRecognizer(singleFingerTap)
        
        //======Get All Channel Comments Data======//
        self.myTableView?.isHidden = true
        self.getAllChannelComments()
    }
    
    //===========Get All Channel Comments Data==========//
    func getAllChannelComments()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getAllChannelCommentsData(encodedString)
        } else {
            self.InternetConnectionNotAvailable1()
        }
    }
    func getAllChannelCommentsData(_ requesturl: String?)
    {
        let channelID : String = UserDefaults.standard.string(forKey: "CHANNEL_ID")!
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"get_user_comment", "post_id":channelID, "type":"channel"]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("All Channel Comments API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("All Channel Comments Responce Data : \(responseObject)")
                self.AllCommentsArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.AllCommentsArray.add(storeDict as Any)
                    }
                }
                print("AllCommentsArray Count = \(self.AllCommentsArray.count)")
                
                DispatchQueue.main.async {
                    if (self.AllCommentsArray.count == 0) {
                        self.myTableView?.isHidden = true
                        self.lblnodatafound?.isHidden = false
                    } else {
                        self.myTableView?.isHidden = false
                        self.lblnodatafound?.isHidden = true
                         self.myTableView?.reloadData()
                    }
                }
                
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure1()
            self.stopSpinner()
        })
    }
    
    //=========UITableView Delegate & Datasource Methods========//
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.AllCommentsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        cell.minHeight = 70.0
        
        cell.imgLogo?.layer.cornerRadius = (cell.imgLogo?.frame.size.height)!/2
        cell.imgLogo?.clipsToBounds = true
        
        //1.User Name
        let userName : String = (self.AllCommentsArray.value(forKey: "user_name") as! NSArray).object(at: indexPath.row) as! String
        cell.lblusername?.text = userName
        //cell.lblusername?.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout."
        
        //2.Comment Date
        let comment_date : String = (self.AllCommentsArray.value(forKey: "comment_date") as! NSArray).object(at: indexPath.row) as! String
        cell.lbldate?.text = comment_date
        
        //3.Comment Text
        let comment_text : String = (self.AllCommentsArray.value(forKey: "comment_text") as! NSArray).object(at: indexPath.row) as! String
        cell.lblcomment?.text = comment_text
        //cell.lblcomment?.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout."
        //cell.lblcomment?.sizeToFit()
        
        return cell
    }
    
    
    //=========UITextview Delegate Methods========//
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        let isLogin = UserDefaults.standard.bool(forKey: "LOGIN")
        if (isLogin) {
            self.lblPlaceholderText?.isHidden = true
            self.opacityView?.isHidden = false
            self.myTableView?.isUserInteractionEnabled = false
            self.txtcomment?.text = ""
            self.txtcomment?.becomeFirstResponder()
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        } else {
            UserDefaults.standard.set(true, forKey: "IS_SKIP")
            self.CallLoginViewController()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.isEmpty {
            self.lblPlaceholderText?.isHidden = false
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
            self.commentView?.frame = CGRect(x: 5, y: Int(CommonUtils.screenHeight-85) , width: Int(CommonUtils.screenWidth-10), height: 80)
            self.myTableView?.isUserInteractionEnabled = true
            self.sendComment()
        }
    }
    @objc func keyboardWasShown(_ notification: Notification?)
    {
        let keyboardSize = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
        let hh = (keyboardSize.height) + 85
        let width = Int(keyboardSize.width)
        self.commentView?.frame = CGRect(x: 5, y: Int(CommonUtils.screenHeight-hh) , width: width-10, height: 80)
    }
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer?)
    {
        self.txtcomment?.text = ""
        self.opacityView?.isHidden = true
        self.txtcomment?.resignFirstResponder()
        self.commentView?.frame = CGRect(x: 5, y: Int(CommonUtils.screenHeight-85) , width: Int(CommonUtils.screenWidth-10), height: 80)
        self.myTableView?.isUserInteractionEnabled = true
    }
    func sendComment()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.setUserCommentData(encodedString)
        } else {
            self.InternetConnectionNotAvailable2()
        }
    }
    func setUserCommentData(_ requesturl: String?)
    {
        let postID : String = UserDefaults.standard.string(forKey: "CHANNEL_ID")!
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
                
                self.txtcomment?.text = ""
                self.lblPlaceholderText?.isHidden = false
                self.stopSpinner()
                
                //======Get All Channel Comments Data======//
                DispatchQueue.main.async {
                    self.getAllChannelComments()
                }
            }
        }, failure: { operation, error in
            self.Networkfailure2()
            self.stopSpinner()
        })
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
        self.lblheadername?.text = CommonMessage.AllComments()
        
        //5.Leave Your Comment
        self.lblPlaceholderText?.text = CommonMessage.LeaveAComment()
        
        //6.Comment ImageView
        self.imgLogo?.layer.cornerRadius = (self.imgLogo?.frame.size.height)! / 2
        self.imgLogo?.layer.shadowColor = UIColor.lightGray.cgColor
        self.imgLogo?.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.imgLogo?.layer.shadowRadius = 1.0
        self.imgLogo?.layer.shadowOpacity = 2
        self.imgLogo?.layer.masksToBounds = false
        self.imgLogo?.layer.shadowPath = UIBezierPath(roundedRect: self.imgLogo!.bounds, cornerRadius: (self.imgLogo?.layer.cornerRadius)!).cgPath
        self.imgLogo?.clipsToBounds = true
        
        //7.Comment View
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
    //1.All Channel Comments
    func InternetConnectionNotAvailable1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myTableView?.isHidden = true
            self.getAllChannelComments()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.myTableView?.isHidden = true
            self.getAllChannelComments()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    //2.Send User Channel Comment
    func InternetConnectionNotAvailable2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.sendComment()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure2()
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
