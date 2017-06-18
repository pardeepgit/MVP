//
//  MVPLoginViewController.swift
//  MVPSports
//
//  Created by Chetu India on 09/08/16.
//

import UIKit
import PKHUD
import Flurry_iOS_SDK


class MVPLoginViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var buttonForgotPassword: UIButton!
  @IBOutlet weak var buttonCreateAccount: UIButton!
  @IBOutlet weak var buttonNotAMember: UIButton!
  
  @IBOutlet weak var textFieldUsername: UITextField!
  @IBOutlet weak var textFieldPassword: UITextField!
  @IBOutlet weak var buttonLogin: UIButton!
  @IBOutlet weak var buttonCross: UIButton!
  
  // MARK:  instance variables, constant decalaration and define with infer type with default values.
  var requestParamKeyArray = [String]() //["username", "LogInPwd"]
  var requestKeyValueDict = [String: String]()
  var isValidate = Bool()
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the state of method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  
  /*
   * preparedScreenDesign method is created to set all UI design element configuration with some property.
   */
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    // Code to set textfield border and round rect corner.
    textFieldUsername.layer.borderColor = LIGHTGRAYCOLOR.CGColor
    textFieldUsername.layer.borderWidth = VALUEONEBORDERWIDTH
    textFieldUsername.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    
    textFieldPassword.layer.borderColor = LIGHTGRAYCOLOR.CGColor
    textFieldPassword.layer.borderWidth = VALUEONEBORDERWIDTH
    textFieldPassword.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    
    // Code to set left padding to the textFieldUsername for the text enter value.
    let paddingView = UIView(frame: CGRectMake(0, 0, 10, textFieldUsername.frame.height))
    textFieldUsername.leftView = paddingView
    textFieldUsername.leftViewMode = UITextFieldViewMode.Always
    
    // Code to set left padding to the textFieldPassword for the text enter value.
    let paddingView2 = UIView(frame: CGRectMake(0, 0, 10, textFieldPassword.frame.height))
    textFieldPassword.leftView = paddingView2
    textFieldPassword.leftViewMode = UITextFieldViewMode.Always
    
    // Code to set round rect corner to the buttonLogin.
    buttonLogin.layer.cornerRadius = VALUEFIFTEENCORNERRADIUS
  }
  
  
  
  // MARK:  :--- All Selector Target Methods ---:
  // MARK:  navigateToAccountWebViewControllerForAccountUrl method.
  func navigateToAccountWebViewControllerForAccountUrl(accountUrl: String) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let viewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPACCOUNTLINKSVIEWCONTROLLER) as! MVPMyMVPAccountLinksViewController
    viewController.accountLinkUrlString = accountUrl
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  // MARK:  buttonCreateAccountTapped method.
  @IBAction func buttonCreateAccountTapped(sender: UIButton){
    let createAccountUrl = CreateAccountPageURL
    self.navigateToAccountWebViewControllerForAccountUrl(createAccountUrl)
  }
  
  // MARK:  buttonNotAMemberTapped method.
  @IBAction func buttonNotAMemberTapped(sender: UIButton){
    let notAMemberUrl = NotAMemberPageURL
    self.navigateToAccountWebViewControllerForAccountUrl(notAMemberUrl)
  }
  
  // MARK:  buttonForgotPasswordTapped method.
  @IBAction func buttonForgotPasswordTapped(sender: UIButton){
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpForgotPasswordViewController = storyBoard.instantiateViewControllerWithIdentifier(FORGOTPASSWORDVIEWCONTROLLER) as! MVPForgotPasswordViewController
    self.navigationController?.pushViewController(mvpForgotPasswordViewController, animated: true)
  }
  
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  
  
  
  // MARK:  loginButtonTapped method.
  @IBAction func loginButtonTapped(sender: UIButton){
    self.view.endEditing(true)
    
    let loginFormValidation = self.validateLoginFormForUserAuthentication()
    let validationFlag = loginFormValidation.0
    let title = loginFormValidation.1
    let message = loginFormValidation.2
    
    if validationFlag == true{ // Form is valid
      let requestBodyParam = self.prepareRequestBodyParameterOfLoginService()
      /*
       * Code to check device is connected to internet connection or not.
       */
      if Reachability.isConnectedToNetwork() == true {
        // Code to start loader.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(AUTHENTICATINGMSG, comment: "")))
        
        // Code to call executeSendCommentApiServiceWith method after certain one second delay.
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
          self.executeLoginApiServiceWith(requestBodyParam)
        })
      }
      else{
        self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
      }
    }
    else{ // Form is invalid
      self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
    }
  }
  
  
  
  /*
   * Method to call api method from LoginService class to execute MemberLogin Api endpoint service.
   */
  // MARK:  executeLoginApiServiceWith method.
  func executeLoginApiServiceWith(inputParam: [String: String]) {
    var apiFlag = false
    var title = ""
    var message = ""
    
    LoginService.authUserWith(inputParam as [String : String], completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        apiFlag = true
      }
      else if status == ApiResponseStatusEnum.Failure{
        apiFlag = false
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else if status == ApiResponseStatusEnum.NetworkError{
        apiFlag = false
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      else if status == ApiResponseStatusEnum.ClientTokenExpiry{
        
      }
      
      // Code to update loader hide UI in the Main thread and show a alert dialogue of invalid credentials.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide progress hud.
        HUD.hide(animated: true)
        
        if apiFlag == true{

          // Code to execute Save Device token api service.
          let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
          dispatch_async(queue){() -> Void in
            
            self.executeSaveDeviceTokenAsynchApiService()
          }

          
          // Code to save Default HpChart data of logged user for OptIn Status functionality.
          BarChartViewModel.setDeafultOptInHpChartData()
          
          // Code to add User_Login Event on Flurry dashboard.
          Flurry.logEvent("User_Login")
          
          // Code to update the user status flag boolean value to true. Bcoz status get changed from UnLogeed user to Logged user.
          UserViewModel.setUserStatusInApplication(true)
          
          // Code to set default api flag for local cache.
          UtilManager.sharedInstance.setDefaultApiFlagForLocalCacheFunctionality()
          
          // Code to delete from records from SiteClassByDate table for un logged user default Site Class.
          let deleteQueryString = "\(deleteFromSiteClassByDateQuery)\("\n")\(deleteFromSiteClassByInstructorQuery)\("\n")\(deleteFromSiteClassByClassesQuery)\("\n")\(deleteFromSiteClassByUserFavouriteQuery)"
          DBManager.sharedInstance.executeDeleteQueryBy(deleteQueryString)
          
          // Code to call executeSendCommentApiServiceWith method after certain half second delay.
          let triggerTime = (Int64(NSEC_PER_MSEC) * 1000)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            // Code navigae to the Root ViewController.
            NavigationViewManager.instance.navigateToRootViewControllerFrom(self)
          })
        }
        else{
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
    
    })
  }
  
  /*
   * Method to validate login form, for user authentication and retuen tupple with validation status flag and alert title and msg string.
   */
  // MARK:  validateLoginFormForUserAuthentication method.
  func validateLoginFormForUserAuthentication() -> (Bool, String, String) {
    var validationFlag = true
    var title = ""
    var message = ""
    
    if textFieldUsername.text!.characters.count == 0{
      validationFlag = false
      title = NSLocalizedString(ALERTTITLE, comment: "")
      message = NSLocalizedString(PLEASEENTERUSERNAMEALERTMSG, comment: "")
    }
    else if textFieldPassword.text!.characters.count == 0{
      validationFlag = false
      title = NSLocalizedString(ALERTTITLE, comment: "")
      message = NSLocalizedString(PLEASEENTERPASSWORDALERTMSG, comment: "")
    }
    
    return (validationFlag, title, message)
  }
  
  /*
   * Method to prepare request body parameter for api LoginService.
   */
  // MARK:  prepareRequestBodyParameterOfLoginService method.
  func prepareRequestBodyParameterOfLoginService () -> [String: String] {
    var inputParam = [String: String]()
    var username = textFieldUsername.text! as String
    var password = textFieldPassword.text! as String
    
    username = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    password = password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    
    textFieldUsername.text = username
    textFieldPassword.text = password
    
    inputParam["username"] = username
    inputParam["LogInPwd"] = password
    
    return inputParam
  }
  
  
  
  func executeSaveDeviceTokenAsynchApiService() {
    let tokenForSave = NotificationAnnouncementViewModel.getDeviceTokenForSaveFromUserDefault()
    if tokenForSave.characters.count > 0{
      if NotificationAnnouncementViewModel.validateDeviceTokenFromPreviousTokenValueBy(tokenForSave) == false{
        
        // Code to call a ASynchronous call by GCD global queue method.
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue){() -> Void in
          // Code to call class type method of NotificationAnnouncementViewModel class to save device token on to MVP server by Api services.
          NotificationAnnouncementViewModel.saveUniqueDeviceTokenToMvpServerFor(tokenForSave)
        }
      }
    }
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
 * Extension of MVPLoginViewController to add UITextField prototcol UITextFieldDelegate.
 * Override the protocol method of textfield delegate in LoginViewController to handle textfield action event and slector method.
 */
// MARK:  UITextField Delegates methods
extension MVPLoginViewController: UITextFieldDelegate{
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    if textField == textFieldUsername {
      textFieldPassword.becomeFirstResponder()
      return true
    }
    else if textField == textFieldPassword{
      textFieldPassword.resignFirstResponder()
      return true
    }
    else{
      return true
    }
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
    if textField == textFieldUsername {
      let currentCharacterCount = textField.text?.characters.count ?? 0
      if (range.length + range.location > currentCharacterCount){
        return false
      }
      
      let newLength = currentCharacterCount + string.characters.count - range.length
      return newLength <= 50
    }
    else{
      return true
    }
  }
  
}

