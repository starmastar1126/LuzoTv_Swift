//
//  Register.swift
//  LiveTV
//
//  Created by Apple on 03/07/19.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import ADCountryPicker


class Register: UIViewController,UITextFieldDelegate
{
    var spinner: SWActivityIndicatorView!
    var picker:ADCountryPicker = ADCountryPicker()
    var pickedDialCode:String = String()
    var numberValid:Bool = false
    
    
    var success:Int = Int()
    var message:String = String()
    @IBOutlet weak var regionImage: UIImageView!
    
    @IBOutlet private weak var myScrollview: UIScrollView!
    @IBOutlet var lblsignup : UILabel?
    @IBOutlet var lblusername : UILabel?
    @IBOutlet var lblemail : UILabel?
    @IBOutlet var lblpassword : UILabel?
    @IBOutlet var lblphone : UILabel?
    @IBOutlet private weak var txtusername: UITextField!
    @IBOutlet private weak var txtemail: UITextField!
    @IBOutlet private weak var txtpassword: UITextField!
    @IBOutlet private weak var txtphone: FPNTextField!
    @IBOutlet var btnregister : UIButton?
    @IBOutlet var lblalreadyaccount : UILabel?
    @IBOutlet var btnlogin : UIButton?
    @IBOutlet var lineView : UIView?
    @IBOutlet var lblline1 : UILabel?
    @IBOutlet var lblline2 : UILabel?
    var RegisterArray = NSMutableArray()
    
    @IBOutlet private weak var txtgender: UITextField!
    @IBOutlet private weak var txtagerange: UITextField!
    @IBOutlet private weak var txtcountry: UITextField!
    @IBOutlet private weak var txtregion: UITextField!
    
    
    @IBOutlet var lblgender : UILabel?
    @IBOutlet var lblagerange : UILabel?
    @IBOutlet var lblcountry : UILabel?
    @IBOutlet var lblregion : UILabel?
    
    
    
    
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
        txtphone.setFlag(for: FPNCountryCode(rawValue: "NG")!)
        self.pickedDialCode = "+234"
        txtphone.textColor = .white
       txtphone.delegate = self
        self.txtgender.inputView = UIView()
        self.txtagerange.inputView = UIView()
        self.txtcountry.inputView = UIView()
        self.txtregion.inputView = UIView()
        
        picker.delegate = self
        
        //=======UIKeyboard Hide & Show Methods======//
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
      
    }
    
    //======Register Button Click======//
    @IBAction func OnRegisterClick(sender:UIButton)
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
        }else if (self.txtgender.text == "") {
            self.txtgender?.bs_setupErrorMessageView(withMessage: CommonMessage.Select_Gender())
            self.txtgender?.bs_showError()
        }else if (self.txtagerange.text == "") {
            self.txtagerange?.bs_setupErrorMessageView(withMessage: CommonMessage.Select_Age())
            self.txtagerange?.bs_showError()
        }else if (self.txtcountry.text == "") {
            self.txtcountry?.bs_setupErrorMessageView(withMessage: CommonMessage.Select_Country())
            self.txtcountry?.bs_showError()
        }else if self.numberValid == false {
            self.txtphone?.bs_setupErrorMessageView(withMessage: "Number is invalid")
        } else {
            self.txtusername?.resignFirstResponder()
            self.txtemail?.resignFirstResponder()
            self.txtpassword?.resignFirstResponder()
            self.txtphone?.resignFirstResponder()
            self.txtgender?.resignFirstResponder()
            self.txtagerange?.resignFirstResponder()
            self.txtcountry?.resignFirstResponder()
            self.txtphone.resignFirstResponder()
            self.getRegister()
        }
    }
    
    //===========Get Register Data==========//
    func getRegister()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            self.sendRegisterData(name: txtusername.text!,
                                  email: txtemail.text!,
                                  password: txtpassword.text!,
                                  mobileCode: self.pickedDialCode,
                                  mobileNumber: txtphone.text!,
                                  gender: txtgender.text!,
                                  ageRange: txtagerange.text!, country: txtcountry.text!,
                                  region: txtregion.text ?? "")
            //self.getRegisterData(encodedString)
        } else {
            self.InternetConnectionNotAvailable()
        }
        
    }
    func sendRegisterData(name:String,
                          email:String,
                          password:String,
                          mobileCode:String,
                          mobileNumber:String,
                          gender:String,
                          ageRange:String,
                          country:String,
                          region:String){
        
        let url = URL(string: "http://luzotv.com/api/registrationUser.php")!
        
        let parameters: [String: Any] = [
            "function":"signup",
            "user_type":"Normal",
            "name": name,
            "email": email,
            "password":password,
            "phone_code":mobileCode,
            "phone":mobileNumber,
            "gender":gender,
            "age_range":ageRange,
            "country":country,
            "region":region,
            "confirm_code":"",
            "status":"1",
            "profile_status":"1"
        ]
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
       
        
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            print(response)
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
           
            let jsonData = responseString!.data(using: .utf8)!
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as? [String:Any]
                {
                    if let success = jsonArray["success"] as? Int {
                        self.success = success
                    }
                    if let message = jsonArray["message"] as? String {
                        self.message = message
                    }
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
            
            DispatchQueue.main.async{
                self.stopSpinner()
                if self.success == 0 {
                    let alert = SCLAlertView()
                    
                    _ = alert.showError("\(self.message)")
                } else {
                    let alert = SCLAlertView()
                    
                    _ = alert.showInfo("\(self.message)")
                    self.navigationController?.popViewController(animated: true)
                }
                
               
            }
        }
        
        task.resume()
        
    }
//    func getRegisterData(_ requesturl: String?)
//    {
//        let salt:String = CommonUtils.getSalt() as String
//        let sign = CommonUtils.getSign(salt)
//        let name = self.txtusername?.text
//        let email = self.txtemail?.text
//        let password = self.txtpassword?.text
//        let phone = self.txtphone?.text
//
//        let dict = ["salt":salt,
//                    "sign":sign,
//                    "method_name":"user_register",
//                    "name":name,
//                    "email":email,
//                    "password":password,
//                    "phone":phone]
//
//        let data = CommonUtils.getBase64EncodedString(dict as [AnyHashable : Any])
//        let strDict = ["data": data]
//        print("Register API URL : \(strDict)")
//        
//        let manager = AFHTTPSessionManager()
//        manager.post(requesturl!, parameters: strDict, progress: nil, success:
//        { task, responseObject in if let responseObject = responseObject
//            {
//                print("Register Responce Data : \(responseObject)")
//                self.RegisterArray.removeAllObjects()
//                let response = responseObject as AnyObject?
//                let storeArr = response?.object(forKey: CommonUtils.getAPIKeyName()) as! NSArray
//                for i in 0..<storeArr.count {
//                    let storeDict = storeArr[i] as? [AnyHashable : Any]
//                    if storeDict != nil {
//                        self.RegisterArray.add(storeDict as Any)
//                    }
//                }
//                print("RegisterArray Count = \(self.RegisterArray.count)")
//
//                DispatchQueue.main.async {
//                    let success = (self.RegisterArray.value(forKey: "success") as! NSArray).componentsJoined(by: "")
//                    if (success == "0") {
//                        let msg = (self.RegisterArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
//                        KSToastView.ks_showToast(msg, duration: 3.0) {
//                            print("\("End!")")
//                        }
//                    } else {
//                        let msg = (self.RegisterArray.value(forKey: "msg") as! NSArray).componentsJoined(by: "")
//                        KSToastView.ks_showToast(msg, duration: 3.0) {
//                            print("\("End!")")
//                        }
//                        self.addInformation()
//                        _ = self.navigationController?.popViewController(animated:true)
//                    }
//                }
//
//                self.stopSpinner()
//            }
//        }, failure: { operation, error in
//            self.Networkfailure()
//            self.stopSpinner()
//        })
//    }
    
    func addInformation(){
        
    }
    //======Login Click======//
    @IBAction func OnLoginClick(sender:UIButton)
    {
        _ = self.navigationController?.popViewController(animated:true)
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
        
        if textField == txtgender {
            let alert = SCLAlertView()
            _ = alert.addButton("Male") {
                self.txtgender.text = "Male"
            }
            _ = alert.addButton("Female") {
                self.txtgender.text = "Female"
            }
            _ = alert.showInfo("Select Gender")
        }
        
        if textField == txtagerange {
            let alert = SCLAlertView()
            _ = alert.addButton("Below 12") {
                self.txtagerange.text = "Below 12"
            }
            _ = alert.addButton("13 - 17") {
                self.txtagerange.text = "13 - 17"
            }
            _ = alert.addButton("18 - 24") {
                self.txtagerange.text = "18 - 24"
            }
            _ = alert.addButton("25 - 34") {
                self.txtagerange.text = "25 - 34"
            }
            _ = alert.addButton("35 - 44") {
                self.txtagerange.text = "35 - 44"
            }
            _ = alert.addButton("45 - 64") {
                self.txtagerange.text = "45 - 64"
            }
            _ = alert.addButton("45 - 65") {
                self.txtagerange.text = "45 - 65"
            }
            _ = alert.addButton("Above 65") {
                self.txtagerange.text = "Above 65"
            }
            _ = alert.showInfo("Select Age Range")
        }
        
        if textField == txtregion {
            let alert = SCLAlertView()
            _ = alert.addButton("North East") {
                self.txtregion.text = "North East"
            }
            _ = alert.addButton("North West") {
                self.txtregion.text = "North West"
            }
            _ = alert.addButton("North Central") {
                self.txtregion.text = "North Central"
            }
            _ = alert.addButton("South South") {
                self.txtregion.text = "South South"
            }
            _ = alert.addButton("South East") {
                self.txtregion.text = "South East"
            }
            _ = alert.addButton("South West") {
                self.txtregion.text = "South West"
            }
            
            _ = alert.showInfo("Select Region")
        }
        if textField == txtcountry {
            let pickerNavigationController = UINavigationController(rootViewController: picker)
            self.present(pickerNavigationController, animated: true, completion: nil)
        }
        
        
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
        
        //=====Welcome Title 1====//
        self.lblsignup?.text = CommonMessage.SignUp()
        
        //=====User Name Lable====//
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
        let rightBorder2 = CALayer()
        rightBorder2.frame = CGRect(x: (self.lblpassword?.frame.size.width)! - 2, y: (self.lblpassword?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder2.borderWidth = 2.0
        rightBorder2.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblpassword?.layer.addSublayer(rightBorder2)
        
        //=====Phone Lable====//
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
        
        
        //=========Phone Lable========//
        //1.Bottom
        let bottomBorder5 = CALayer()
        bottomBorder5.frame = CGRect(x: 0, y: (self.lblgender?.frame.size.height)!, width: (self.lblgender?.frame.size.width)!, height: 2.0)
        bottomBorder5.borderWidth = 2.0
        bottomBorder5.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblgender?.layer.addSublayer(bottomBorder5)
        //2.Left
        let leftBorder5 = CALayer()
        leftBorder5.frame = CGRect(x: 0, y: (self.lblgender?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder5.borderWidth = 2.0
        leftBorder5.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblgender?.layer.addSublayer(leftBorder5)
        //3.Right
        let rightBorder5 = CALayer()
        rightBorder5.frame = CGRect(x: (self.lblgender?.frame.size.width)! - 2, y: (self.lblgender?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder5.borderWidth = 2.0
        rightBorder5.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblgender?.layer.addSublayer(rightBorder5)
        
        //=========Phone Lable========//
        //1.Bottom
        let bottomBorder6 = CALayer()
        bottomBorder6.frame = CGRect(x: 0, y: (self.lblagerange?.frame.size.height)!, width: (self.lblagerange?.frame.size.width)!, height: 2.0)
        bottomBorder6.borderWidth = 2.0
        bottomBorder6.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblagerange?.layer.addSublayer(bottomBorder6)
        //2.Left
        let leftBorder6 = CALayer()
        leftBorder6.frame = CGRect(x: 0, y: (self.lblagerange?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder6.borderWidth = 2.0
        leftBorder6.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblagerange?.layer.addSublayer(leftBorder6)
        //3.Right
        let rightBorder6 = CALayer()
        rightBorder6.frame = CGRect(x: (self.lblagerange?.frame.size.width)! - 2, y: (self.lblagerange?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder6.borderWidth = 2.0
        rightBorder6.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblagerange?.layer.addSublayer(rightBorder6)
        
        
        //=========Phone Lable========//
        //1.Bottom
        let bottomBorder7 = CALayer()
        bottomBorder7.frame = CGRect(x: 0, y: (self.lblcountry?.frame.size.height)!, width: (self.lblcountry?.frame.size.width)!, height: 2.0)
        bottomBorder7.borderWidth = 2.0
        bottomBorder7.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblcountry?.layer.addSublayer(bottomBorder7)
        //2.Left
        let leftBorder7 = CALayer()
        leftBorder7.frame = CGRect(x: 0, y: (self.lblcountry?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder7.borderWidth = 2.0
        leftBorder7.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblcountry?.layer.addSublayer(leftBorder7)
        //3.Right
        let rightBorder7 = CALayer()
        rightBorder7.frame = CGRect(x: (self.lblcountry?.frame.size.width)! - 2, y: (self.lblcountry?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder7.borderWidth = 2.0
        rightBorder7.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblcountry?.layer.addSublayer(rightBorder7)
        
        //=========Phone Lable========//
        //1.Bottom
        let bottomBorder8 = CALayer()
        bottomBorder8.frame = CGRect(x: 0, y: (self.lblregion?.frame.size.height)!, width: (self.lblregion?.frame.size.width)!, height: 2.0)
        bottomBorder8.borderWidth = 2.0
        bottomBorder8.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblregion?.layer.addSublayer(bottomBorder8)
        //2.Left
        let leftBorder8 = CALayer()
        leftBorder8.frame = CGRect(x: 0, y: (self.lblregion?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder8.borderWidth = 2.0
        leftBorder8.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblregion?.layer.addSublayer(leftBorder8)
        //3.Right
        let rightBorder8 = CALayer()
        rightBorder8.frame = CGRect(x: (self.lblregion?.frame.size.width)! - 2, y: (self.lblregion?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder8.borderWidth = 2.0
        rightBorder8.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.lblregion?.layer.addSublayer(rightBorder8)
        
        
        
        
        //=====Username Placeholder Color====//
        self.txtusername?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Name(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=====Email Placeholder Color====//
        self.txtemail?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Email(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=====Password Placeholder Color====//
        self.txtpassword?.attributedPlaceholder = NSAttributedString(string: CommonMessage.Password(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=====Password Placeholder Color====//
        self.txtphone?.attributedPlaceholder = NSAttributedString(string: "Mobile Number",  attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: Colors.getTextBorderColor(), alpha: 0.7)!])
        
        self.txtgender?.attributedPlaceholder = NSAttributedString(string: "Gender",attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString:Colors.getTextBorderColor(), alpha: 0.7)!])
        
        self.txtagerange?.attributedPlaceholder = NSAttributedString(string: "Age Range",attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString:Colors.getTextBorderColor(), alpha: 0.7)!])
        
        self.txtcountry?.attributedPlaceholder = NSAttributedString(string: "Country",attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString:Colors.getTextBorderColor(), alpha: 0.7)!])
        
        self.txtregion?.attributedPlaceholder = NSAttributedString(string: "Region",attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString:Colors.getTextBorderColor(), alpha: 0.7)!])
        
        //=====Register Button Corner Radius====//
        self.btnregister?.layer.cornerRadius = (self.btnregister?.frame.size.height)!/2
        self.btnregister?.clipsToBounds = true
        self.btnregister?.setTitle(CommonMessage.REGISTER(), for: UIControl.State.normal)
        self.btnregister?.backgroundColor = UIColor(hexString: Colors.getButtonColor1())
        
        //=====Already Have an Account Button====//
        self.lblalreadyaccount?.text = CommonMessage.AlreadyHaveanAccount()
        
        //=====Login Button====//
        self.btnlogin?.setTitle(CommonMessage.Login(), for: UIControl.State.normal)
        self.btnlogin?.setTitleColor(UIColor(hexString: Colors.getButtonColor2()), for: UIControl.State.normal)
        
        //=====Bottom Line====//
        self.lineView?.layer.cornerRadius = (self.lineView?.frame.size.height)!/2
        self.lineView?.clipsToBounds = true
        self.lblline1?.backgroundColor = UIColor(hexString: Colors.getButtonColor1())
        self.lblline2?.backgroundColor = UIColor(hexString: Colors.getButtonColor2())
        
        //=======Set UIScrollView Content Size========//
        //self.myScrollview?.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 875)
        self.myScrollview?.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
       
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
            self.getRegister()
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
            self.getRegister()
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


extension Register:ADCountryPickerDelegate{
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        picker.dismiss(animated: true, completion: nil)
        
        self.txtcountry.text = name
        if code == "NG" {
            lblregion?.isHidden = false
            regionImage.isHidden = false
            txtregion.isHidden = false
            
        } else {
            lblregion?.isHidden = true
            regionImage.isHidden = true
            txtregion.isHidden = true
        }
        
    }
    
}
extension Register: FPNTextFieldDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        self.pickedDialCode = dialCode
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            self.numberValid = true
            
            
        } else {
            self.numberValid = false
            print("Number invalid")
        }
    }
}
extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
