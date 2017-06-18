//
//  MVPMyMVPSiteClassDetailViewController.swift
//  MVPSports
//
//  Created by Chetu India on 08/10/16.
//

import UIKit
import PKHUD


class MVPMyMVPSiteClassDetailViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var viewSiteClassDetailView: UIView!

  @IBOutlet weak var labelClassName: UILabel!
  @IBOutlet weak var labelInstructorName: UILabel!
  @IBOutlet weak var labelClassDate: UILabel!
  @IBOutlet weak var labelClassStartEndTime: UILabel!
  @IBOutlet weak var labelClassLocation: UILabel!
  @IBOutlet weak var labelClassDescription: UILabel!
  @IBOutlet weak var labelClassClubName: UILabel!
  @IBOutlet weak var labelClassDescriptionHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var viewClassInstructorName: UIView!
  @IBOutlet weak var buttonClassInstructorName: UIButton!
  @IBOutlet weak var labelClassInstructorViewWidthConstraint: NSLayoutConstraint!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
  var siteClass = ExerciseClass()
  var apiStatusFlag = false
  
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()

    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      // Code to show progress loader till execute Site Class description api services.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      self.fetchSiteClassDescription()
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  

  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    if apiStatusFlag == true{
      let instructorName = siteClass.classInstructor! as String
      
      labelClassName.text = (siteClass.className! as String).uppercaseString
      labelInstructorName.text = instructorName
      labelClassLocation.text = siteClass.classLocation! as String
      
      let startTime = ScheduleViewModel.getTimeStringFromDateString(siteClass.classStartTime!)
      let endTime = ScheduleViewModel.getTimeStringFromDateString(siteClass.classEndTime!)
      labelClassStartEndTime.text = "\(startTime) - \(endTime)"
      
      let siteClassStartTime = siteClass.classStartTime!
      let siteClassStartDateFormattedString = ScheduleViewModel.getSiteClassFormattedStartDateFrom(siteClassStartTime)
      labelClassDate.text = siteClassStartDateFormattedString
      
      let labelFont = self.labelInstructorName.font
      let labelWidth = UtilManager.sharedInstance.widthForLabel(instructorName, font: labelFont, height: 20.0)
      self.labelClassInstructorViewWidthConstraint.constant = labelWidth
      
      var siteClubName = ""
      if userLoginFlag == true{ // When user is logged in
        var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
        if let sitename = loggedUserDict["siteName"]{
          siteClubName = sitename
        }
      }
      else{ // When user is not logged in
        var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
        if let sitename = unLoggedUserDict["siteName"]{
          siteClubName = sitename as String
        }
      }
      labelClassClubName.text = siteClubName
      
      viewSiteClassDetailView.hidden = false
    }
    else{
      viewSiteClassDetailView.hidden = true
    }
  }
  
  
  
  // MARK:  fetchSiteClassDescription method.
  func fetchSiteClassDescription() {
    // Code to initiate input param dictionary to fetch all Site Clubs of application.
    let inputField = [String: String]()
    let className = siteClass.className! as String
    
    
    ExerciseClassService.getSiteClassDescriptionBy(inputField, For: className, completion: { (responseStatus, classDescription) -> () in
      if responseStatus == ApiResponseStatusEnum.Success{
        // Code to upate UI in the Main thread when SiteClasses api response execute successfully.
        dispatch_async(dispatch_get_main_queue()) {
          // Code to hide progress hud.
          HUD.hide(animated: true)

          let formattedDescription = self.stringFromHTML(classDescription as? String)
          self.labelClassDescription.text = formattedDescription
          
          let labelFont = self.labelClassDescription.font
          let labelWidth = self.view.frame.size.width - 40
          let labelHeight = UtilManager.sharedInstance.heightForLabel(formattedDescription, font: labelFont, width: labelWidth)
          self.labelClassDescriptionHeightConstraint.constant = labelHeight + 20
          
          self.apiStatusFlag = true
          self.preparedScreenDesign()
        }
      }
      else{
        // Code to upate UI in the Main thread when SiteClasses api response status is false to dismis loader.
        dispatch_async(dispatch_get_main_queue()) {
          // Code to hide progress hud.
          HUD.hide(animated: true)
          
          self.apiStatusFlag = false
          self.preparedScreenDesign()
        }
      }
      
    })
  }
  
  // MARK:  stringFromHTML method.
  func stringFromHTML( string: String?) -> String{
    do{
      let str = try NSAttributedString(data:string!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true
        )!, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(unsignedLong: NSUTF8StringEncoding)], documentAttributes: nil)
      return str.string
    }
    catch{
      print("html error\n",error)
    }
    
    return ""
  }
  

  
  
  // MARK:  crossButtonTapped method.
  @IBAction func crossButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  // MARK:  buttonClassInstructorNameTapped method.
  @IBAction func buttonClassInstructorNameTapped(sender: UIButton){
    let instructorName = siteClass.classInstructor! as String
    let instructorId = siteClass.classInstructorId! as String
    if instructorId.characters.count != 0{
      
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let mvpMyMVPInstructorDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPINSTRUCTORDETAILVIEWCONTROLLER) as! MVPMyMVPInstructorDetailViewController
      mvpMyMVPInstructorDetailViewController.selectedInstructorId = instructorId
      mvpMyMVPInstructorDetailViewController.selectedInstructorName = instructorName
      self.navigationController?.pushViewController(mvpMyMVPInstructorDetailViewController, animated: true)
    }
    else{
      let message = "\(instructorName) \(NSLocalizedString(NOINSTRUCTORINFORMATION, comment: ""))"
      self.showAlerrtDialogueWithTitle(NSLocalizedString(ALERTTITLE, comment: ""), AndErrorMsg: message)
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
  
  
  // MARK:  Memoey management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}


// MARK:  Extension of MVPMyMVPSiteClassDetailViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPSiteClassDetailViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
  
}

