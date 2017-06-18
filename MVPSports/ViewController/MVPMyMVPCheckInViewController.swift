//
//  MVPMyMVPCheckInViewController.swift
//  MVPSports
//
//  Created by Chetu India on 05/10/16.
//

import UIKit
import PKHUD


class MVPMyMVPCheckInViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var scrollViewCheckIn: UIScrollView!
  @IBOutlet weak var imageViewLoggedUserBarCode: UIImageView!
  @IBOutlet weak var labelMemberNumber: UILabel!
  @IBOutlet weak var labelMemberName: UILabel!
  @IBOutlet weak var labelMemberStatus: UILabel!
  @IBOutlet weak var labelMemberType: UILabel!
  @IBOutlet weak var buttonClassCheckIn: UIButton!
  @IBOutlet weak var imageViewLoggedUserImageView: UIImageView!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  let loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
  
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    // Code to mark log event on to flurry for CheckIn screen view.
    dispatch_async(dispatch_get_main_queue(), {
      FlurryManager.sharedInstance.setFlurryLogForScreenType(ViewScreensEnum.CheckIn)
    })
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to disable idle timer for the CheckIn screen only.
    UIApplication.sharedApplication().idleTimerDisabled = true

    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to enable idle timer when user out from the CheckIn screen.
    UIApplication.sharedApplication().idleTimerDisabled = false
  }
  
  
  
  
  /*
   * prepareUiComponent method is created to set all UI design element configuration with some property.
   */
  // MARK:  prepareUiComponent method.
  func prepareUiComponent() {
    /*
     * Code to Change the lable font size for the iPhone_5 device.
     */
    if DeviceType.IS_IPHONE_5 {
      labelMemberName.font = SEVENTEENSYSTEMSEMIBOLDFONT
      labelMemberNumber.font = FOURTEENSYSTEMMEDIUMFONT
      labelMemberType.font = FOURTEENSYSTEMFONT
      labelMemberStatus.font = FOURTEENSYSTEMFONT
    }
    else if DeviceType.IS_IPHONE_6 {
    }
    else if DeviceType.IS_IPHONE_6P {
    }
    
    buttonClassCheckIn.layer.cornerRadius = VALUEFIFTEENCORNERRADIUS
  }

  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    // Code to call method to set view of widget components.
    self.prepareUiComponent()

    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    if let memberShipDesc = loggedUserDict["memberShipDesc"] {
      labelMemberType.text = "\(memberShipDesc)"
    }
    else{
      labelMemberType.text = ""
    }

    var memberNumber = ""
    if let memNumber = loggedUserDict["memberNumber"] {
      memberNumber = memNumber
      labelMemberNumber.text = "\(memberNumber)"
    }
    else{
      memberNumber = "12345"
      labelMemberNumber.text = ""
    }

    let size = CGSize(width: 150, height: 150)
    imageViewLoggedUserBarCode.image = self.convertTextToQRCode(memberNumber, withSize: size)
    imageViewLoggedUserBarCode.contentMode = .ScaleAspectFit
    imageViewLoggedUserBarCode.clipsToBounds = true
    
    var firstName = ""
    if let name = loggedUserDict["firstName"]{
      firstName = name
    }
    let labelWidth = self.view.frame.size.width - 200
    let labelFont = labelMemberName.font as UIFont
    let truncatedName = SiteClubsViewModel.getSiteClubLocationTruncatedLabelStringFrom(firstName, font: labelFont, labelWidth: labelWidth)
    labelMemberName.text = truncatedName.uppercaseString
    
    var img = ""
    if let image = loggedUserDict["img"]{
      img = image
      
      if img.characters.count > 0{
        let decodedData = NSData(base64EncodedString: img, options: NSDataBase64DecodingOptions(rawValue: 0))
        let decodedimage = UIImage(data: decodedData!)
        imageViewLoggedUserImageView.image = decodedimage! as UIImage
      }
    }
  }
  
  
  
  // MARK:  convertTextToQRCode method.
  func convertTextToQRCode(text: String, withSize size: CGSize) -> UIImage {
    let data = text.dataUsingEncoding(NSASCIIStringEncoding)
    let filter = CIFilter(name: "CIQRCodeGenerator")
    filter!.setValue(data, forKey: "inputMessage")
    filter!.setValue("Q", forKey: "inputCorrectionLevel")
    
    let qrcodeCIImage = filter!.outputImage!
    
    let cgImage = CIContext(options:nil).createCGImage(qrcodeCIImage, fromRect: qrcodeCIImage.extent)
    UIGraphicsBeginImageContext(CGSizeMake(size.width * UIScreen.mainScreen().scale, size.height * UIScreen.mainScreen().scale))
    let context = UIGraphicsGetCurrentContext()
    CGContextSetInterpolationQuality(context, .None)
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
    let preImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let qrCodeImage = UIImage(CGImage: preImage.CGImage!, scale: 1.0/UIScreen.mainScreen().scale, orientation: .DownMirrored)
    return qrCodeImage
  }
  
  
  // MARK:  crossButtonTapped method.
  @IBAction func crossButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  buttonClassCheckInTapped method.
  @IBAction func buttonClassCheckInTapped(sender: UIButton){
    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      
      // Code to call fetchUserCheckInScheduleExerciseClasses method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        
        self.getLoggedUserCheckInStatus()
      })
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }

  /*
   * getLoggedUserCheckInStatus method to execute GetIsCheckedIn api endpoint service for logged user CheckIn Status for default site club.
   */
  // MARK:  getLoggedUserCheckInStatus method.
  func getLoggedUserCheckInStatus() {
    // Code to initiate input param dictionary to get logged user Site Club CheckIn status.
    var inputField = [String: String]()
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    inputField["memid"] = memberId

    // Code to devlare ceriable for the Api Endpoint service handling.
    var apiFlag = false
    var title = ""
    var message = ""
    // Code to execute the GetIsCheckedIn api endpoint from CheckInService class method getUserSiteClubCheckInStatusBy to get Logged User Site Club CheckIn status.
    CheckInService.getUserSiteClubCheckInStatusBy(inputField, completion: { (apiStatus, checkInStatus) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.

        if checkInStatus as! Bool == true{
          apiFlag = true
        }
        else{
          title = NSLocalizedString(ERRORTITLE, comment: "")
          message = NSLocalizedString(CHECKEDINSTATUSFAILUREALERTMSG, comment: "")
        }
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = NSLocalizedString(CHECKEDINSTATUSAPIFAILUREALERTMSG, comment: "")
      }
      else{ // For Network error.
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to upate UI in the Main thread when SiteClassesForCheckin api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide loader
        HUD.hide(animated: false)
        
        if apiFlag == true{
          // Code to navigate to CheckInClasses viewController for the logged user to mark checkin into Site Classes of Site Club.
          let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
          let mvpMyMVPCheckInClassViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCHECKINCLASSVIEWCONTROLLER) as! MVPMyMVPCheckInClassViewController
          self.navigationController?.pushViewController(mvpMyMVPCheckInClassViewController, animated: true)
        }
        else{
          // Code to show alert viewController on failure.
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
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

// MARK:  Extension of MVPMyMVPCheckInViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPCheckInViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    print("MVPMyMVPCheckInViewController announcementDelegate")
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

