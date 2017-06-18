//
//  MVPForgotPasswordViewController.swift
//  MVPSports
//
//  Created by Chetu India on 17/11/16.
//

import UIKit
import PKHUD
import Crashlytics


class MVPForgotPasswordViewController: UIViewController {

  // MARK:  Widget elements declarations.
  @IBOutlet weak var textFieldEmail: UITextField!
  @IBOutlet weak var buttonSendPassword: UIButton!

  @IBOutlet weak var tableViewLinkedMember: UITableView!
  @IBOutlet weak var viewLinkedMemberView: UIView!
  @IBOutlet weak var viewLinkedInnerMemberView: UIView!
  
  // MARK:  instance variables, constant decalaration and define with infer type with default values.
  var linkedMemberArray = [[String: AnyObject]]()
  var chooseMemberIndex = -1

  
  
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
    // Code to show or hide LinkedMember list view.
    self.hideAndShowLinkedMemberView(false)
    
    // Code to set textfield border and round rect corner.
    textFieldEmail.layer.borderColor = LIGHTGRAYCOLOR.CGColor
    textFieldEmail.layer.borderWidth = VALUEONEBORDERWIDTH
    textFieldEmail.layer.cornerRadius = VALUEEIGHTCORNERRADIUS

    viewLinkedInnerMemberView.layer.borderColor = LIGHTGRAYCOLOR.CGColor
    viewLinkedInnerMemberView.layer.borderWidth = VALUEONEBORDERWIDTH
    viewLinkedInnerMemberView.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    
    // Code to set left padding to the textFieldEmail for the text enter value.
    let paddingView = UIView(frame: CGRectMake(0, 0, 10, textFieldEmail.frame.height))
    textFieldEmail.leftView = paddingView
    textFieldEmail.leftViewMode = UITextFieldViewMode.Always
    
    // Code to set round rect corner to the buttonLogin.
    buttonSendPassword.layer.cornerRadius = VALUEFIFTEENCORNERRADIUS
  }

  
  
  
  
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  cancelOrSendButtonTapped method.
  @IBAction func cancelOrSendButtonTapped(sender: UIButton){
    let tagIndex = sender.tag
    if tagIndex == 101{ // Cancel tapped
      chooseMemberIndex = -1
      
      // Code to hide linked member view.
      self.hideAndShowLinkedMemberView(false)
    }
    else if tagIndex == 102{ // Send tapped
      if chooseMemberIndex != -1{
        // Code to show flash loader with text message Authenticating to indicate there is user authentication is in progress.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(SENDINGPASSWORDMSG, comment: "")))
        
        // Code to call a method to execute FindMemberById ApiService.
        self.executeFindMemberByIdApiService()
      }
    }
    else{ // Others
    }
  }
  
  // MARK:  sendPasswordButtonTapped method.
  @IBAction func sendPasswordButtonTapped(sender: UIButton){
    self.view.endEditing(true)
    
    let sendPasswordFormValidation = self.validateSendPasswordFormForResetPassword()
    let validationFlag = sendPasswordFormValidation.0
    let title = sendPasswordFormValidation.1
    let message = sendPasswordFormValidation.2
    
    if validationFlag == true{ // Form is valid
      let requestBodyParam = self.prepareRequestBodyParameterOfSendPasswordService()
      /*
       * Code to check device is connected to internet connection or not.
       */
      if Reachability.isConnectedToNetwork() == true {
        // Code to start loader.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(SENDINGPASSWORDMSG, comment: "")))
        
        // Code to call executeSendCommentApiServiceWith method after certain one second delay.
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
          self.executeSendPasswordApiServiceWith(requestBodyParam)
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
   * Method to call api method from LoginService class to execute executeSendPasswordApiServiceWith Api endpoint service.
   */
  // MARK:  executeSendPasswordApiServiceWith method.
  func executeSendPasswordApiServiceWith(inputParam: [String: String]) {
    LoginService.sendPasswordServiceBy(inputParam as [String : String], completion: { (status, responseData) -> () in
      var apiFlag = false
      var alertFlag = false
      var title = ""
      var message = ""
      
      if status == ApiResponseStatusEnum.Success{
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = NSLocalizedString(NEWPASSWORDMAILISSENTALERTMSG, comment: "")
      }
      else if status == ApiResponseStatusEnum.Failure{
        alertFlag = true
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else{
        alertFlag = true
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to update loader hide UI in the Main thread and show a alert dialogue of invalid credentials.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to handle api eucssefull execution response.
        if apiFlag{
          let arrayOfLinkedMember = UserViewModel.parseSendPasswordLinkedMemberJsonResponseData(responseData as! NSData) as [[String: AnyObject]]
          
          if arrayOfLinkedMember.count > 0{
            if arrayOfLinkedMember.count == 1{
              self.chooseMemberIndex = 0
              self.linkedMemberArray = arrayOfLinkedMember
              
              // Code to call a method to execute FindMemberById ApiService.
              self.executeFindMemberByIdApiService()
            }
            else{
              // Code to hide progress hud.
              HUD.hide(animated: true)
              
              self.linkedMemberArray = arrayOfLinkedMember
              self.tableViewLinkedMember.reloadData()
              
              // Code to show linked member view.
              self.hideAndShowLinkedMemberView(true)
            }
          }
          else{
            alertFlag = true
            title = NSLocalizedString(ALERTTITLE, comment: "")
            message = NSLocalizedString(VALIDREGISTEREDEMAILREQUIREDALERTMSG, comment: "")
          }
        }
        
        if alertFlag{
          // Code to hide progress hud.
          HUD.hide(animated: true)
          
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
  }
  
  // MARK:  executeFindMemberByIdApiService method.
  func executeFindMemberByIdApiService() {
    let linkedMember = linkedMemberArray[chooseMemberIndex]
    let memberId = linkedMember["MemberId"] as! Int

    // Code to initiate input param dictionary to execute FindMemberById api endpoint service.
    var inputField = [String: String]()
    inputField["MemberId"] = "\(memberId)"
    
    var apiFlag = false
    var title = ""
    var message = ""
    LoginService.FindMemberByIdServiceBy(inputField as [String : String], completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = NSLocalizedString(NEWPASSWORDMAILISSENTALERTMSG, comment: "")
      }
      else if status == ApiResponseStatusEnum.Failure{
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else{
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to update loader hide UI in the Main thread and show a alert dialogue of invalid credentials.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide progress hud.
        HUD.hide(animated: true)
        
        if apiFlag{
          let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          // On 'OK' click.
          alert.addAction(UIAlertAction(title: NSLocalizedString(OKACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in

            // Code to pop to Login View Controller
            self.backButtonTapped(UIButton())
          }))
          self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
  }

  
  
  
  /*
   * Method to validate send password form, for send reset password link and retuen tupple with validation status flag and alert title and msg string.
   */
  // MARK:  validateSendPasswordFormForResetPassword method.
  func validateSendPasswordFormForResetPassword() -> (Bool, String, String) {
    var validationFlag = true
    var title = ""
    var message = ""
    
    if textFieldEmail.text!.characters.count == 0{
      validationFlag = false
      title = NSLocalizedString(ALERTTITLE, comment: "")
      message = NSLocalizedString(VALIDREGISTEREDEMAILREQUIREDALERTMSG, comment: "")
    }
    else if !UtilManager.sharedInstance.isValidEmail(textFieldEmail.text!){
      validationFlag = false
      title = NSLocalizedString(ALERTTITLE, comment: "")
      message = NSLocalizedString(PLEASEENTERAVALIDEMAILALERTMSG, comment: "")
    }
    
    return (validationFlag, title, message)
  }
  
  /*
   * Method to prepare request body parameter for api SendPassword.
   */
  // MARK:  prepareRequestBodyParameterOfSendPasswordService method.
  func prepareRequestBodyParameterOfSendPasswordService () -> [String: String] {
    var inputParam = [String: String]()
    let email = textFieldEmail.text! as String
    inputParam["EmailAddress"] = email
    
    return inputParam
  }
  
  
  // MARK:  hideAndShowLinkedMemberView method.
  func hideAndShowLinkedMemberView(showFlag: Bool) {
    if showFlag == true{ // Show linked view.
      viewLinkedMemberView.hidden = false
    }
    else{ // Hide linked view.
      viewLinkedMemberView.hidden = true
    }
  }

  // MARK:  chooseMemberBtnClicked method.
  func chooseMemberBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    chooseMemberIndex = tagIndex
    
    tableViewLinkedMember.reloadData()
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
 * Extension of MVPForgotPasswordViewController to add UITextField prototcol UITextFieldDelegate.
 * Override the protocol method of textfield delegate in LoginViewController to handle textfield action event and slector method.
 */
// MARK:  UITextField Delegates methods
extension MVPForgotPasswordViewController: UITextFieldDelegate{
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textFieldEmail.resignFirstResponder()
    return true
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
    return true
  }
  
}



/*
 * Extension of MVPForgotPasswordViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in LoginViewController.
 */
// MARK:  Extension of MVPForgotPasswordViewController by UITableView DataSource & Delegates method.
extension MVPForgotPasswordViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50.0
  }
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return linkedMemberArray.count
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: LinkedMemberTableViewCell = (tableView.dequeueReusableCellWithIdentifier(LINKEDMEMBERTABLEVIEWCELL) as? LinkedMemberTableViewCell!)!
    
    let linkedMember = linkedMemberArray[indexPath.row]
    let memberName = (linkedMember["MemberName"] as! String).capitalizedString
    cell.labelMemberName.text = memberName
    
    if chooseMemberIndex == indexPath.row{
      cell.buttonChooseMember.setBackgroundImage(UIImage(named: "checkedin"), forState: UIControlState.Normal)
    }
    else{
      cell.buttonChooseMember.setBackgroundImage(UIImage(named: "uncheckedin"), forState: UIControlState.Normal)
    }
    
    cell.buttonChooseMember.tag = indexPath.row
    cell.buttonChooseMember.addTarget(self, action: #selector(MVPForgotPasswordViewController.chooseMemberBtnClicked(_:)), forControlEvents: .TouchUpInside)
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewLinkedMember.reloadData()
  }
  
}
