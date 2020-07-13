//
//  Profile.swift
//  LiveTV
//
//  Created by Apple on 05/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import ADCountryPicker

class Profile: UIViewController,UITextFieldDelegate
{
    
    
    var spinner: SWActivityIndicatorView!
   
    @IBOutlet private weak var myScrollview: UIScrollView!
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    
    @IBOutlet weak var regionImage: UIImageView!
    @IBOutlet var lblusername : UILabel?
    @IBOutlet var lblemail : UILabel?
    @IBOutlet var lblpassword : UILabel?
    @IBOutlet var lblphone : UILabel?
    
    
    
    @IBOutlet private weak var txtusername: UITextField!
    @IBOutlet private weak var txtemail: UITextField!
    @IBOutlet private weak var txtpassword: UITextField!
    @IBOutlet private weak var txtphone: UITextField!

    
    
    @IBOutlet var btnsubmit : UIButton?
    var ProfileArray = NSMutableArray()
    var UpdateProfileArray = NSMutableArray()

    private lazy var toolbar: FormToolbar = {
        return FormToolbar(inputs: self.inputs)
    }()
    private var inputs: [FormInput] {
        return [self.txtusername, self.txtemail, self.txtpassword, self.txtphone]
    }
    private weak var activeInput: FormInput?
    
    override func loadView()
    {
        super.loadView()
        
        self.txtusername.delegate = self
        self.txtemail.delegate = self
        self.txtpassword.delegate = self
        self.txtphone.delegate = self
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
      
        //=======UIKeyboard Hide & Show Methods======//
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //======Get User Profile Data======//
        self.getUserProfile()
    }
    
    //===========Get User Profile Data==========//
    func getUserProfile()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getUserProfileData(encodedString)
        } else {
            self.InternetConnectionNotAvailable1()
        }
    }
    func getUserProfileData(_ requesturl: String?)
    {
        let userID : String = UserDefaults.standard.string(forKey: "USER_ID")!
        print("USER ID IS : \(userID)")
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let dict = ["salt":salt, "sign":sign, "method_name":"user_profile", "user_id":userID]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("User Profile API URL : \(strDict)")
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("User Profile Responce Data : \(responseObject)")
                self.ProfileArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.ProfileArray.add(storeDict as Any)
                    }
                }
                print("ProfileArray Count = \(self.ProfileArray)")
                
                self.SetUserProfileData()
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure1()
            self.stopSpinner()
        })
    }
    
    func SetUserProfileData()
    {
   
        //1.Name
        let name = (self.ProfileArray.value(forKey: "name") as! NSArray).componentsJoined(by: "")
        self.txtusername.text = name
        
        //2.Email
        let email = (self.ProfileArray.value(forKey: "email") as! NSArray).componentsJoined(by: "")
        self.txtemail.text = email
        
        //3.Phone
        let phone = (self.ProfileArray.value(forKey: "phone") as! NSArray).componentsJoined(by: "")
        self.txtphone.text = phone
    }
    
    
    //======Submit Button Click======//
    @IBAction func OnSubmitClick(sender:UIButton)
    {
        if (self.txtusername?.text == "") {
            self.txtusername?.bs_setupErrorMessageView(withMessage: CommonMessage.Enter_Name())
            self.txtusername?.bs_showError()
        } else if (self.txtemail?.text == "") {
            self.txtemail?.bs_setupErrorMessageView(withMessage: CommonMessage.Enter_email_address())
            self.txtemail?.bs_showError()
        } else if !CommonUtils.validateEmail(with: self.txtemail?.text) {
            self.txtemail?.bs_setupErrorMessageView(withMessage: CommonMessage.Enter_Valid_email_address())
            self.txtemail?.bs_showError()
        } else if (self.txtpassword?.text == "") {
            self.txtpassword?.bs_setupErrorMessageView(withMessage: CommonMessage.Enter_Password())
            self.txtpassword?.bs_showError()
        } else if (self.txtpassword?.text?.count)! < 6 {
            let errorMessageView = BSErrorMessageView(message: CommonMessage.Password_required_minimum_6_characters())
            errorMessageView?.mainTintColor = UIColor.green
            errorMessageView?.textFont = UIFont.systemFont(ofSize: 14.0)
            errorMessageView?.messageAlwaysShowing = true
            self.txtpassword?.bs_setupErrorMessageView(with: errorMessageView)
            self.txtpassword?.bs_showError()
        } else {
            self.txtusername?.resignFirstResponder()
            self.txtemail?.resignFirstResponder()
            self.txtpassword?.resignFirstResponder()
            self.txtphone?.resignFirstResponder()
            self.getUpdateProfile()
        }
    }
    
    //===========Send Update Profile Data==========//
    func getUpdateProfile()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getSubmitData(encodedString)
        } else {
            self.InternetConnectionNotAvailable2()
        }
    }
    func getSubmitData(_ requesturl: String?)
    {
        let userID : String = UserDefaults.standard.string(forKey: "USER_ID")!
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let name = self.txtusername?.text
        let email = self.txtemail?.text
        let password = self.txtpassword?.text
        let phone = self.txtphone?.text
        let dict = ["salt":salt, "sign":sign, "method_name":"user_profile_update", "user_id":userID, "name":name, "email":email, "password":password, "phone":phone]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Update Profile API URL : \(strDict)")
        
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Update Profile Responce Data : \(responseObject)")
                self.UpdateProfileArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.UpdateProfileArray.add(storeDict as Any)
                    }
                }
                print("UpdateProfileArray Count = \(self.UpdateProfileArray.count)")
                
                DispatchQueue.main.async {
                    let success = (self.UpdateProfileArray.value(forKey: "success") as! NSArray).componentsJoined(by: "")
                    if (success == "0") {
                        let msg = (self.UpdateProfileArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
                        KSToastView.ks_showToast(msg, duration: 3.0) {
                            print("\("End!")")
                        }
                    } else {
                        let msg = (self.UpdateProfileArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
                        KSToastView.ks_showToast(msg, duration: 3.0) {
                            print("\("End!")")
                        }
                        _ = self.navigationController?.popViewController(animated:true)
                    }
                }
                
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure2()
            self.stopSpinner()
        })
    }
    
    //======Keyboard Delegate Methods ======//
    @objc func keyboardWillShow(_ notification: Notification)
    {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 16.0, right: 0)
        self.myScrollview.contentInset = contentInsets
        self.myScrollview.scrollIndicatorInsets = contentInsets
    }
    @objc func keyboardWillHide(_ notification: Notification)
    {
        self.myScrollview.contentInset = .zero
        self.myScrollview.scrollIndicatorInsets = .zero
    }
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    //======UITextfield Delegate Methods======//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        toolbar.goForward()
        
        self.txtusername?.resignFirstResponder()
        self.txtemail?.resignFirstResponder()
        self.txtpassword?.resignFirstResponder()
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        toolbar.update()
        activeInput = textField
        
        self.txtusername?.bs_hideError()
        self.txtemail?.bs_hideError()
        self.txtpassword?.bs_hideError()
        self.txtphone?.bs_hideError()
       
    }
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        toolbar.update()
        activeInput = textView
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,                   replacementString string: String) -> Bool
    {
        self.txtusername?.bs_hideError()
        self.txtemail?.bs_hideError()
        self.txtpassword?.bs_hideError()
        self.txtphone?.bs_hideError()
        return true
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
        self.lblheadername?.text = CommonMessage.Profile()
        
        //=========User Name Lable========//
        //1.Bottom
        let bottomBorder0 = CALayer()
        bottomBorder0.frame = CGRect(x: 0, y: (self.lblusername?.frame.size.height)!, width: (self.lblusername?.frame.size.width)!, height: 2.0)
        bottomBorder0.borderWidth = 2.0
        bottomBorder0.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblusername?.layer.addSublayer(bottomBorder0)
        //2.Left
        let leftBorder0 = CALayer()
        leftBorder0.frame = CGRect(x: 0, y: (self.lblusername?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder0.borderWidth = 2.0
        leftBorder0.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblusername?.layer.addSublayer(leftBorder0)
        //3.Right
        let rightBorder0 = CALayer()
        rightBorder0.frame = CGRect(x: (self.lblusername?.frame.size.width)! - 2, y: (self.lblusername?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder0.borderWidth = 2.0
        rightBorder0.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblusername?.layer.addSublayer(rightBorder0)
        
        //=====Email Lable====//
        //1.Bottom
        let bottomBorder1 = CALayer()
        bottomBorder1.frame = CGRect(x: 0, y: (self.lblemail?.frame.size.height)!, width: (self.lblemail?.frame.size.width)!, height: 2.0)
        bottomBorder1.borderWidth = 2.0
        bottomBorder1.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblemail?.layer.addSublayer(bottomBorder1)
        //2.Left
        let leftBorder1 = CALayer()
        leftBorder1.frame = CGRect(x: 0, y: (self.lblemail?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder1.borderWidth = 2.0
        leftBorder1.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblemail?.layer.addSublayer(leftBorder1)
        //3.Right
        let rightBorder1 = CALayer()
        rightBorder1.frame = CGRect(x: (self.lblemail?.frame.size.width)! - 2, y: (self.lblemail?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder1.borderWidth = 2.0
        rightBorder1.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblemail?.layer.addSublayer(rightBorder1)
        
        //=========Password Lable========//
        //1.Bottom
        let bottomBorder2 = CALayer()
        bottomBorder2.frame = CGRect(x: 0, y: (self.lblpassword?.frame.size.height)!, width: (self.lblpassword?.frame.size.width)!, height: 2.0)
        bottomBorder2.borderWidth = 2.0
        bottomBorder2.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblpassword?.layer.addSublayer(bottomBorder2)
        //2.Left
        let leftBorder2 = CALayer()
        leftBorder2.frame = CGRect(x: 0, y: (self.lblpassword?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder2.borderWidth = 2.0
        leftBorder2.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblpassword?.layer.addSublayer(leftBorder2)
        //3.Right
        let rightBorder2 = CALayer()
        rightBorder2.frame = CGRect(x: (self.lblpassword?.frame.size.width)! - 2, y: (self.lblpassword?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder2.borderWidth = 2.0
        rightBorder2.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblpassword?.layer.addSublayer(rightBorder2)
        
        //=========Phone Lable========//
        //1.Bottom
        let bottomBorder4 = CALayer()
        bottomBorder4.frame = CGRect(x: 0, y: (self.lblphone?.frame.size.height)!, width: (self.lblphone?.frame.size.width)!, height: 2.0)
        bottomBorder4.borderWidth = 2.0
        bottomBorder4.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblphone?.layer.addSublayer(bottomBorder4)
        //2.Left
        let leftBorder4 = CALayer()
        leftBorder4.frame = CGRect(x: 0, y: (self.lblphone?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder4.borderWidth = 2.0
        leftBorder4.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblphone?.layer.addSublayer(leftBorder4)
        //3.Right
        let rightBorder4 = CALayer()
        rightBorder4.frame = CGRect(x: (self.lblphone?.frame.size.width)! - 2, y: (self.lblphone?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder4.borderWidth = 2.0
        rightBorder4.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblphone?.layer.addSublayer(rightBorder4)
        
        
     
        //=========Username Placeholder Color========//
        //self.txtusername?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Name(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=========Email Placeholder Color========//
        //self.txtemail?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Email(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=========Password Placeholder Color========//
        self.txtpassword?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Password(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=========Password Placeholder Color========//
        self.txtphone?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Phone(),attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString:Colors.getTextBorderColor(), alpha: 0.7)!])
  
        
        //=========Submit Button Corner Radius=========//
        self.btnsubmit?.layer.cornerRadius = (self.btnsubmit?.frame.size.height)!/2
        self.btnsubmit?.clipsToBounds = true
        self.btnsubmit?.setTitle(CommonMessage.Submit(), for: UIControl.State.normal)
        self.btnsubmit?.backgroundColor = UIColor(hexString: Colors.getButtonColor1())
        
        //=========UIScrollView Content Size=========//
        self.myScrollview?.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 75)
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
    func InternetConnectionNotAvailable1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUserProfile()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure1()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUserProfile()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
    
    //=======Internet Connection Not Available=======//
    func InternetConnectionNotAvailable2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUpdateProfile()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure2()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getUpdateProfile()
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
