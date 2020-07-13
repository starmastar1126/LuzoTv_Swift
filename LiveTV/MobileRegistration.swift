//
//  MobileRegistration.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 15/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import FirebaseAuth
import Firebase
import ADCountryPicker

class MobileRegistration: UIViewController,UITextFieldDelegate {
    
    var numberValid:Bool = Bool()
    var number:String = String()
    var dialCode:String = String()
    
    
    var success:Int = Int()
    var responseMessage:String = String()
    
    @IBOutlet weak var numberTextField: FPNTextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var verifyBtn: UIButton!
    
    
    
    @IBOutlet weak var otpBtn: UIButton!
    @IBOutlet weak var otpCode: UITextField!
    @IBOutlet weak var otpCodeLabel: UILabel!
    
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    

    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    
    var spinner: SWActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTextField.setFlag(for: FPNCountryCode(rawValue: "NG")!)
        dialCode = "+234"
        
        numberTextField.textColor = .white
        //=====Phone Number Label====//
        //1.Bottom
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: (self.numberLabel?.frame.size.height)!, width: (self.numberLabel?.frame.size.width)!, height: 2.0)
        bottomBorder.borderWidth = 2.0
        bottomBorder.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.numberLabel?.layer.addSublayer(bottomBorder)
        
        
        //2.Left
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0, y: (self.numberLabel?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder.borderWidth = 2.0
        leftBorder.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.numberLabel?.layer.addSublayer(leftBorder)
        
        //3.Right
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: (self.numberLabel?.frame.size.width)! - 2, y: (self.numberLabel?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder.borderWidth = 2.0
        rightBorder.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.numberLabel?.layer.addSublayer(rightBorder)
        
        
        //=====OTP Number Label====//
        //1.Bottom
        let bottomBorder2 = CALayer()
        bottomBorder2.frame = CGRect(x: 0, y: (self.otpCodeLabel?.frame.size.height)!, width: (self.otpCodeLabel?.frame.size.width)!, height: 2.0)
        bottomBorder2.borderWidth = 2.0
        bottomBorder2.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.otpCodeLabel?.layer.addSublayer(bottomBorder2)
        
        
        //2.Left
        let leftBorder2 = CALayer()
        leftBorder2.frame = CGRect(x: 0, y: (self.otpCodeLabel?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder2.borderWidth = 2.0
        leftBorder2.borderColor = UIColor.white.cgColor
        self.otpCodeLabel?.layer.addSublayer(leftBorder2)
        
        //3.Right
        let rightBorder2 = CALayer()
        rightBorder2.frame = CGRect(x: (self.otpCodeLabel?.frame.size.width)! - 2, y: (self.otpCodeLabel?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder2.borderWidth = 2.0
        rightBorder2.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.otpCodeLabel?.layer.addSublayer(rightBorder2)
        
        
        //=====Password Label====//
        //1.Bottom
        let bottomBorder3 = CALayer()
        bottomBorder3.frame = CGRect(x: 0, y: (self.passwordLabel?.frame.size.height)!, width: (self.passwordLabel?.frame.size.width)!, height: 2.0)
        bottomBorder3.borderWidth = 2.0
        bottomBorder3.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.passwordLabel?.layer.addSublayer(bottomBorder3)
        
        
        //2.Left
        let leftBorder3 = CALayer()
        leftBorder3.frame = CGRect(x: 0, y: (self.passwordLabel?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder3.borderWidth = 2.0
        leftBorder3.borderColor = UIColor.white.cgColor
        self.passwordLabel?.layer.addSublayer(leftBorder2)
        
        //3.Right
        let rightBorder3 = CALayer()
        rightBorder3.frame = CGRect(x: (self.passwordLabel?.frame.size.width)! - 2, y: (self.passwordLabel?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder3.borderWidth = 2.0
        rightBorder3.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.passwordLabel?.layer.addSublayer(rightBorder3)
        
        //=====Confirm Password Label====//
        //1.Bottom
        let bottomBorder4 = CALayer()
        bottomBorder4.frame = CGRect(x: 0, y: (self.confirmPasswordLabel?.frame.size.height)!, width: (self.confirmPasswordLabel?.frame.size.width)!, height: 2.0)
        bottomBorder4.borderWidth = 2.0
        bottomBorder4.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.confirmPasswordLabel?.layer.addSublayer(bottomBorder4)
        
        
        //2.Left
        let leftBorder4 = CALayer()
        leftBorder4.frame = CGRect(x: 0, y: (self.confirmPasswordLabel?.frame.size.height)! - 5, width: 2, height: 5)
        leftBorder4.borderWidth = 2.0
        leftBorder4.borderColor = UIColor.white.cgColor
        self.confirmPasswordLabel?.layer.addSublayer(leftBorder4)
        
        //3.Right
        let rightBorder4 = CALayer()
        rightBorder4.frame = CGRect(x: (self.confirmPasswordLabel?.frame.size.width)! - 2, y: (self.confirmPasswordLabel?.frame.size.height)! - 5, width: 2, height: 5)
        rightBorder4.borderWidth = 2.0
        rightBorder4.borderColor = UIColor(hexString: Colors.getTextBorderColor())?.cgColor
        self.confirmPasswordLabel?.layer.addSublayer(rightBorder2)
        
      
        
        self.verifyBtn.layer.cornerRadius = 5.0
        self.otpBtn.layer.cornerRadius = 5.0
    }
    
    

    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func verifyNumber(_ sender: Any) {
       
        
        if numberValid == true {
            self.startSpinner()
            PhoneAuthProvider.provider().verifyPhoneNumber("+923333333333", uiDelegate: nil) { (verificationID, error) in
                
                if let error = error {
                    self.stopSpinner()
                    
                    let alert = SCLAlertView()
                    _ = alert.addButton(CommonMessage.RETRY()) {
                        
                    }
                    alert.showError(error.localizedDescription, subTitle: "")
                    
                    return
                }
                self.stopSpinner()
                print(verificationID!)
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                
               
            }

        }else {
            let alert = SCLAlertView()
            alert.addButton("Retry") {
                
            }
            alert.showError("Number is Invalid")
        }
    }
 
    
    @IBAction func checkOTPCode(_ sender: Any) {
        if otpCode.text! != ""{
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") as! String
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: "123456")
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // ...
                    return
                }
                self.getRegister()
            }
            
        }
        
        
    }
    
    func getRegister(){
        if password.text! != "" && confirmPassword.text! != ""{
            
            if password.text! == confirmPassword.text! {
                
                if self.dialCode != "" {
                    self.registerUser(code: dialCode, mobileNumber: numberTextField.text!, password: confirmPassword.text!)
                    print("Sign in Successfull")
                }else {
                    let alert = SCLAlertView()
                    _ = alert.addButton(CommonMessage.RETRY()) {
                        
                    }
                    alert.showError("Please Select Your Country, Please Try Again", subTitle: "")
                }
                
            }else {
                let alert = SCLAlertView()
                _ = alert.addButton(CommonMessage.RETRY()) {
                    
                }
                alert.showError("Passwords Dont Match, Please Try Again", subTitle: "")
            }
            
            
            
            
        } else {
            let alert = SCLAlertView()
            _ = alert.addButton(CommonMessage.RETRY()) {
                
            }
            alert.showError("Passwords Fields Cannot Be Empty, Please Try Again", subTitle: "")
        }
       
    }
    func registerUser(code:String, mobileNumber:String, password:String){
        
        let urlStr:String = "http://luzotv.com/api/quick_signup"
        
        let params = ["phone_code":code,
                      "phone":mobileNumber,
                      "password":password]

        print(urlStr)
        print(params)
        let manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = nil;
        manager.post(urlStr, parameters: params, progress: nil, success:
            { task, responseObject in

                print(responseObject)
                if let json = responseObject as? [String:Any] {
                    print(json)
                    if let status = json["status"] as? Int {
                        self.success = status
                    }
                    if let message = json["msg"] as? String {
                        self.responseMessage = message
                    }
                }
                DispatchQueue.main.async {
                    
                    if self.success == 1{
                        let alert = SCLAlertView()
                        _ = alert.addButton("Okay") {
                            self.navigationController?.popViewController(animated: true)
                        
                    }
                        alert.showError("Success: \(self.success)", subTitle: "Message: \(self.responseMessage)")
                    } else {
                        let alert = SCLAlertView()
                        _ = alert.addButton("Okay") {
                            
                        }
                        alert.showError("Success: \(self.success)", subTitle: "Message: \(self.responseMessage)")
                    }
                    
                }


        }, failure: { operation, error in
            print(error.localizedDescription)
            self.Networkfailure()
            self.stopSpinner()
        })
    }
    
     @IBAction func tryAnotherWay(_ sender: Any) {
        CallRegisterationViewController()
        
     }
    func CallRegisterationViewController()
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
    
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
            
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
    }
    func Networkfailure()
    {
        let alert = SCLAlertView()
        _ = alert.addButton(CommonMessage.RETRY()) {
           
        }
        _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
    }
}
extension MobileRegistration:FPNTextFieldDelegate{
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        self.dialCode = dialCode
        print(dialCode)
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
extension MobileRegistration:AuthUIDelegate{
    
}
