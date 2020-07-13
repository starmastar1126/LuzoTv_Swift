//
//  UpdateViewController.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 30/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import ADCountryPicker


class UpdateViewController: UIViewController,UITextFieldDelegate {
    var success:Int = 0
    
    var message:String = String()
    var gender:Int = 0
    var ageRange:Int = 0
    var country:String = String()
    @IBOutlet weak var updateBTn: UIButton!
    var spinner: SWActivityIndicatorView!
    var picker:ADCountryPicker = ADCountryPicker()
    var pickedDialCode:String = String()
    var numberValid:Bool = false
    var ProfileArray = NSMutableArray()
    
    @IBOutlet weak var regionImage: UIImageView!
    @IBOutlet var lblusername : UILabel?
    @IBOutlet var lblemail : UILabel?
    @IBOutlet var lblpassword : UILabel?
    @IBOutlet var lblphone : UILabel?
    
    @IBOutlet var lblagerange : UILabel?
    @IBOutlet var lblgender : UILabel?
    @IBOutlet var lblcountry : UILabel?
    @IBOutlet var lblregion : UILabel?
    
    
    
    @IBOutlet private weak var txtusername: UITextField!
    @IBOutlet private weak var txtemail: UITextField!
    @IBOutlet private weak var txtpassword: UITextField!
    @IBOutlet private weak var txtphone: FPNTextField!
    
    @IBOutlet private weak var txtagerange: UITextField!
    @IBOutlet private weak var txtgender: UITextField!
    @IBOutlet private weak var txtcountry: UITextField!
    @IBOutlet private weak var txtregion: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

         txtphone.setFlag(for: FPNCountryCode(rawValue: "NG")!)
         self.pickedDialCode = "+234"
         txtphone.textColor = .white
         txtphone.delegate = self
        txtgender.delegate = self
        txtagerange.delegate = self
        txtcountry.delegate = self
        txtregion.delegate = self
         self.txtgender.inputView = UIView()
         self.txtagerange.inputView = UIView()
         self.txtcountry.inputView = UIView()
         self.txtregion.inputView = UIView()
         
         picker.delegate = self
        
        self.getUserProfile()
    }
    @IBAction func OnUpdateClick(sender:UIButton)
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
           } else {
               self.txtusername?.resignFirstResponder()
               self.txtemail?.resignFirstResponder()
               self.txtpassword?.resignFirstResponder()
               self.txtgender?.resignFirstResponder()
               self.txtagerange?.resignFirstResponder()
               self.txtcountry?.resignFirstResponder()
              
               self.sendUpdate()
           }
       }
    
    func sendUpdate()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
            self.startSpinner()
            let userID : String = UserDefaults.standard.string(forKey: "USER_ID")!
            self.sendUpdateData(userID:userID,
                                name: txtusername.text!,
                                email: txtemail.text!,
                                gender: self.gender,
                                ageRange: self.ageRange,
                                country: country,
                                region: txtregion.text ?? "")
           
        } else {
            self.InternetConnectionNotAvailable1()
        }
        
    }
    func sendUpdateData(userID:String,name:String,email:String,gender:Int,ageRange:Int,country:String,region:String){
        
        let userID:String = UserDefaults.standard.string(forKey: "USER_ID")!
        let url:String = "http://luzotv.com/api/user_profile_update"
        
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print(request.httpMethod)
          let params:[String:Any] = ["uid":userID,"name":name,"email":email,"gender":gender,"age_Range":ageRange,"country":country,"region":region]
        print(params)
          do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response    , error) in
              if let response = response {
                let nsHTTPResponse = response as! HTTPURLResponse
                let statusCode = nsHTTPResponse.statusCode
                print ("status code = \(statusCode)")
              }
              if let error = error {
                print ("\(error)")
              }
              if let data = data {
                do{
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                  print ("data = \(jsonResponse)")
                    
                    if let status = jsonResponse["status"] as? Int {
                        self.success = status
                    }
                }catch _ {
                  print ("OOps not good JSON formatted response")
                }
              }
                DispatchQueue.main.async{
                    self.stopSpinner()
                    if self.success == 0 {
                        let alert = SCLAlertView()

                        _ = alert.showError("Status: \(self.success)",subTitle: "Unable to Update Profile. Contact Support")
                    } else {
                        let alert = SCLAlertView()
                        _ = alert.addButton("Take me Back", action: {
                            self.navigationController?.popViewController(animated: true)
                        })
                        _ = alert.showInfo("\(self.message)")
                    }
                }
            })
            task.resume()
          }catch _ {
            print ("Oops something happened buddy")
          }
    }
       
    func textFieldDidBeginEditing(_ textField: UITextField)
    {

        self.txtusername?.bs_hideError()
        self.txtemail?.bs_hideError()
        self.txtpassword?.bs_hideError()
        self.txtphone?.bs_hideError()
        
        if textField == txtgender {
            let alert = SCLAlertView()
            _ = alert.addButton("Male") {
                self.txtgender.text = "Male"
                self.gender = 0
            }
            _ = alert.addButton("Female") {
                self.txtgender.text = "Female"
                 self.gender = 1
            }
            _ = alert.showInfo("Select Gender")
        }
        
        if textField == txtagerange {
            let alert = SCLAlertView()
            _ = alert.addButton("Below 12") {
                self.txtagerange.text = "Below 12"
                self.ageRange = 0
            }
            _ = alert.addButton("13 - 17") {
                self.txtagerange.text = "13 - 17"
                self.ageRange = 1
            }
            _ = alert.addButton("18 - 24") {
                self.txtagerange.text = "18 - 24"
                self.ageRange = 2
            }
            _ = alert.addButton("25 - 34") {
                self.txtagerange.text = "25 - 34"
                self.ageRange = 3
            }
            _ = alert.addButton("35 - 44") {
                self.txtagerange.text = "35 - 44"
                self.ageRange = 4
            }
            _ = alert.addButton("45 - 64") {
                self.txtagerange.text = "45 - 64"
                self.ageRange = 5
            }
            _ = alert.addButton("45 - 65") {
                self.txtagerange.text = "45 - 65"
                self.ageRange = 6
            }
            _ = alert.addButton("Above 65") {
                self.txtagerange.text = "Above 65"
                self.ageRange = 7
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
        self.updateBTn?.layer.cornerRadius = (self.updateBTn?.frame.size.height)!/2
        self.updateBTn?.clipsToBounds = true
      
        self.updateBTn?.backgroundColor = UIColor(hexString: Colors.getButtonColor1())
     
       
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
    
    @IBAction func dismiss(_ sender: UIButton) {
           self.navigationController?.popViewController(animated: true)
       }

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
    //1.Latest Movies
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

}

extension UpdateViewController:ADCountryPickerDelegate{
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        picker.dismiss(animated: true, completion: nil)
        
        self.txtcountry.text = name
        self.country = code
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
extension UpdateViewController: FPNTextFieldDelegate {
    
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

