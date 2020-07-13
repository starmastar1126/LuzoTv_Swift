//
//  Login.swift
//  LiveTV
//
//  Created by Apple on 03/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import SafariServices
class Login: UIViewController,UITextFieldDelegate,CheckboxDelegate
{
    var spinner: SWActivityIndicatorView!
   
    @IBOutlet weak var mobileTextfield: FPNTextField!
    @IBOutlet weak var lblcountry: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var btnAdvertise: UIButton!
    
    
    
    @IBOutlet var myScrollview : UIScrollView?
    @IBOutlet var lblwlctitle1 : UILabel?
    @IBOutlet var lblwlctitle2 : UILabel?
    @IBOutlet var lblemail : UILabel?
    @IBOutlet var lblpassword : UILabel?
    @IBOutlet var txtemail : UITextField?
    @IBOutlet var txtpassword : UITextField?
    @IBOutlet weak var checkbox: CCheckbox!
    @IBOutlet var lblrememberme : UILabel?
    @IBOutlet var btnlogin : UIButton?
    @IBOutlet var btnforgot : UIButton?
    @IBOutlet var lbldonotaccount : UILabel?
    
    @IBOutlet var lineView : UIView?
    @IBOutlet var lblline1 : UILabel?
    @IBOutlet var lblline2 : UILabel?
    var LoginArray = NSMutableArray()
    
    //========Goto Registration Screen========//
    @IBAction func gotoRegisterScreen(_ sender: Any) {
        CallMobileRegisterationViewController()
        
    }
    
    @IBAction func openAdvertise(_ sender: UIButton) {
        guard let url = URL(string: "https://luzotv.com/advertiser/dashboard") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mobileTextfield.delegate = self
        
        //========PackageName Notification========//
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivePackageNameNotification(_:)), name: NSNotification.Name("PackageNameNotification"), object: nil)
        
        //========Set CheckBox Data========//
        self.checkbox.delegate = self
        self.checkbox.animation = .showHideTransitionViews
        let isChecked = UserDefaults.standard.bool(forKey: "IS_CHECKED")
        if (isChecked) {
            self.checkbox.isCheckboxSelected = false
        } else {
            self.checkbox.isCheckboxSelected = true
        }
        self.txtemail?.text = UserDefaults.standard.string(forKey: "EMAIL")
        self.txtpassword?.text = UserDefaults.standard.string(forKey: "PASSWORD")
    }
    
    //======Login Click======//
    @IBAction func OnLoginClick(sender:UIButton)
    {
        if (self.txtemail?.text == "") {
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
            self.txtemail?.resignFirstResponder()
            self.txtpassword?.resignFirstResponder()
            self.getLogin()
        }
    }
    
    //===========Get Login Data==========//
    func getLogin()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getLoginData(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getLoginData(_ requesturl: String?)
    {
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let email = self.txtemail?.text
        let password = self.txtpassword?.text
        let dict = ["salt":salt, "sign":sign, "method_name":"user_login", "email":email, "password":password]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Login API URL : \(strDict)")
        
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
        { task, responseObject in if let responseObject = responseObject
            {
                print("Login Responce Data : \(responseObject)")
                self.LoginArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.LoginArray.add(storeDict as Any)
                    }
                }
                print("LoginArray Count = \(self.LoginArray.count)")
                
                DispatchQueue.main.async {
                    let success = (self.LoginArray.value(forKey: "success") as! NSArray).componentsJoined(by: "")
                    if (success == "0") {
                        let msg = (self.LoginArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
                        KSToastView.ks_showToast(msg, duration: 3.0) {
                            print("\("End!")")
                        }
                    } else {
                        UserDefaults.standard.set(true, forKey: "LOGIN")
                        let user_id = (self.LoginArray.value(forKey: "user_id") as! NSArray).componentsJoined(by: "")
                        UserDefaults.standard.set(user_id, forKey: "USER_ID")
                        let user_name = (self.LoginArray.value(forKey: "name") as! NSArray).componentsJoined(by: "")
                        UserDefaults.standard.set(user_name, forKey: "USER_NAME")
                        
                        let isSKIP = UserDefaults.standard.bool(forKey: "IS_SKIP")
                        if (isSKIP) {
                            _ = self.navigationController?.popViewController(animated:true)
                        } else {
                            UserDefaults.standard.set(false, forKey: "IS_SKIP")
                            self.CallHomeViewController()
                        }
                    }
                }
                self.stopSpinner()
            }
        }, failure: { operation, error in
            self.Networkfailure()
            self.stopSpinner()
        })
    }
    
    //======Skip Click======//
    @IBAction func OnSkipClick(sender:UIButton)
    {
        let isSKIP = UserDefaults.standard.bool(forKey: "IS_SKIP")
        if (isSKIP) {
            UserDefaults.standard.set(false, forKey: "IS_SKIP")
            _ = navigationController?.popViewController(animated:true)
        } else {
            self.CallHomeViewController()
        }
    }
    func CallMobileRegisterationViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = MobileRegistration(nibName: "MobileRegistration_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = MobileRegistration(nibName: "MobileRegistration_iPhoneX", bundle: nil)
        } else {
            view = MobileRegistration(nibName: "MobileRegistration", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    //======Sign Up Click======//
    @IBAction func OnSignUpClick(sender:UIButton)
    {
        self.CallRegisterViewController()
    }
    
    //======Forgot Password Click======//
    @IBAction func OnForgotPasswordClick(sender:UIButton)
    {
        self.CallForgotPasswordController()
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
    
    func CallRegisterViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = Register(nibName: "Register_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = Register(nibName: "Register_iPhoneX", bundle: nil)
        } else {
            view = Register(nibName: "Register", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func CallForgotPasswordController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = ForgotPassword(nibName: "ForgotPassword_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = ForgotPassword(nibName: "ForgotPassword_iPhoneX", bundle: nil)
        } else {
            view = ForgotPassword(nibName: "ForgotPassword", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //=====Welcome Title 1====//
        self.lblwlctitle1?.text = CommonMessage.WelcomeBack()
        
        //=====Welcome Title 2====//
        self.lblwlctitle2?.text = CommonMessage.SignInToContinue()
        
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
        
        //=====Country Lable====//
        //1.Bottom
        let bottomBorder11 = CALayer()
        bottomBorder11.frame = CGRect(x: 0, y: (self.lblcountry?.frame.size.height)!, width: (self.lblemail?.frame.size.width)!, height: 2.0)
        bottomBorder11.borderWidth = 2.0
        bottomBorder11.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblcountry?.layer.addSublayer(bottomBorder11)
        //2.Left
        let leftBorder11 = CALayer()
        leftBorder11.frame = CGRect(x: 0, y: (self.lblcountry?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder11.borderWidth = 2.0
        leftBorder11.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblcountry?.layer.addSublayer(leftBorder11)
        //3.Right
        let rightBorder11 = CALayer()
        rightBorder11.frame = CGRect(x: (self.lblcountry?.frame.size.width)! - 2, y: (self.lblemail?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder11.borderWidth = 2.0
        rightBorder11.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblcountry?.layer.addSublayer(rightBorder11)
        
        
        
        //=====Password Lable====//
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
        let rightBorder3 = CALayer()
        rightBorder3.frame = CGRect(x: (self.lblpassword?.frame.size.width)! - 2, y: (self.lblpassword?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder3.borderWidth = 2.0
        rightBorder3.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblpassword?.layer.addSublayer(rightBorder3)
        
        //=====Email Placeholder Color====//
        self.txtemail?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Email(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=====Password Placeholder Color====//
        self.txtpassword?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Password(),       attributes:[NSAttributedString.Key.foregroundColor: UIColor(hexString:Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=====Remember Me Lable====//
        self.lblrememberme?.text = CommonMessage.RememberMe()
        
        //=====Login Button====//
        self.btnlogin?.layer.cornerRadius = (self.btnlogin?.frame.size.height)!/2
        self.btnlogin?.clipsToBounds = true
        self.btnlogin?.setTitle(CommonMessage.LOGIN(), for: UIControl.State.normal)
        self.btnlogin?.backgroundColor = UIColor(hexString: Colors.getButtonColor1())
        
        //=====Skip Button====//
        self.registerBtn?.layer.cornerRadius = (self.registerBtn?.frame.size.height)!/2
        self.registerBtn?.clipsToBounds = true
//        let isSKIP = UserDefaults.standard.bool(forKey: "IS_SKIP")
//        if (isSKIP) {
//            self.btnskip?.setTitle(CommonMessage.BACK(), for: UIControl.State.normal)
//        } else {
//            self.btnskip?.setTitle(CommonMessage.SKIP(), for: UIControl.State.normal)
//        }
        self.registerBtn?.backgroundColor = UIColor(hexString: Colors.getTextBorderColor())
        
        //=====Forgot Password Button====//
        self.btnforgot?.setTitle(CommonMessage.ForgotYourPassword(), for: UIControl.State.normal)
        
        //=====Don't Account Button====//
       //self.lbldonotaccount?.text = CommonMessage.DontHaveanAccount()
        
        //=====Sign Up Button====//
        self.btnAdvertise?.setTitle(CommonMessage.GetStarted(), for: UIControl.State.normal)
        self.btnAdvertise?.setTitleColor(UIColor(hexString: Colors.getButtonColor2()), for: UIControl.State.normal)
        
        //=====Bottom Line====//
        self.lineView?.layer.cornerRadius = (self.lineView?.frame.size.height)!/2
        self.lineView?.clipsToBounds = true
        self.lblline1?.backgroundColor = UIColor(hexString: Colors.getButtonColor1())
        self.lblline2?.backgroundColor = UIColor(hexString: Colors.getButtonColor2())
    }
    
    //======UITextfield Delegate Methods======//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.txtemail?.resignFirstResponder()
        self.txtpassword?.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.txtemail?.bs_hideError()
        self.txtpassword?.bs_hideError()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,                   replacementString string: String) -> Bool
    {
        self.txtemail?.bs_hideError()
        self.txtpassword?.bs_hideError()
        return true
    }
    
    //======Checkbox Delegate Methods======//
    func didDeselect(_ checkbox: CCheckbox)
    {
        UserDefaults.standard.set(true, forKey: "IS_CHECKED")
        UserDefaults.standard.set(self.txtemail?.text, forKey: "EMAIL")
        UserDefaults.standard.set(self.txtpassword?.text, forKey: "PASSWORD")
    }
    func didSelect(_ checkbox: CCheckbox)
    {
        UserDefaults.standard.set(false, forKey: "IS_CHECKED")
        UserDefaults.standard.set("", forKey: "EMAIL")
        UserDefaults.standard.set("", forKey: "PASSWORD")
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
            self.getLogin()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getLogin()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
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

extension Login:FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            
           
        } else {
            
        }
    }
    
    
}
