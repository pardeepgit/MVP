//
//  MVPMyMVPRewardSendToFriendViewController.swift
//  MVPSports
//
//  Created by Chetu India on 15/11/16.
//

import UIKit
import PKHUD


class MVPMyMVPRewardSendToFriendViewController: UIViewController {

  // MARK:  Widget elements declarations.
  @IBOutlet weak var textFieldFriendEmail: UITextField!
  @IBOutlet weak var buttonSendRewards: UIButton!
  @IBOutlet weak var buttonCopyMeOnEmailCheckUnCheck: UIButton!
  @IBOutlet weak var labelBadgeCount: UILabel!

  @IBOutlet weak var viewSendRewardStatusView: UIView!
  @IBOutlet weak var labelSentRewardFriendEmailLabel: UILabel!
  @IBOutlet weak var labelSentRewardFriendEmailLabelHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var labelSentRewardDescriptionLabel: UILabel!
  @IBOutlet weak var labelRewardDescriptionHeightConstraint: NSLayoutConstraint!


  // MARK:  instance variables, constant decalaration and define with some values.
  var selectedSendRewardToFriendMail = Reward()
  var copyMeOnEmailFlag = false
  
  // For Drawer View.
  var dimView = UIView()
  var tableview = DrawerTableView()

  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    self.preparedScreenDesign()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
    RemoteNotificationObserverManager.sharedInstance.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    // Code to hide Send reward status view.
    viewSendRewardStatusView.hidden = true
    self.buttonSendRewards.layer.cornerRadius = VALUETENCORNERRADIUS
    
    self.textFieldFriendEmail.layer.borderWidth = VALUEONEBORDERWIDTH
    self.textFieldFriendEmail.layer.borderColor = LIGHTGRAYCOLOR.CGColor
    self.textFieldFriendEmail.layer.cornerRadius = VALUEFIVECORNERRADIUS

    // Code to set left padding to the self.textFieldFriendEmail for the text enter value.
    let paddingView = UIView(frame: CGRectMake(0, 0, 30, self.textFieldFriendEmail.frame.height))
    self.textFieldFriendEmail.leftView = paddingView
    self.textFieldFriendEmail.leftViewMode = UITextFieldViewMode.Always
    
    
    // Code to prepare design od Send reward to Friends emial view.
    if selectedSendRewardToFriendMail.friendsEmail?.characters.count > 0{
      self.textFieldFriendEmail.text = selectedSendRewardToFriendMail.friendsEmail
    }
    else{
      self.textFieldFriendEmail.text = ""
      self.textFieldFriendEmail.placeholder = FriendEmailFieldIdentifier
    }
    copyMeOnEmailFlag = selectedSendRewardToFriendMail.copyMeOnEmail!
    
    // Code to set background image of buttonCopyMeOnEmailCheckUnCheck button by copyMeOnEmailFlag boolean flag veriable value.
    if copyMeOnEmailFlag{
      buttonCopyMeOnEmailCheckUnCheck.setBackgroundImage(UIImage(named: "check.png"), forState: UIControlState.Normal)
    }
    else{
      buttonCopyMeOnEmailCheckUnCheck.setBackgroundImage(UIImage(named: "uncheck.png"), forState: UIControlState.Normal)
    }
    
    let labelFont = self.labelSentRewardDescriptionLabel.font
    let labelWidth = self.view.frame.size.width - 80
    let rewardDescription = self.labelSentRewardDescriptionLabel.text
    let labelHeight = UtilManager.sharedInstance.heightForLabel(rewardDescription!, font: labelFont, width: labelWidth)
    self.labelRewardDescriptionHeightConstraint.constant = labelHeight + 10
  }
  
  
  
  
  
  // MARK:  buttonSendRewardsTapped method.
  @IBAction func buttonSendRewardsTapped(sender: UIButton){
    view.endEditing(true)
    /*
     * Code to check device is connected to internet connection or not.
     */
    if Reachability.isConnectedToNetwork() == true {
      let friendMail = textFieldFriendEmail.text
      
      // Code to validate the username and password field value.
      if friendMail!.characters.count == 0{
        self.showAlerrtDialogueWithTitle(NSLocalizedString(ERRORTITLE, comment: ""), AndErrorMsg: NSLocalizedString(FRIENDEMAILALERTMSG, comment: ""))
      }
      else if !UtilManager.sharedInstance.isValidEmail(friendMail!){
        self.showAlerrtDialogueWithTitle(NSLocalizedString(ERRORTITLE, comment: ""), AndErrorMsg: NSLocalizedString(VALIDEMAILALERTMSG, comment: ""))
      }
      else{
        // Code to show loader.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(SENDINGMSG, comment: "")))
        
        let memid  = selectedSendRewardToFriendMail.memid! as String
        let rewardId  = selectedSendRewardToFriendMail.rewardId! as String
        let friendsEmail  = self.textFieldFriendEmail.text! as String
        
        var inputParamField = [String: String]()
        inputParamField["memid"] = memid
        inputParamField["FriendsEmail"] = friendsEmail
        inputParamField["RewardId"] = rewardId
        
        if copyMeOnEmailFlag{
          inputParamField["CopyMeOnEmail"] = "true"
        }
        else{
          inputParamField["CopyMeOnEmail"] = "false"
        }
        
        self.sendRewardToFriendMailApiService(inputParamField)
      }
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  // MARK:  sendRewardToFriendMailApiService method.
  func  sendRewardToFriendMailApiService(inputParam: [String: String]) {
    var apiFlag = false
    
    // Code to execute the GetRewards api endpoint from RewardService class method getMyMvpRewardBy to fetch all rewards of memid.
    RewardService.sendRewardToFriendEmailServiceBy(inputParam, completion: { (responseStatus, arrayOfRewardsObject) -> () in
      if responseStatus == ApiResponseStatusEnum.Success{
        apiFlag = true
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{
      }
      else if responseStatus == ApiResponseStatusEnum.ClientTokenExpiry{
      }
      else if responseStatus == ApiResponseStatusEnum.NetworkError{
      }
      else{
      }
      
      // Code to upate UI in the Main thread when GetRewards api response execute successfully.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide progress loader.
        HUD.hide(animated: true)
        
        if apiFlag == true{
          /*
           * Code to update the user status flag boolean value to true.
           * Bcoz over here user status get changed from UnLogeed user to Logged user.
           */
          UserViewModel.setUserStatusInApplication(true)
          
          let rewardName = self.selectedSendRewardToFriendMail.name! as String
          let friendsEmail  = self.textFieldFriendEmail.text! as String
          let statusMessage = "A \(rewardName) is on its way to\n\(friendsEmail)."
          self.labelSentRewardFriendEmailLabel.text = statusMessage
          
          let labelFont = self.labelSentRewardFriendEmailLabel.font
          let labelWidth = self.view.frame.size.width - 60
          let labelHeight = UtilManager.sharedInstance.heightForLabel(statusMessage, font: labelFont, width: labelWidth)
          self.labelSentRewardFriendEmailLabelHeightConstraint.constant = labelHeight + 5
          
          UIView.animateWithDuration(10.5, delay: 5.5, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
              self.viewSendRewardStatusView.hidden = false
            }, completion: { (finished: Bool) -> Void in
              
              // Code to call backButtonTapped method after certain one second delay.
              let triggerTime = (Int64(NSEC_PER_SEC) * 2)
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.backButtonTapped(UIButton())
              })
          })
          
        }
      }
      
    })
  }
  
  
  
  // MARK:  buttonSendRewardsTapped method.
  @IBAction func buttonCopyMeOnEmailCheckUnCheckTapped(sender: UIButton){
    // Code to execute check box functionalit of custom check box button by copyMeOnEmailFlag boolean veriable.
    if copyMeOnEmailFlag{
      copyMeOnEmailFlag = false
      buttonCopyMeOnEmailCheckUnCheck.setBackgroundImage(UIImage(named: "uncheck.png"), forState: UIControlState.Normal)
    }
    else{
      copyMeOnEmailFlag = true
      buttonCopyMeOnEmailCheckUnCheck.setBackgroundImage(UIImage(named: "check.png"), forState: UIControlState.Normal)
    }
  }
  
  // MARK:  notificationAlertBellBtnClicked method.
  @IBAction func notificationAlertBellBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
  
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  homeButtonTapped method.
  @IBAction func homeButtonTapped(sender: UIButton){
    // Code navigae to the Root ViewController.
    NavigationViewManager.instance.navigateToRootViewControllerFrom(self)
  }

  
  

  
  // MARK:  drawerButtonTapped method.
  @IBAction func drawerButtonTapped(sender: UIButton){
    dimView.frame = self.view.frame
    dimView.backgroundColor = BLACKCOLOR
    dimView.alpha = 0.0
    self.view.addSubview(dimView)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(MVPDashboardViewController.handleOuterViewWithDrawerTapGesture))
    dimView.addGestureRecognizer(tap)
    
    let xPoint = self.view.frame.size.width/2
    tableview = DrawerTableView(frame: CGRectMake(self.view.frame.size.width, 80, self.view.frame.size.width/2, self.view.frame.size.height-80), style: .Plain)
    tableview.parentViewController = self
    tableview.drawerDelegate = self
    self.view.addSubview(tableview)
    
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.tableview.frame = CGRectMake(xPoint, 80, self.tableview.frame.size.width, self.tableview.frame.size.height)
      self.dimView.alpha = 0.6
      
      }, completion: { finished in
        // Code to
    })
  }
  
  // MARK:  handleOuterViewWithDrawerTapGesture method.
  func handleOuterViewWithDrawerTapGesture() {
    let xPoint = self.view.frame.size.width
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.tableview.frame = CGRectMake(xPoint, 80, self.tableview.frame.size.width, self.tableview.frame.size.height)
      self.dimView.alpha = 0.0
      
      }, completion: { finished in
        // Code to remove tableview from self view
        self.dimView.removeFromSuperview()
        self.tableview.removeFromSuperview()
    })
  }

  // MARK:  popDrawerView method.
  func popDrawerView() {
    // Code to remove drawer tableview from self view
    self.dimView.removeFromSuperview()
    self.tableview.removeFromSuperview()
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
 * Extension of MVPMyMVPRewardSendToFriendViewController to add UITextField prototcol UITextFieldDelegate.
 * Override the protocol method of textfield delegate in MVPMyMVPRewardSendToFriendViewController to handle textfield action event and slector method.
 */
// MARK:  UITextField Delegates methods
extension MVPMyMVPRewardSendToFriendViewController: UITextFieldDelegate{
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}

// MARK:  Extension of MVPMyMVPRewardSendToFriendViewController by DrawerTableViewDelegate method.
extension MVPMyMVPRewardSendToFriendViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    self.popDrawerView()
  }
}

// MARK:  Extension of MVPMyMVPRewardSendToFriendViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPRewardSendToFriendViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}
