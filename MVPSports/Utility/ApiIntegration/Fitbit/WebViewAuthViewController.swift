//
//  WebViewAuthViewController.swift
//  SwiftFitbitIntegration
//
//  Created by Chetu India on 09/09/16.
//

import UIKit
import PKHUD


class WebViewAuthViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var webViewAuth: UIWebView!
  
  
  // MARK:  instance variables, constant decalaration and define with infer type with default values.
  var connectionAppId = 0

  let polar_client_id = "MVP Sports Clubs DEV"
  let polar_client_secret = "9vDDJrTNJcAa"
  
  let fitbit_client_id = "227R9X"
  let fitbit_client_secret = "98a7bde224641fb6134115e17bfeb786"
  let fitbit_scope = "activity heartrate location nutrition profile settings sleep social weight"
  let fitbit_redirect_uri = "https://team.mvpsportsclubs.com/"

  let hunderArmour_client_id = "fxkdbvx7djqakfuq2xe8r4x75awvtgjg"
  let hunderArmour_client_secret = "S2GZQ9XByRMRbaFMqg2cZhqd2GTY9sZn3MuQWb6M6VE"
  let hunderArmour_redirect_uri = "http://localhost:52623/"
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Code to clear cache of webview.
    NSURLCache.sharedURLCache().removeAllCachedResponses()
    if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
      for cookie in cookies {
        NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    var urlString = ""
    switch connectionAppId {
    case FITBITAPPID: // For Fitbit
      urlString = self.fitbitAuthUrl()
      break
      
    case UNDERARMOURAPPID: // For Hunder Armour
      urlString = self.hunderArmourAuthUrl()
      break
      
    case POLARAPPID: // for Polar
      urlString = self.polarAuthUrl()
      break
      
    default:
      urlString = ""
    }
    
    
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
    
    // Code to call fetchUserCheckInScheduleExerciseClasses method after certain one second delay.
    let triggerTime = (Int64(NSEC_PER_SEC) * 1)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
      self.loadUrlStringInWebView(urlString)
    })
  }
  

  
  // MARK:  loadUrlStringInWebView method.
  func loadUrlStringInWebView(urlString: String) {
    // Code to initiate the load url request.
    let url = NSURL (string: urlString)
    let requestObj = NSURLRequest(URL: url!);
    webViewAuth.loadRequest(requestObj)
  }
  
  
  
  
  // MARK:  executeSaveDeviceSettingApiWith method.
  func executeSaveDeviceSettingApiWith(inputParam: [String: String]) {
    var userConnectedAppCredentials = [String: AnyObject]()
    userConnectedAppCredentials["Credentials"] = inputParam
    userConnectedAppCredentials["ConnectedAppId"] = self.connectionAppId
    
    // Code to save the Connected App Credentials Key-Value pair value into user default.
    UserViewModel.setConnectedAppCredentialsInApplication(userConnectedAppCredentials)
    
    // Code to update the Connected App status flag boolean value to true.
    UserViewModel.setConnectedAppsStatusInApplication(true)
    
    dispatch_async(dispatch_get_main_queue()) {
      HUD.hide(animated: true)
      
      self.dismissViewControllerAnimated(true, completion: {});
    }
  }

  
  
  

  
  // *********************************** Polar Integration **************************************
  // MARK:  polarAuthUrl method.
  func polarAuthUrl() -> String {
    // client_id=[CLIENT_ID]
    let baseAuthorizeUrl = "https://flow.polar.com/oauth2/authorization?response_type=code&"
    let authUrl = "\(baseAuthorizeUrl)client_id=\(polar_client_id)"
    let encodedAuthUrl = authUrl.stringByReplacingOccurrencesOfString(" ", withString: "%20")

    return encodedAuthUrl
  }
  
  // MARK:  polarAccessTokenAuthUrlWithCode method.
  func polarAccessTokenAuthUrlWithCode(code: String) -> String {
    let tokenUrl = "https://polarremote.com/v2/oauth2/token"
    return tokenUrl
  }
  
  // MARK:  authenticatePolarUserWithResponseCode method.
  func authenticatePolarUserWithResponseCode(code: String) {
    let url: NSURL = NSURL(string: self.polarAccessTokenAuthUrlWithCode(code))!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Accept")
    request.setValue(NSString(format: "Basic %@", self.getBase64AuthorizationFromPolarCredentials()) as String, forHTTPHeaderField: "Authorization")
    
    let urlPostParam = "grant_type=authorization_code&code=\(code)"
    let postData: NSData = urlPostParam.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
    request.HTTPBody = postData
    
    var apiFlag = false
    var connectedAppResponse = [String: String]()
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      if data != nil{
//        let responseJsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)  as! String
//        print("Response json is :\n\(responseJsonString)")
        apiFlag = true
        connectedAppResponse = ConnectedAppsViewModel.parseConnectedAppsResponseData(data! as NSData, type: ConnectedAppsType.Polar)
      }
      else{
        apiFlag = false
      }
      
      if apiFlag == true{
        self.executeSaveDeviceSettingApiWith(connectedAppResponse)
      }
      else{
        dispatch_async(dispatch_get_main_queue()) {
          // Code to hide progress hud.
          HUD.hide(animated: true)
          self.dismissViewControllerAnimated(true, completion: {});
        }
      }
      
    })
    task.resume()
  }

  // MARK:  getBase64AuthorizationFromPolarCredentials method.
  func getBase64AuthorizationFromPolarCredentials() -> String{
    let baseEncodeAuth = "\(polar_client_id):\(polar_client_secret)"
    let loginData: NSData = baseEncodeAuth.dataUsingEncoding(NSUTF8StringEncoding)!
    let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
    return base64LoginString
  }
  
  // *******************************************************************************************
  
  
  
  
  // *********************************** FitBit Integration **************************************
  // MARK:  fitbitAuthUrl method.
  func fitbitAuthUrl() -> String {
    let baseAuthorizeUrl = "https://fitbit.com/oauth2/authorize?"
    let encodedScope = fitbit_scope.stringByReplacingOccurrencesOfString(" ", withString: "%20")
    let authUrl = "\(baseAuthorizeUrl)response_type=code&client_id=\(fitbit_client_id)&scope=\(encodedScope)&redirect_uri=\(fitbit_redirect_uri)"
    return authUrl
  }
  
  // MARK:  fitbitAccessTokenAuthUrlWithCode method.
  func fitbitAccessTokenAuthUrlWithCode(code: String) -> String {
    let baseAccessTokenUrl = "https://api.fitbit.com/oauth2/token?"
    let authUrl = "\(baseAccessTokenUrl)client_id=\(fitbit_client_id)&grant_type=authorization_code&redirect_uri=\(fitbit_redirect_uri)&code=\(code)"
    return authUrl
  }
  
  // MARK:  authenticateFitBitUserWithResponseCode method.
  func authenticateFitBitUserWithResponseCode(code: String) {
    let url: NSURL = NSURL(string: self.fitbitAccessTokenAuthUrlWithCode(code))!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue(NSString(format: "Basic %@", self.getBase64AuthorizationFromFitbitCredentials()) as String, forHTTPHeaderField: "Authorization")
    
    var apiFlag = false
    var connectedAppResponse = [String: String]()
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      if data != nil{
        apiFlag = true
        connectedAppResponse = ConnectedAppsViewModel.parseConnectedAppsResponseData(data! as NSData, type: ConnectedAppsType.FitBit)
      }
      else{
        apiFlag = false
      }
      
      if apiFlag == true{
        self.executeSaveDeviceSettingApiWith(connectedAppResponse)
      }
      else{
        dispatch_async(dispatch_get_main_queue()) {
          // Code to hide progress hud.
          HUD.hide(animated: true)
          self.dismissViewControllerAnimated(true, completion: {});
        }
      }
      
    })
    task.resume()
  }
  
  // MARK:  getBase64AuthorizationFromFitbitCredentials method.
  func getBase64AuthorizationFromFitbitCredentials() -> String{
    let baseEncodeAuth = "\(fitbit_client_id):\(fitbit_client_secret)"
    let loginData: NSData = baseEncodeAuth.dataUsingEncoding(NSUTF8StringEncoding)!
    let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
    return base64LoginString
  }
  
// *******************************************************************************************
  
  
  
  
  // *********************************** Hunder Armour Integration **************************************
  // MARK:  hunderArmourAuthUrl method.
  func hunderArmourAuthUrl() -> String {
    let baseAuthorizeUrl = "https://www.mapmyfitness.com/v7.1/oauth2/authorize/?"
    let authUrl = "\(baseAuthorizeUrl)client_id=\(hunderArmour_client_id)&response_type=code&redirect_uri=\(hunderArmour_redirect_uri)"
    return authUrl
  }
  
  // MARK:  fitbitAccessTokenAuthUrlWithCode method.
  func hunderArmourAccessTokenAuthUrlWithCode(code: String) -> String {
    let baseAccessTokenUrl = "https://api.ua.com/v7.1/oauth2/access_token?"
    let authUrl = "\(baseAccessTokenUrl)client_id=\(hunderArmour_client_id)&client_secret=\(hunderArmour_client_secret)&grant_type=authorization_code&code=\(code)"
    // print("\(authUrl)")
    return authUrl
  }
  
  // MARK:  authenticateHunderArmourUserWithResponseCode method.
  func authenticateHunderArmourUserWithResponseCode(code: String) {
    var bodyParam = [String: String]()
    bodyParam["grant_type"] = "authorization_code"
    bodyParam["client_id"] = hunderArmour_client_id
    bodyParam["client_secret"] = hunderArmour_client_secret
    bodyParam["code"] = code
    // print("\(bodyParam)")
    
    let keyArray = Array(bodyParam.keys)
    var postString = ""
    for index in 0 ..< keyArray.count{
      let key = keyArray[index] as String
      let value = bodyParam[key]! as String
      
      if index == keyArray.count-1{
        postString = "\(postString)\(key)=\(value)"
      }
      else{
        postString = "\(postString)\(key)=\(value)&"
      }
    }
    
    let postData: NSData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
    let postLength: String = "\(postData.length)"
    
    let url: NSURL = NSURL(string: self.hunderArmourAccessTokenAuthUrlWithCode(code))!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("fxkdbvx7djqakfuq2xe8r4x75awvtgjg", forHTTPHeaderField: "Api-Key")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue(postLength, forHTTPHeaderField: "Content-Length")
    request.HTTPBody = postData
    
    var apiFlag = false
    var connectedAppResponse = [String: String]()
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      if data != nil{
//        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)  as! String
//        print(responseString)

        apiFlag = true
        connectedAppResponse = ConnectedAppsViewModel.parseConnectedAppsResponseData(data! as NSData, type: ConnectedAppsType.UnderArmour)
      }
      else{
        apiFlag = false
      }
      
      if apiFlag == true{
        self.executeSaveDeviceSettingApiWith(connectedAppResponse)
      }
      else{
        dispatch_async(dispatch_get_main_queue()) {
          // Code to hide progress hud.
          HUD.hide(animated: true)
          self.dismissViewControllerAnimated(true, completion: {});
        }
      }

    })
    task.resume()
  }

  // *******************************************************************************************
  
  
  
  // MARK:  executeApiForCode method.
  func executeApiForCode(code: String) {
    dispatch_async(dispatch_get_main_queue()) {
      self.webViewAuth.hidden = true

      // Code to hide progress hud.
      HUD.show(.LabeledProgress(title: "", subtitle: "Authenticating..."))

      // Code to call method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        
        if self.connectionAppId == FITBITAPPID{ // for Fitbit
          self.authenticateFitBitUserWithResponseCode(code)
        }
        else if self.connectionAppId == UNDERARMOURAPPID{ // For Hunder Armour
          self.authenticateHunderArmourUserWithResponseCode(code)
        }
        else if self.connectionAppId == POLARAPPID{ // For Polar
          self.authenticatePolarUserWithResponseCode(code)
        }

      })
    }
  }
  
  
  
  
  
  
  // MARK:  cancelButtonTapped method.
  @IBAction func cancelButtonTapped(sender: UIButton){
    self.dismissViewControllerAnimated(true, completion: {});
  }

  // MARK:  showAlerrtDialogueWithTitle method.
  func showAlerrtDialogueWithTitle(title: String, AndErrorMsg errorMessage:String) {
    // create the alert
    let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    // add an action (button)
    alert.addAction(UIAlertAction(title: NSLocalizedString(OKACTION, comment: ""), style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK:  showAlerrtDialogueWithSuccessMessage method.
  func showAlerrtDialogueWithSuccessMessage(message: String) {
    // create the alert
    let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    // add an action (button)
    alert.addAction(UIAlertAction(title: NSLocalizedString(OKACTION, comment: ""), style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK:  Memory management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}



/*
 * Extension of WebViewAuthViewController to add UIWebView prototcol UIWebViewDelegate.
 * Override the protocol method to add tableview in WebViewAuthViewController.
 */
// MARK:  Extension of WebViewAuthViewController by UIWebViewDelegate Delegates method.
extension WebViewAuthViewController: UIWebViewDelegate{
  
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
    let urlAbsoluteString = (request.URL?.absoluteString)! as String
    
    if urlAbsoluteString.rangeOfString("code=") != nil{
      let codeRange = urlAbsoluteString.rangeOfString("code=",
                                                      options: NSStringCompareOptions.LiteralSearch,
                                                      range: urlAbsoluteString.startIndex..<urlAbsoluteString.endIndex,
                                                      locale: nil)
      
      let code = urlAbsoluteString [codeRange!.endIndex..<urlAbsoluteString.endIndex]
      self.executeApiForCode(code)
    }
    
    return true
  }
  
  func webViewDidStartLoad(webView: UIWebView){
  }
  
  func webViewDidFinishLoad(webView: UIWebView){
    dispatch_async(dispatch_get_main_queue()) {
      // Code to hide progress hud.
      HUD.hide(animated: true)
    }
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
    dispatch_async(dispatch_get_main_queue()) {
      // Code to hide progress hud.
      HUD.hide(animated: true)
    }
  }
  
}
