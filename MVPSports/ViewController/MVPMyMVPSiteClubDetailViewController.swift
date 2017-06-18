//
//  MVPMyMVPSiteClubDetailViewController.swift
//  MVPSports
//
//  Created by Chetu India on 03/10/16.
//

import UIKit
import MapKit
import MessageUI
import PKHUD



class MVPMyMVPSiteClubDetailViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var parentScrollView: UIScrollView!
  @IBOutlet weak var viewParentView: UIView!
  @IBOutlet weak var labelHeaderTitle: UILabel!
  @IBOutlet weak var imageViewClubStatus: UIImageView!
  @IBOutlet weak var labelSiteClubName: UILabel!
  @IBOutlet weak var labelSiteClubSchedule: UILabel!
  @IBOutlet weak var labelSiteClubAddress: UILabel!
  @IBOutlet weak var labelBadgeCount: UILabel!

  @IBOutlet weak var viewHeaderView: UIView!
  @IBOutlet weak var viewMapView: UIView!
  @IBOutlet weak var viewFooterView: UIView!
  
  @IBOutlet weak var buttonLeaveFeedBack: UIButton!
  @IBOutlet weak var buttonCallNow: UIButton!
  @IBOutlet weak var buttonEmailUs: UIButton!
  @IBOutlet weak var mapViewSiteClub: MKMapView!
  
  @IBOutlet weak var imageViewArrowIcon: UIImageView!
  @IBOutlet weak var imageViewArrowIconHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageViewArrowIconWidthConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var viewMapViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var viewHeaderViewHeightConstraint: NSLayoutConstraint!

  // MARK:  instance variables, constant decalaration and define with some values.
  var dimView = UIView()
  var tableview = DrawerTableView()
  var siteClub = SiteClub()
  var siteClubId = ""
  var apiFlag = false
  var mapViewFlag = false
  var userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
  var headerViewHeight = 180

  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    if siteClubId.characters.count != 0{
      labelHeaderTitle.text = "Club Detail"
    }
    else{
      labelHeaderTitle.text = "Contact"
    }

    // Call method to set UI of screen.
    self.preparedScreenDesign()
    
    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      
      // Code to fetch site club from api endpoint services to load into contact screen.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      
      // Code to call fetchSiteClub method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 3)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        self.fetchSiteClub()
      })
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
 
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

  
  // MARK:  getSiteClubId method.
  func getSiteClubId() {
    var defaultSiteClubId = ""
    
    if userLoginFlag == true{ // When user is logged in
      var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
      defaultSiteClubId = loggedUserDict["Siteid"]! as String
    }
    else{ // When user is not logged in.
      var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
      if unLoggedUserDict.count > 0{ // Code to validate for un logged user default Site Class already in local .plist DB.
        if let siteid = unLoggedUserDict["siteId"]{
          defaultSiteClubId = siteid as String
        }
      }
    }

    if siteClubId.characters.count != 0{
      if siteClubId == defaultSiteClubId {
        imageViewClubStatus.image = UIImage(named: "starblack-filled")
      }
      else{
        imageViewClubStatus.image = UIImage(named: "siteunfavourite")
      }
    }
    else{ // From Contact Us
      siteClubId = defaultSiteClubId
      imageViewClubStatus.image = UIImage(named: "starblack-filled")
    }
    
  }
  
  
  // MARK:  fetchSiteClub method.
  func fetchSiteClub() {
    self.getSiteClubId()
    
    // Code to initiate input param dictionary to fetch all Site Clubs of application.
    let inputField = [String: String]()
    
    // Code to execute the getSiteClubsBy api endpoint from SiteClubService class method getSiteClubsBy to fetch all SiteClub of application.
    SiteClubService.getSiteClubsBy(inputField, completion: { (apiStatus, arrayOfSiteClubs) -> () in
      var alertTitle = ""
      var alertMsg = ""
      
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        let arrayOfSiteClubObjects = arrayOfSiteClubs as! [SiteClub]
        if arrayOfSiteClubObjects.count > 0{
          for index in 0..<arrayOfSiteClubObjects.count {
            let siteClubIs =  arrayOfSiteClubObjects[index] 
            if let clubId = siteClubIs.clubid{
              if clubId == self.siteClubId{
                self.siteClub = siteClubIs
                self.apiFlag = true
                break
              }
            }
          }
        }
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        alertTitle = NSLocalizedString(ERRORTITLE, comment: "")
        alertMsg = "Api service failure"
      }
      else{ // For Network error.
        alertTitle = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        alertMsg = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to upate UI in the Main thread when GetRewards api response execute successfully.
      dispatch_async(dispatch_get_main_queue()) {
        HUD.hide(animated: true)
        
        if apiStatus == ApiResponseStatusEnum.Success{ // Load Club detail into UI
          // Call method to set UI of screen.
          self.preparedScreenDesign()
        }
        else{ // Show aert for the failure.
          self.showAlerrtDialogueWithTitle(alertTitle, AndErrorMsg: alertMsg)
        }
      }
      
    })
    
  }
  
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    // Code to Change the lable font size for the iPhone_5 device.
    if DeviceType.IS_IPHONE_5 {
      labelSiteClubName.font = SEVENTEENSYSTEMMEDIUMFONT
      labelSiteClubSchedule.font = FOURTEENSYSTEMMEDIUMFONT
      labelSiteClubAddress.font = FOURTEENSYSTEMMEDIUMFONT
    }
    else if DeviceType.IS_IPHONE_6 {
    }
    else if DeviceType.IS_IPHONE_6P {
    }
    
    // Code to set UI view design of the screen for the api flag of SiteClub
    if apiFlag{
      viewHeaderView.hidden = false
      viewMapView.hidden = false
      viewFooterView.hidden = false
      
      buttonCallNow.layer.cornerRadius = VALUETWENTYCORNERRADIUS
      buttonEmailUs.layer.cornerRadius = VALUETWENTYCORNERRADIUS
      
      let siteClubName = siteClub.clubName! as String
      let siteClubAddress = siteClub.address! as String
      let siteClubSchedule =  SiteClubsViewModel.getSiteClubOperationScheduleBy(siteClub)
      
      labelSiteClubName.text = siteClubName
      labelSiteClubAddress.text = siteClubAddress
      labelSiteClubSchedule.text = siteClubSchedule
      
      let siteClubLat = siteClub.lat! as String
      let siteClubLang = siteClub.lang! as String
      if ScheduleViewModel.validateSiteClubCordinates(siteClubLat, and: siteClubLang) {
        
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
        let siteClubLocation = CLLocationCoordinate2D(latitude: Double(siteClubLat)!, longitude: Double(siteClubLang)!)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(siteClubLocation, theSpan)
        mapViewSiteClub.setRegion(theRegion, animated: true)
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = siteClubLocation
        
        let clubAddress = siteClub.address! as String
        if clubAddress.characters.count > 0{
          anotation.title = clubAddress
        }
        else{
          anotation.title = "Street"
        }
        
        mapViewSiteClub.addAnnotation(anotation)
        mapViewSiteClub.selectAnnotation(anotation, animated: false)
      }
      
      let labelFont = self.labelSiteClubSchedule.font
      let labelWidth = self.view.frame.size.width - 90
      let labelHeight = UtilManager.sharedInstance.heightForLabel(siteClubSchedule, font: labelFont, width: labelWidth)
      if labelHeight > 60{
        headerViewHeight = 130 + Int(labelHeight)
      }
      viewHeaderViewHeightConstraint.constant = CGFloat(headerViewHeight)
      
      // Code to call method for hide mapView.
      self.showHideMapViewByContraintValue(false)
    }
    else{
      viewHeaderView.hidden = true
      viewMapView.hidden = true
      viewFooterView.hidden = true
    }
  }
  

  
  
  // MARK:  socialMediaPageBackButtonTapped method.
  @IBAction func socialMediaPageBackButtonTapped(sender: UIButton){
    var socialMediaPageUrl = ""
    let tagIndex = sender.tag
    switch tagIndex {

    case 101:
      socialMediaPageUrl = siteClub.facebookPageUrl!

    case 201:
      socialMediaPageUrl = siteClub.instagramPageUrl!

    case 301:
      socialMediaPageUrl = siteClub.twitterPageUrl!

    case 401:
      socialMediaPageUrl = siteClub.youtubePageUrl!

    default:
      print("")
    }
    
    if socialMediaPageUrl.characters.count > 0{
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let viewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPACCOUNTLINKSVIEWCONTROLLER) as! MVPMyMVPAccountLinksViewController
      viewController.accountLinkUrlString = socialMediaPageUrl
      self.navigationController?.pushViewController(viewController, animated: true)
    }
  }
  
  // MARK:  leaveFeedBackButtonTapped method.
  @IBAction func leaveFeedBackButtonTapped(sender: UIButton){
    NavigationViewManager.instance.navigateToGiveFeedbackViewControllerFrom(self)
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
  
  // MARK:  mapViewArrowButtonTapped method.
  @IBAction func mapViewArrowButtonTapped(sender: UIButton){
    if mapViewFlag == true{
      mapViewFlag = false
      
      imageViewArrowIconWidthConstraint.constant = 10
      imageViewArrowIconHeightConstraint.constant = 16
      imageViewArrowIcon.image = UIImage(named: "black-arrow-right")

      self.showHideMapViewByContraintValue(false)
    }
    else{
      mapViewFlag = true
      
      imageViewArrowIconWidthConstraint.constant = 16
      imageViewArrowIconHeightConstraint.constant = 10
      imageViewArrowIcon.image = UIImage(named: "black-arrow-down")
      
      self.showHideMapViewByContraintValue(true)
    }
  }
  
  func showHideMapViewByContraintValue(showFlag: Bool) {
    
    if showFlag == true{
      let parentScrollViewHeigh = headerViewHeight + 610
      viewMapViewHeightConstraint.constant = 270
      parentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGFloat(parentScrollViewHeigh))
    }
    else{
      let parentScrollViewHeigh = headerViewHeight + 340
      viewMapViewHeightConstraint.constant = 0
      parentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGFloat(parentScrollViewHeigh))
    }
  }
  

  // MARK:  setDefaultSiteClubButtonTapped method.
  @IBAction func setDefaultSiteClubButtonTapped(sender: UIButton){
    if siteClub.isUserDafault == false{
      // Code to validate site class is laready marked favourite or not.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      
      // Code to call setDefaultSiteClubOfSelected method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        self.setDefaultSiteClubOfSelected(self.siteClub)
      })
      
    }
    else{
      var title = ""
      var message = ""
      title = NSLocalizedString(ALERTTITLE, comment: "")
      message = NSLocalizedString(ALREADYYOURDEFAULTSITECLUB, comment: "")
      
      self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
    }
  }
  
  
  
  // MARK:  callNowButtonTapped method.
  @IBAction func callNowButtonTapped(sender: UIButton){
    let siteClubContactNumber = siteClub.phone! as String
    let numberDigitsArray = siteClubContactNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
    let phoneNumber = numberDigitsArray.joinWithSeparator("")
    
    if phoneNumber.characters.count > 0{
      if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
        let application:UIApplication = UIApplication.sharedApplication()
        if (application.canOpenURL(phoneCallURL)) {
          application.openURL(phoneCallURL);
        }
      }
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(ALERTTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOSITECLUBPHONENUMBER, comment: ""))
    }
  }
  
  // MARK:  emailUsButtonTapped method.
  @IBAction func emailUsButtonTapped(sender: UIButton){
    let mailComposeViewController = configuredMailComposeViewController()
    if MFMailComposeViewController.canSendMail() {
      self.presentViewController(mailComposeViewController, animated: true, completion: nil)
    }
    else {
      self.showSendMailErrorAlert()
    }
  }
  
  // MARK:  configuredMailComposeViewController method.
  func configuredMailComposeViewController() -> MFMailComposeViewController {
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self
    // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    
    let siteClubEmailAddress = siteClub.email! as String
    if siteClubEmailAddress.characters.count > 0{
      mailComposerVC.setToRecipients([siteClubEmailAddress])
    }
    
    return mailComposerVC
  }
  
  // MARK:  showSendMailErrorAlert method.
  func showSendMailErrorAlert() {
    self.showAlerrtDialogueWithTitle(NSLocalizedString(COULDNOTSENDEMAILTITLE, comment: ""), AndErrorMsg: NSLocalizedString(COULDNOTSENDEMAILMSG, comment: ""))
  }
  
  

  
  
  // MARK:  setUnLoggedUserDefaultSiteClub method.
  func setUnLoggedUserDefaultSiteClub(selectedSiteClub: SiteClub) {
    // Code to save UnLogged user default site club info in local .plist file.
    var SiteId = ""
    var SiteName = ""
    if let siteid = selectedSiteClub.clubid{
      SiteId = siteid as String
    }
    if let sitename = selectedSiteClub.clubName{
      SiteName = sitename as String
    }
    
    var unLoggedUserDict = [String: String]()
    unLoggedUserDict["siteId"] = SiteId
    unLoggedUserDict["siteName"] = SiteName
    UserViewModel.saveUnLoggedUserDictInUserDefault(unLoggedUserDict)
    
    /*
     * Code to update the user status flag boolean value to true.
     * Bcoz over here user status get changed from UnLogeed user to Logged user.
     */
    UserViewModel.setUserStatusInApplication(true)
    
    /*
     * Code to update the Change Location flag boolean value to true.
     */
    UserViewModel.setChangeLocationStatusInApplication(true)
    
    // Code to upate UI in the Main thread.
    dispatch_async(dispatch_get_main_queue()) {
      // Code to hide loader
      HUD.hide(animated: true)
      
      // Code to reset the local cache from SQLite database to pop to rootViewController.
      self.reSetLocalCacheFromSqliteDatabase()
    }
  }
  
  // MARK:  setLoggedUserDefaultSiteClub method.
  func setLoggedUserDefaultSiteClub(siteClub: SiteClub) {
    var setDefaultSiteClassInputField = [String: String]()
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    
    setDefaultSiteClassInputField["memid"] = memberId
    setDefaultSiteClassInputField["siteid"] = siteClub.clubid! as String
    
    /*
     * Code to set user default Site Class by SetDefaultSiteClass api endpoint service.
     * SiteClubService class method setDefaultSiteClubsBy to execute api to set Site Class as default site class of user.
     */
    // Code to execute the setDefaultSiteClubsBy api endpoint from SiteClubService class method setDefaultSiteClubsBy to set selected SiteClass as default SiteClass.
    SiteClubService.setDefaultSiteClubsBy(setDefaultSiteClassInputField, completion: { (apiStatus, response) -> () in
      var apiFlag = false
      var title = ""
      var message = ""
      
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = "\(siteClub.clubName! as String) set as default Site Class"
        
        // Code to save logged user default site club info in local .plist file.
        var SiteId = ""
        var SiteName = ""
        if let siteid = siteClub.clubid{
          SiteId = siteid as String
        }
        if let sitename = siteClub.clubName{
          SiteName = sitename as String
        }
        
        var userDict = [String: String]()
        userDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
        userDict["Siteid"] = SiteId
        userDict["siteName"] = SiteName
        UserViewModel.saveUserDictInUserDefault(userDict)
        
        /*
         * Code to update the user status flag boolean value to true.
         * Bcoz over here user status get changed from UnLogeed user to Logged user.
         */
        UserViewModel.setUserStatusInApplication(true)
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(ERROROCCUREDTOSETASDEFAULTSITECLASSMSG, comment: "")
      }
      else{ // For Network error.
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        
        if apiFlag == true{
          // Code to hide loader
          HUD.hide(animated: true)

          // Code to reset the local cache from SQLite database to pop to rootViewController.
          self.reSetLocalCacheFromSqliteDatabase()
        }
        else{
          // Code to hide progress loader.
          HUD.hide(animated: true)
          // Code to show alert dialogue box.
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
    })
  }
  
  // MARK:  setDefaultSiteClubOfSelected method.
  func setDefaultSiteClubOfSelected(siteClub: SiteClub) {
    
    if userLoginFlag == true{ // When user is Logged In
      self.setLoggedUserDefaultSiteClub(siteClub)
    }
    else{ // when user is Logged Out
      self.setUnLoggedUserDefaultSiteClub(siteClub)
    }
  }

  // MARK:  reSetLocalCacheFromSqliteDatabase method.
  func reSetLocalCacheFromSqliteDatabase() {
    
    // Code to delete from records from SiteClassByDate table for un logged user default Site Class.
    let deleteQueryString = "\(deleteFromSiteClassByDateQuery)\("\n")\(deleteFromSiteClassByInstructorQuery)\("\n")\(deleteFromSiteClassByClassesQuery)\("\n")\(deleteFromSiteClassByUserFavouriteQuery)"
    DBManager.sharedInstance.executeDeleteQueryBy(deleteQueryString)
    
    // Code navigae to the Root ViewController.
    self.navigationController?.popToRootViewControllerAnimated(true)
  }
  
  
  
  
  
  // MARK:  drawerButtonTapped method.
  @IBAction func drawerButtonTapped(sender: UIButton){
    dimView.frame = self.view.frame
    dimView.backgroundColor = BLACKCOLOR
    dimView.alpha = 0.0
    self.view.addSubview(dimView)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(MVPMyMVPScheduleViewController.handleOuterViewWithDrawerTapGesture))
    dimView.addGestureRecognizer(tap)
    
    let yPoint = 20 + viewParentView.frame.size.height
    let xPoint = self.view.frame.size.width/2
    tableview = DrawerTableView(frame: CGRectMake(self.view.frame.size.width, yPoint, self.view.frame.size.width/2, self.view.frame.size.height-yPoint), style: .Plain)
    tableview.parentViewController = self
    tableview.drawerDelegate = self
    self.view.addSubview(tableview)
    
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.tableview.frame = CGRectMake(xPoint, yPoint, self.tableview.frame.size.width, self.tableview.frame.size.height)
      self.dimView.alpha = 0.6
      
      }, completion: { finished in
        // Code to
    })
  }
  
  // MARK:  handleOuterViewWithDrawerTapGesture method.
  func handleOuterViewWithDrawerTapGesture() {
    let yPoint = 20 + viewParentView.frame.size.height
    let xPoint = self.view.frame.size.width
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.tableview.frame = CGRectMake(xPoint, yPoint, self.tableview.frame.size.width, self.tableview.frame.size.height)
      self.dimView.alpha = 0.0
      
      }, completion: { finished in
        // Code to remove tableview from self view
        self.tableview.removeFromSuperview()
        self.dimView.removeFromSuperview()
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



// MARK:  Extension of MVPMyMVPSiteClubDetailViewController by DrawerTableViewDelegate method.
extension MVPMyMVPSiteClubDetailViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.ContactHours{
      self.handleOuterViewWithDrawerTapGesture()
    }
    else{
      self.popDrawerView()
    }
  }
}


// MARK:  Extension of MVPMyMVPSiteClubDetailViewController by MFMailComposeViewControllerDelegate method.
extension MVPMyMVPSiteClubDetailViewController: MFMailComposeViewControllerDelegate{
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    switch result.rawValue {
    case MFMailComposeResultCancelled.rawValue:
      print("Mail cancelled")
    case MFMailComposeResultSaved.rawValue:
      print("Mail saved")
    case MFMailComposeResultSent.rawValue:
      print("Mail sent")
    case MFMailComposeResultFailed.rawValue:
      print("Mail sent failure: \(error!.localizedDescription)")
    default:
      break
    }
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
  
}


// MARK:  Extension of MVPMyMVPSiteClubDetailViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPSiteClubDetailViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}

