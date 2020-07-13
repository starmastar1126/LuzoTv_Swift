//
//  GetRewards.swift
//  LiveTV
//
//  Created by Aqib  Farooq on 18/09/2019.
//  Copyright © 2019 Viavi Webtech. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SnapKit
import Alamofire

class GetRewards: UIViewController,LCBannerViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate {
    
    var ProfileArray = NSMutableArray()
    
    let packageTable:UITableView = UITableView()
    
    let packageAlert:UIAlertController = UIAlertController(title: "Packages", message: "Select Your Package", preferredStyle: .alert)
   
    var spinner: SWActivityIndicatorView!
    
    var BASE_URL_PAYALAT = "https://payalat.com/api/v1/"
    
    var PACKAGE_PATH = "package"
    var BILL_PATH = "bill"
    
    var bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    
    var interstitial: GADInterstitial!
    
    var packages:[[String:Any]] = [[String:Any]]()
    
    var user_wallet:[String:Any] = [String:Any]()
    
    var status:String = "0"
    
    var message:String = String()
    
    var serviceID:Int = Int()
    
    var operatorSelected:Bool = false
    
    @IBOutlet weak var selectOperatorTxt: UITextField!
    
    @IBOutlet weak var claimRewardBtn: UIButton!
    
    @IBOutlet weak var earnMorePoints: UIButton!
    
    @IBOutlet weak var TotalClaimedPoints: UITextField!
    @IBOutlet weak var totalAvaiablePoints: UILabel!
    
    var isUserProfileCompleted:Bool = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        packageTable.delegate = self
        packageTable.dataSource = self
        
        packageTable.register(UINib(nibName: "PackageCell", bundle: nil), forCellReuseIdentifier: "packageCell")

        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: packageAlert.view.frame.width, height: packageAlert.view.frame.height)
        vc.view.addSubview(packageTable)
        
        packageTable.snp.makeConstraints { (ConstraintMaker) in
            ConstraintMaker.edges.equalToSuperview()
        }
        
        packageAlert.setValue(vc, forKey: "contentViewController")
        
        packageAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
            
        }))
        
        selectOperatorTxt.inputView = nil
        
        claimRewardBtn.applyGradient(colours: [UIColor.init(251, green: 17, blue: 79),UIColor.init(251, green: 67, blue: 46)])
        
        earnMorePoints.applyGradient(colours: [UIColor.init(251, green: 17, blue: 79),UIColor.init(251, green: 67, blue: 46)])
        
        claimRewardBtn.layer.cornerRadius = 15.0
        earnMorePoints.layer.cornerRadius = 15.0
        setAdmob()
        self.getUserProfile()
        
    
        
    }
    @IBAction func claimRewards(_ sender: Any) {
        if self.isUserProfileCompleted == true {
            if self.operatorSelected == true {

               if let points = self.user_wallet["current_balance"] as? Int {
                   if points > 100 {
                       print("Points are: \(points)")
                       if self.status == "200" {
                           if self.packages.count > 0 {
                               self.packageTable.reloadData()
                               self.present(self.packageAlert, animated: true, completion: nil)
                           }
                                              
                       } else {
                           let alert = SCLAlertView()
                            
                           _ = alert.showError("Status: \(self.status)",subTitle: "Unable to Get Packages. Contact Support or Please Try Later")
                       }
                   }
               } else {
                   let alert = SCLAlertView()
                   _ = alert.addButton("Okay") {
                       self.getUserWallet()
                       }
                   _ = alert.showError("Not Enough Reward Points", subTitle: "You need to earn more reward points before you can claim rewards.")
               }
                
            } else {
                let alert = SCLAlertView()
                _ = alert.showError("Please Select Your Mobile Operator")
            }
            
        } else {
            self.isUserProfileCompleted = false
            let alert = SCLAlertView()
            _ = alert.addButton("Complete Profile") {
            self.CallUpdateProfileViewController()
            }
            _ = alert.showError("Profile Not Completed", subTitle: "You need to complete your profile before you can start claiming reward points.")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.isUserProfileComplete()
    }
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isUserProfileComplete(){
        if (Reachability.shared.isConnectedToNetwork()) {
            self.getUserProfileData()
        } else {
            self.InternetConnectionNotAvailable1()
        }
        
    }
    func getUserProfileData(){
        self.startSpinner()
             let userID:String = UserDefaults.standard.string(forKey: "USER_ID")!
            
             

               let url = URL(string: "http://luzotv.com/api/get_profile_completed?uid=\(userID)")!

               var request = URLRequest(url: url)
               request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
               request.httpMethod = "POST"
               
               
              
               
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
                 
                   let jsonData = responseString!.data(using: .utf8)!
                   do {
                       if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as? [String:Any]
                       {
                         if let statuss = jsonArray["status"] as? Int {
                            self.status = "\(statuss)"
                         }
                          
                       } else {
                           print("bad json")
                       }
                   } catch let error as NSError {
                       print(error)
                   }
                   
                   DispatchQueue.main.async{
                    self.stopSpinner()
                    if self.status == "0" {
                        let alert = SCLAlertView()
                        _ = alert.addButton("Complete Profile") {
                            self.CallUpdateProfileViewController()
                        }
                        _ = alert.showError("Profile Not Completed", subTitle: "You need to complete your profile before you can start claiming reward points.")
                        
                        
                    }else {
                        self.isUserProfileCompleted = true
                        self.getUserWallet()
                    }
                   }
               }
        
               task.resume()
    }

    func getPackages(serviceIDs:Int){
         
        
             
        self.packages.removeAll()
              
        self.startSpinner()

         let baseString:String = BASE_URL_PAYALAT+PACKAGE_PATH
        
         let userID:String = UserDefaults.standard.string(forKey: "USER_ID")!
         
         
         let session = URLSession.shared
         var request = URLRequest(url: URL(string: baseString)!)
         
         request.httpMethod = "POST"
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue("psk_a9541b9b487249938f3a0636eacd1c3e", forHTTPHeaderField: "Authorization")
         
         print(request.httpMethod)
        let params:[String:Any] = ["serviceID":serviceIDs]
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
                    //print ("data = \(jsonResponse)")
                    if let status = jsonResponse["status"] as? String {
                        if status == "200" {
                            self.status = "\(status)"
                            print("Status is: \(self.status)")
                            if let billServicePackages = jsonResponse["billServicePackages"] as? [[String:Any]] {
                                if billServicePackages.count > 0 {
                                    for index in 0...billServicePackages.count-1 {
                                        var temp:[String:Any] = [String:Any]()
                                        if let name = billServicePackages[index]["name"] as? String {
                                            temp.updateValue(name, forKey: "name")
                                        }
                                        if let code = billServicePackages[index]["code"] as? String {
                                            temp.updateValue(code, forKey: "code")
                                        }
                                        if let amount = billServicePackages[index]["amount"] as? String {
                                            temp.updateValue(amount, forKey: "amount")
                                        }
                                        if let value = billServicePackages[index]["value"] as? String {
                                            temp.updateValue(value, forKey: "value")
                                        }
                                        if let valid = billServicePackages[index]["valid"] as? String {
                                            temp.updateValue(valid, forKey: "valid")
                                        }
                                        self.packages.append(temp)
                                    }
                                }
                            }
                        } else {
                             self.status = "\(status)"
                            if let message = jsonResponse["message"] as? String {
                                self.message = message
                            }
                        }
                        
                    }
                 }catch _ {
                   print ("OOps not good JSON formatted response")
                 }
               }
                 DispatchQueue.main.async{
                    print(self.packages)
                     self.stopSpinner()
                   
                 }
             })
             task.resume()
           }catch _ {
             print ("Oops something happened buddy")
           }
     }
    
    
    @IBAction func selectOperator(_ sender: Any) {
        let alertView = SCLAlertView()
        
        alertView.appearance.buttonCornerRadius = 10.0
        alertView.addButton("MTN"){
            self.operatorSelected = true
            self.selectOperatorTxt.text = "MTN"
            self.serviceID = 6
            self.getPackages(serviceIDs: 6)
            
            
        }
        alertView.addButton("AIRTEL") {
            self.operatorSelected = true
            self.selectOperatorTxt.text = "AIRTEL"
            self.serviceID = 12
            self.getPackages(serviceIDs: 12)
        }
        alertView.addButton("9MOBILE") {
            self.operatorSelected = true
            self.selectOperatorTxt.text = "9MOBILE"
            self.serviceID = 15
            self.getPackages(serviceIDs: 15)
        }
        alertView.addButton("GLO") {
            self.operatorSelected = true
            self.selectOperatorTxt.text = "GLO"
            self.serviceID = 9
            self.getPackages(serviceIDs: 9)
        }
        alertView.showSuccess("Select Operator", subTitle: "")
    }
    
    func getUserWallet() {
        self.startSpinner()
        let userID:String = UserDefaults.standard.string(forKey: "USER_ID")!
       
        
          
          let url = URL(string: "http://luzotv.com/api/wallet/get/\(userID)")!

          var request = URLRequest(url: url)
          request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
          request.httpMethod = "POST"
          
          
         
          
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
            
              let jsonData = responseString!.data(using: .utf8)!
              do {
                  if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as? [String:Any]
                  {
                    if let status = jsonArray["status"] as? Int {
                        if status == 1 {
                            if let data = jsonArray["data"] as? [String:Any] {
                                
                                self.user_wallet.removeAll()
                                
                                if let phone_code = data["phone_code"] as? String {
                                    self.user_wallet.updateValue(phone_code, forKey: "phone_code")
                                }
                                if let phone = data["phone"] as? String {
                                    self.user_wallet.updateValue(phone, forKey: "phone")
                                }
                                if let total_balance = data["total_balance"] as? Int {
                                    self.user_wallet.updateValue(total_balance, forKey: "total_balance")
                                }
                                if let current_balance = data["current_balance"] as? Int {
                                    self.user_wallet.updateValue(current_balance, forKey: "current_balance")
                                }
                                if let claimed_balance = data["claimed_balance"] as? Int {
                                    self.user_wallet.updateValue(claimed_balance, forKey: "claimed_balance")
                                }
                                
                            }
                        } else {
                            
                        }
                    }
                     
                  } else {
                      print("bad json")
                  }
              } catch let error as NSError {
                  print(error)
              }
              
              DispatchQueue.main.async{
                self.stopSpinner()
                print(self.user_wallet)
                if let current_balance = self.user_wallet["current_balance"] as? Int {
                    self.totalAvaiablePoints.text = "Total Points: \(current_balance)"
                }
                if let total_claimed = self.user_wallet["claimed_balance"] as? Int {
                    self.TotalClaimedPoints.text = "Total Claimed: \(total_claimed)"
                }
                
                
              }
          }
          
          task.resume()
    }
    
    func setAdmob()
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-50, width:CommonUtils.screenWidth-20, height:50))
        } else if (CommonUtils.screenHeight >= 812) {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-65, width:CommonUtils.screenWidth-20, height:50))
        } else {
            bannerView = GADBannerView(frame: CGRect(x:10, y:CommonUtils.screenHeight-50, width:CommonUtils.screenWidth-20, height:50))
        }
        
        addBannerView(to: bannerView)
        let banner_ad_id_ios = UserDefaults.standard.value(forKey: "banner_ad_id_ios") as? String
        bannerView.adUnitID = banner_ad_id_ios
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    func adViewDidReceiveAd(_ adView: GADBannerView)
    {
        // We've received an ad so lets show the banner
        print("adViewDidReceiveAd")
    }
    func adView(_ adView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        // Failed to receive an ad from AdMob so lets hide the banner
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription )")
    }
    func addBannerView(to bannerView: UIView?)
    {
        if let aView = bannerView {
            view.addSubview(aView)
        }
        if let aView = bannerView {
            view.addConstraints([NSLayoutConstraint(item: aView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0), NSLayoutConstraint(item: aView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
        }
    }
    
    //================Admob Interstitial Ads===============//
    func CallAdmobInterstitial()
    {
        //1.Interstitial Ad Click
        let ad_click: Int = UserDefaults.standard.integer(forKey: "ADClick")
        UserDefaults.standard.set(ad_click + 1, forKey: "ADClick")
        //2.Load Interstitial
        let isInterstitialAd = UserDefaults.standard.value(forKey: "interstital_ad_ios") as? String
        if (isInterstitialAd == "true") {
            let interstital_ad_click_ios = UserDefaults.standard.value(forKey: "interstital_ad_click_ios") as? String
            let adminCount = Int(interstital_ad_click_ios!)
            let ad_click1: Int = UserDefaults.standard.integer(forKey: "ADClick")
            print("ad_click1 : \(ad_click1)")
            if (ad_click1 % adminCount! == 0) {
                let isGDPR_STATUS: Bool = UserDefaults.standard.bool(forKey: "GDPR_STATUS")
                if (isGDPR_STATUS) {
                    let request = DFPRequest()
                    let extras = GADExtras()
                    extras.additionalParameters = ["npa": "1"]
                    request.register(extras)
                    self.createAndLoadInterstitial()
                } else {
                    self.createAndLoadInterstitial()
                }
            }
        }
    }
    func createAndLoadInterstitial()
    {
        let interstitialAdId = UserDefaults.standard.value(forKey: "interstital_ad_id_ios") as? String
        interstitial = GADInterstitial(adUnitID: interstitialAdId!)
        let request = GADRequest()
        interstitial.delegate = self
        //request.testDevices = @[ kGADSimulatorID ];
        interstitial.load(request)
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial)
    {
        if (interstitial.isReady) {
            interstitial.present(fromRootViewController: self)
        }
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial)
    {
        print("interstitialWillDismissScreen")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("didFailToReceiveAdWithError")
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
              
              self.getUserWallet()
          }
          _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.InternetConnectionNotAvailable())
      }
      func Networkfailure1()
      {
          let alert = SCLAlertView()
          _ = alert.addButton(CommonMessage.RETRY()) {
              self.getUserWallet()
          }
          _ = alert.showError(CommonMessage.NetworkError(), subTitle: CommonMessage.CouldNotConnectToServer())
      }
}
extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}
extension GetRewards:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "packageCell", for: indexPath) as! PackageCell

        cell.nameLabel.text = self.packages[indexPath.row]["name"] as? String
        cell.amountLabel.text = "Amount: \(self.packages[indexPath.row]["amount"]!)"
        cell.valueLabel.text = "Value: \(self.packages[indexPath.row]["value"]!)"
        cell.validityLabel.text = "Validity: \(self.packages[indexPath.row]["valid"]!)"
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            let packageInfoAlert = SCLAlertView()
        
            _ = packageInfoAlert.addButton("Yes") {
                
                if let packageAmount = self.packages[indexPath.row]["amount"] as? String {
                    
                     let amount = Double(packageAmount)!
                     let userValue:Double = Double(self.user_wallet["current_balance"] as! Int)
                    print("User points: \(userValue)")
                    print("Package Amount: \(amount)")
                        if userValue > amount {
                            
                            
                            
                        packageInfoAlert.dismiss(animated: true) {
                        }
                        self.packageAlert.dismiss(animated: true) {
                        }
                            switch self.serviceID {
                                
                            case 6:
                                print("Invalid Service")
                                //MTN
                                self.rechargeToMobileNumber(parameters: ["serviceID":self.serviceID,
                                                                         "customerName":(self.ProfileArray.object(at: 0) as! [String:Any])["name"] as! String,
                                                                         "email":(self.ProfileArray.object(at: 0) as! [String:Any])["email"] as! String,
                                                                         "MobileNumber":(self.ProfileArray.object(at: 0) as! [String:Any])["phone"] as! String,
                                                                         "amount":amount])
                                
                            case 12:
                                print("Invalid Service")
                                //AIRTEL
                                self.rechargeToMobileNumber(parameters: ["serviceID":self.serviceID,
                                                                          "customerName":(self.ProfileArray.object(at: 0) as! [String:Any])["name"] as! String,
                                                                          "email":(self.ProfileArray.object(at: 0) as! [String:Any])["email"] as! String,
                                                                          "MobileNumber":(self.ProfileArray.object(at: 0) as! [String:Any])["phone"] as! String,
                                                                          "amount":amount])
                            case 15:
                                print("Invalid Service")
                                //9Mobile
                                self.rechargeToMobileNumber(parameters: ["serviceID":self.serviceID,
                                                                          "customerName":(self.ProfileArray.object(at: 0) as! [String:Any])["name"] as! String,
                                                                          "email":(self.ProfileArray.object(at: 0) as! [String:Any])["email"] as! String,
                                                                          "MobileNumber":(self.ProfileArray.object(at: 0) as! [String:Any])["phone"] as! String,
                                                                          "amount":amount])
                            case 9:
                                print("Invalid Service")
                                //GLO
                                self.rechargeToMobileNumber(parameters: ["serviceID":self.serviceID,
                                                                          "customerName":(self.ProfileArray.object(at: 0) as! [String:Any])["name"] as! String,
                                                                          "email":(self.ProfileArray.object(at: 0) as! [String:Any])["email"] as! String,
                                                                          "MobileNumber":(self.ProfileArray.object(at: 0) as! [String:Any])["phone"] as! String,
                                                                          "package":self.packages[indexPath.row]["code"] as! String,
                                                                          "amount":amount])
                            default:
                                print("Invalid Service")
                                
                            }
    
                    }else {
                        packageInfoAlert.dismiss(animated: true, completion: nil)
                        let alert = SCLAlertView()
                        _ = alert.showInfo("Sorry You dont have enough Points, Please Select Another Package or Earn More Reward Points")
                    }
                        
                    
                }

        }
        _ = packageInfoAlert.showError("Are you Sure?", subTitle: "Package: \(self.packages[indexPath.row]["name"] as! String)"+"\n"+"Value: \(self.packages[indexPath.row]["value"] as! String)"+"\n"+"Valid: \(self.packages[indexPath.row]["valid"] as! String)"+"\n"+"Amount: \(self.packages[indexPath.row]["amount"] as! String)")
        
    }
    
    
    func CallUpdateProfileViewController()
    {
        let view : UIViewController
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            view = UpdateViewController(nibName: "UpdateViewController_iPad", bundle: nil)
        } else if (CommonUtils.screenHeight >= 812) {
            view = UpdateViewController(nibName: "UpdateViewController_iPhoneX", bundle: nil)
        } else {
            view = UpdateViewController(nibName: "UpdateViewController", bundle: nil)
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
   
}

extension GetRewards{
    func rechargeToMobileNumber(parameters:[String:Any]){

               self.startSpinner()
                var temp:[String:String] = [String:String]()
                let baseString:String = BASE_URL_PAYALAT+BILL_PATH
               
                let userID:String = UserDefaults.standard.string(forKey: "USER_ID")!
                
                let session = URLSession.shared
        
                var request = URLRequest(url: URL(string: baseString)!)
                
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("psk_a9541b9b487249938f3a0636eacd1c3e", forHTTPHeaderField: "Authorization")
                
                print(request.httpMethod)
        
                print(parameters)
                  do{
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
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
                           //print ("data = \(jsonResponse)")
                           if let status = jsonResponse["status"] as? String {
                            
                               if status == "200" {
                                   self.status = "\(status)"
                                   print("Status is: \(self.status)")
                               
                                print(jsonResponse)
                                
                                if let brand_name = jsonResponse["brand_name"] as? String {
                                    temp.updateValue(brand_name, forKey: "brand_name")
                                }
                                if let utility_name = jsonResponse["utility_name"] as? String {
                                    temp.updateValue(utility_name, forKey: "utility_name")
                                }
                                if let currency = jsonResponse["currency"] as? String {
                                    temp.updateValue(currency, forKey: "currency")
                                }
                                if let amount = jsonResponse["amount"] as? String {
                                    temp.updateValue(amount, forKey: "amount")
                                }
                                if let customerName = jsonResponse["customerName"] as? String {
                                    temp.updateValue(customerName, forKey: "customerName")
                                }
                                if let MobileNumber = jsonResponse["MobileNumber"] as? String {
                                    temp.updateValue(MobileNumber, forKey: "MobileNumber")
                                }
                                if let email = jsonResponse["email"] as? String {
                                    temp.updateValue(email, forKey: "email")
                                }
                                if let txn_ref = jsonResponse["txn_ref"] as? String {
                                    temp.updateValue(txn_ref, forKey: "txn_ref")
                                }
                                if let date = jsonResponse["date"] as? String {
                                    temp.updateValue(date, forKey: "date")
                                }
                                if let message = jsonResponse["message"] as? String {
                                    temp.updateValue(message, forKey: "message")
                                    self.message = message
                                }
                                temp.updateValue(userID, forKey: "uid")
                                
                                
                               } else {
                                    self.status = "\(status)"
                                    if let message = jsonResponse["message"] as? String {
                                       self.message = message
                                   }
                               }
                               
                           }
                        }catch _ {
                          print ("OOps not good JSON formatted response")
                        }
                      }
                        DispatchQueue.main.async{
                            self.stopSpinner()
                            
                            if self.status == "200" {
                                let alert = SCLAlertView()
                                _ = alert.showInfo("\(self.message)")
                                self.sendLog(data: temp)
                                
                            } else {
                                let alert = SCLAlertView()
                                _ = alert.showInfo("\(self.message)")
                            }
                           
                        }
                    })
                    task.resume()
                  }catch _ {
                    print ("Oops something happened buddy")
                  }
        
    }
    
    
    
    
    
    func sendLog(data:[String:String]){
        
                self.startSpinner()
               
                let baseString:String = "http://luzotv.com/api/paylat_log"
               
                let session = URLSession.shared
        
                var request = URLRequest(url: URL(string: baseString)!)
                
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            var parameters:[String:String] = ["uid":            data["uid"] as! String,
                                              "reward_points":  data["amount"] as! String,
                                              "utility_name":   data["utility_name"] as! String,
                                              "currency":       data["currency"] as! String,
                                              "amount":         data["amount"] as! String,
                                              "customerName":   data["customerName"] as! String,
                                              "MobileNumber":   data["MobileNumber"] as! String,
                                              "email":          data["email"] as! String,
                                              "txn_ref":        data["txn_ref"] as! String,
                                              "date":           data["date"] as! String]
                print(request.httpMethod)
        
                  do{
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
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
                           if let status = jsonResponse["status"] as? String {
                            
                               if status == "0" {
                                   self.status = "\(status)"
                                   print("Status is: \(self.status)")
                               
                                print(jsonResponse)

                                
                                
                               } else {
                                    self.status = "\(status)"
                                    if let message = jsonResponse["message"] as? String {
                                       self.message = message
                                   }
                               }
                               
                           }
                        }catch _ {
                          print ("OOps not good JSON formatted response")
                        }
                      }
                        DispatchQueue.main.async{
                            self.stopSpinner()
                          
                        }
                    })
                    task.resume()
                  }catch _ {
                    print ("Oops something happened buddy")
                  }
    }
    
}

extension GetRewards {
    
    
    
    func getUserProfile()
    {
        if (Reachability.shared.isConnectedToNetwork()) {
           
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
                
               
            }
        }, failure: { operation, error in
            self.Networkfailure1()
            self.stopSpinner()
        })
    }
}
