//
//  ForgotPassword.swift
//  LiveTV
//
//  Created by Apple on 03/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit

class ForgotPassword: UIViewController,UITextFieldDelegate
{
    var spinner: SWActivityIndicatorView!
    
    @IBOutlet private weak var myScrollview: UIScrollView!
    @IBOutlet var lblstatusbar : UILabel?
    @IBOutlet var lblheader : UILabel?
    @IBOutlet var lblheadername : UILabel?
    @IBOutlet var lblfgp : UILabel?
    @IBOutlet var lbldesc : UILabel?
    @IBOutlet var lblemail : UILabel?
    @IBOutlet private weak var txtemail: UITextField!
    @IBOutlet var btnsend : UIButton?
    var ForgotArray = NSMutableArray()
    
    private lazy var toolbar: FormToolbar = {
        return FormToolbar(inputs: self.inputs)
    }()
    private var inputs: [FormInput] {
        return [self.txtemail]
    }
    private weak var activeInput: FormInput?
    
    override func loadView()
    {
        super.loadView()
        
        self.txtemail.delegate = self
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //=======UIKeyboard Hide & Show Methods======//
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //======Send Click======//
    @IBAction func OnSendClick(sender:UIButton)
    {
        if (self.txtemail?.text == "") {
            self.txtemail?.bs_setupErrorMessageView(withMessage: CommonMessage.Enter_email_address())
            self.txtemail?.bs_showError()
        } else if !CommonUtils.validateEmail(with: self.txtemail?.text) {
            self.txtemail?.bs_setupErrorMessageView(withMessage: CommonMessage.Enter_Valid_email_address())
            self.txtemail?.bs_showError()
        }  else {
            self.txtemail?.resignFirstResponder()
            self.getForgot()
        }
    }
    
    //===========Get Forgot Password Data==========//
    func getForgot()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let str = String(format: "%@api.php",CommonUtils.getBaseUrl())
            let encodedString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.getForgotData(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
    }
    func getForgotData(_ requesturl: String?)
    {
        let salt:String = CommonUtils.getSalt() as String
        let sign = CommonUtils.getSign(salt)
        let email = self.txtemail?.text
        let dict = ["salt":salt, "sign":sign, "method_name":"forgot_pass", "user_email":email]
        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
        let strDict = ["data": data]
        print("Forgot Password API URL : \(strDict)")
        
        let manager = AFHTTPSessionManager()
        manager.post(requesturl!, parameters: strDict, progress: nil, success:
            { task, responseObject in if let responseObject = responseObject
            {
                print("Forgot Responce Data : \(responseObject)")
                self.ForgotArray.removeAllObjects()
                let response = responseObject as AnyObject?
                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
                for i in 0..<storeArr.count {
                    let storeDict = storeArr[i] as? [AnyHashable : Any]
                    if storeDict != nil {
                        self.ForgotArray.add(storeDict as Any)
                    }
                }
                print("ForgotArray Count = \(self.ForgotArray.count)")
                
                DispatchQueue.main.async {
                    let success = (self.ForgotArray.value(forKey: "success") as! NSArray).componentsJoined(by: "")
                    if (success == "0") {
                        let msg = (self.ForgotArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
                        KSToastView.ks_showToast(msg, duration: 3.0) {
                            print("\("End!")")
                        }
                    } else {
                        let msg = (self.ForgotArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
                        KSToastView.ks_showToast(msg, duration: 3.0) {
                            print("\("End!")")
                        }
                        _ = self.navigationController?.popViewController(animated:true)
                    }
                }
                
                self.stopSpinner()
                }
        }, failure: { operation, error in
            self.Networkfailure()
            self.stopSpinner()
        })
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //1.Background Color
        self.view.backgroundColor = UIColor(hexString:Colors.getForgotPasswordBackgroundColor())

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
        self.lblheadername?.text = CommonMessage.ForgotYourPassword()
        
        //5.Forgot Your Password Lable
        self.lblfgp?.text = CommonMessage.ForgotYourPassword()
        
        //6.Forgot Password Description
        self.lbldesc?.text = CommonMessage.getForgotDescription()
        
        //7.Email Placeholder Color
        self.txtemail?.attributedPlaceholder = NSAttributedString(string: CommonMessage.EnterYourEmail(), attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        //8.Email Lable
        //1.Bottom
        let bottomBorder1 = CALayer()
        bottomBorder1.frame = CGRect(x: 0, y: (self.lblemail?.frame.size.height)!, width: (self.lblemail?.frame.size.width)!, height: 2.0)
        bottomBorder1.borderWidth = 1.5
        bottomBorder1.borderColor = UIColor(hexString: "#000000", alpha: 0.3)?.cgColor
        self.lblemail?.layer.addSublayer(bottomBorder1)
        //2.Left
        let leftBorder1 = CALayer()
        leftBorder1.frame = CGRect(x: 0, y: (self.lblemail?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder1.borderWidth = 1.5
        leftBorder1.borderColor = UIColor(hexString: "#000000", alpha: 0.3)?.cgColor
        self.lblemail?.layer.addSublayer(leftBorder1)
        //3.Right
        let rightBorder1 = CALayer()
        rightBorder1.frame = CGRect(x: (self.lblemail?.frame.size.width)! - 2, y: (self.lblemail?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder1.borderWidth = 1.5
        rightBorder1.borderColor = UIColor(hexString: "#000000", alpha: 0.3)?.cgColor
        self.lblemail?.layer.addSublayer(rightBorder1)
        
        //9.Send Button
        self.btnsend?.layer.cornerRadius = (self.btnsend?.frame.size.height)!/2
        self.btnsend?.clipsToBounds = true
        self.btnsend?.setTitle(CommonMessage.SEND(), for: UIControl.State.normal)
        self.btnsend?.backgroundColor = UIColor(hexString: Colors.getButtonColor1())
        
        //10.Send Button Shadow
        self.btnsend?.layer.shadowColor = UIColor.darkGray.cgColor
        self.btnsend?.layer.shadowOffset = CGSize(width:0, height:0)
        self.btnsend?.layer.shadowRadius = 1.0
        self.btnsend?.layer.shadowOpacity = 1
        self.btnsend?.layer.masksToBounds = false
        self.btnsend?.layer.shadowPath = UIBezierPath(roundedRect: (self.btnsend?.bounds)!, cornerRadius: (self.btnsend?.layer.cornerRadius)!).cgPath
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
        
        self.txtemail?.resignFirstResponder()
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        toolbar.update()
        activeInput = textField
        
        self.txtemail?.bs_hideError()
    }
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        toolbar.update()
        activeInput = textView
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,                   replacementString string: String) -> Bool
    {
        self.txtemail?.bs_hideError()
        return true
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
            self.getForgot()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getForgot()
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
