//
//  MVPMyMVPCheckInClassViewController.swift
//  MVPSports
//
//  Created by Chetu India on 07/11/16.
//

import UIKit
import PKHUD

typealias InsertCheckInCompletionHandler = (Bool) -> (Void)
typealias DeleteCheckInCompletionHandler = (Bool) -> (Void)


class MVPMyMVPCheckInClassViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewCheckInClass: UITableView!
  @IBOutlet weak var labelNoSiteClassesAvailableForCheckInLabel: UILabel!
  
  
  // MARK:  instance variables, constant decalaration and define with some values.
  var userCheckInScheduleClassArray = [ExerciseClass]()
  let loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
  

  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    labelNoSiteClassesAvailableForCheckInLabel.text = NSLocalizedString(NOCLASSESAVAILABLEMSG, comment: "")
    labelNoSiteClassesAvailableForCheckInLabel.hidden = true
    
    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      
      // Code to call fetchUserCheckInScheduleExerciseClasses method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        self.fetchUserCheckInScheduleExerciseClasses()
      })
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
    
    // Code to hide or show labelNoSiteClassesAvailableForCheckInLabel based on Site Classes for CheckedIn array count.
    if userCheckInScheduleClassArray.count > 0{
      labelNoSiteClassesAvailableForCheckInLabel.hidden = true
      
      // Code to notify UItableView instance to reload data in listview
      self.tableViewCheckInClass.reloadData()
    }
    else{
      labelNoSiteClassesAvailableForCheckInLabel.hidden = false
    }
  }
  
  
  // MARK:  fetchUserCheckInScheduleExerciseClasses method.
  func fetchUserCheckInScheduleExerciseClasses() {
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memid = loggedUserDict["memberId"]! as String
    // Code to initiate input param dictionary to fetch all Site Clubs of application.
    var inputField = [String: String]()
    inputField["siteid"] = memid
    
    // Code to execute the getUserCheckInScheduleClassesBy api endpoint from SiteClubService class method SiteClassesForCheckin to fetch all SiteClasses of application.
    CheckInService.getUserCheckInScheduleClassesBy(inputField, completion: { (apiStatus, arrayOfSiteClasses) -> () in
      
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        self.userCheckInScheduleClassArray.removeAll()
        self.userCheckInScheduleClassArray = arrayOfSiteClasses as! [ExerciseClass]
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
      }
      else{ // For Network error.
      }
      
      // Code to upate UI in the Main thread when SiteClassesForCheckin api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide loader
        HUD.hide(animated: true)
        
        // code to re-set UI screen design.
        self.preparedScreenDesign()
      }
    })
  }

  
  
  // MARK:  crossButtonTapped method.
  @IBAction func crossButtonTapped(sender: UIButton){
    // Code navigae to the Root ViewController.
    NavigationViewManager.instance.navigateToRootViewControllerFrom(self)
  }

  
  
  // MARK:  validateForAlreadyCheckInExerciseSiteClass method.
  func validateForAlreadyCheckInExerciseSiteClass() -> (alreadyCheckedInFlag :Bool, chekedInClassIndex:Int) {
    var alreadyCheckInFlag = false
    var alreadyCheckInExeciseClassIndex = 0
    
    for index in 0..<userCheckInScheduleClassArray.count{
      let exerciseClassObject: ExerciseClass = userCheckInScheduleClassArray[index]
      if exerciseClassObject.userCheckIn == true{
        alreadyCheckInFlag = true
        alreadyCheckInExeciseClassIndex = index
        break
      }
    }
    
    return (alreadyCheckInFlag, alreadyCheckInExeciseClassIndex)
  }
  
  // MARK:  prepareRequestParamForInserCheckInApiBy method.
  func prepareRequestParamForInserCheckInApiBy(exerciseClassObject: ExerciseClass) -> [String: String] {
    var setCheckInSiteClassInputField = [String: String]()
    let memberId = loggedUserDict["memberId"]! as String
    
    setCheckInSiteClassInputField["memid"] = memberId
    setCheckInSiteClassInputField["scancode"] = ""
    setCheckInSiteClassInputField["classid"] = exerciseClassObject.classid! as String
    setCheckInSiteClassInputField["start"] = exerciseClassObject.classStartTime! as String
    setCheckInSiteClassInputField["end"] = exerciseClassObject.classEndTime! as String
    setCheckInSiteClassInputField["location"] = exerciseClassObject.classLocation! as String
    setCheckInSiteClassInputField["instructor"] = exerciseClassObject.classInstructor! as String
    setCheckInSiteClassInputField["classname"] = exerciseClassObject.className! as String
    setCheckInSiteClassInputField["siteid"] = exerciseClassObject.siteid! as String

    return setCheckInSiteClassInputField
  }
  
  // MARK:  markUserCheckInSiteClassBtnClicked method.
  func markUserCheckInSiteClassBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let exerciseClassObject: ExerciseClass = userCheckInScheduleClassArray[tagIndex]
    
    // Code to validate site class is laready marked favourite or not.
    if exerciseClassObject.userCheckIn == false{
      
      // Code of validation tupple for already checked in site class.
      let validateAlreadyCheckedInTuple = self.validateForAlreadyCheckInExerciseSiteClass()
      let alreadyCheckedInFlag = validateAlreadyCheckedInTuple.alreadyCheckedInFlag
      let checkedInClassIndex = validateAlreadyCheckedInTuple.chekedInClassIndex
      
      if alreadyCheckedInFlag == true{

        let alertMsg = "You are already checked into a class at this time. Would you like to change your selection?"
        let alert = UIAlertController(title: "", message:alertMsg , preferredStyle: UIAlertControllerStyle.Alert)
        
        // On 'Yes' click.
        alert.addAction(UIAlertAction(title: NSLocalizedString(YESACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
          HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))

          // Code to call api method after certain delay.
          let triggerTime = (Int64(NSEC_PER_SEC) * 1)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            
            let chekedInExerciseClassObject: ExerciseClass = self.userCheckInScheduleClassArray[checkedInClassIndex]
            self.executeInsertCheckInForExerciseSiteClassby(exerciseClassObject, whenAlreadyCheckedIn: chekedInExerciseClassObject)
          })
          
        }))
        
        // On 'No' click.
        alert.addAction(UIAlertAction(title: NSLocalizedString(NOACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
      }
      else{
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))

        // Code to call api method after certain delay.
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
          
          var setCheckInSiteClassInputField = [String: String]()
          setCheckInSiteClassInputField = self.prepareRequestParamForInserCheckInApiBy(exerciseClassObject)
          self.executeInsertClassCheckInApiWith(setCheckInSiteClassInputField, For: exerciseClassObject, afterCompletion: { (completionFlag: Bool) -> (Void) in
            
            HUD.hide(animated: true)
          })
          
        })
      }
    }
    else{
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))
      
      // Code to call api method after certain delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        
        var deleteCheckInSiteClassInputField = [String: String]()
        deleteCheckInSiteClassInputField["checkinid"] = exerciseClassObject.checkedId! as String
        
        self.executeDeleteClassCheckInApiWith(deleteCheckInSiteClassInputField, For: exerciseClassObject, afterCompletion: { (completionFlag: Bool) -> (Void) in
          
          HUD.hide(animated: true)
        })
        
      })

    }
  }
  
  // MARK:  executeInsertCheckInForExerciseSiteClassby method.
  func executeInsertCheckInForExerciseSiteClassby(insertCheckInClass: ExerciseClass, whenAlreadyCheckedIn alreadyCheckedInClass: ExerciseClass) {
    
    var deleteCheckInSiteClassInputField = [String: String]()
    deleteCheckInSiteClassInputField["checkinid"] = alreadyCheckedInClass.checkedId! as String
    self.executeDeleteClassCheckInApiWith(deleteCheckInSiteClassInputField, For: alreadyCheckedInClass, afterCompletion: { (completionFlag: Bool) -> (Void) in
      
      if completionFlag == true{
        
        var setCheckInSiteClassInputField = [String: String]()
        setCheckInSiteClassInputField = self.prepareRequestParamForInserCheckInApiBy(insertCheckInClass)
        self.executeInsertClassCheckInApiWith(setCheckInSiteClassInputField, For: insertCheckInClass, afterCompletion: { (completionFlag: Bool) -> (Void) in
          
          HUD.hide(animated: true)
        })
        
      }
      else{
        HUD.hide(animated: true)
      }
      
    })
  }
  
  
  
  
  
  // MARK:  executeInsertClassCheckInApiWith method.
  func executeInsertClassCheckInApiWith(inputParam: [String: String], For exerciseClass: ExerciseClass, afterCompletion completionHandler:InsertCheckInCompletionHandler) {
    var apiFlag = false
    var title = ""
    var message = ""
    
    // Code to execute the SiteClasses api endpoint from ExerciseClassService class method markUserCheckInScheduleClassBy to mark SiteClass of Checkin.
    CheckInService.markUserCheckInScheduleClassBy(inputParam, completion: { (apiStatus, response) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
        exerciseClass.userCheckIn = true
        exerciseClass.checkedId = response as? String
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        apiFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(response as! NSData)
        exerciseClass.userCheckIn = false
      }
      else{ // For Network Error.
        apiFlag = false
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
        exerciseClass.userCheckIn = false
      }
      
      // Code to upate UI in the Main thread when SiteClasses api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to notiFy tableview.
        self.tableViewCheckInClass.reloadData()
        
        if apiFlag == false{
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
        
        // Code to call completion block.
        completionHandler(apiFlag)
      }
    })
  }
  
  // MARK:  executeDeleteClassCheckInApiWith method.
  func executeDeleteClassCheckInApiWith(inputParam: [String: String], For exerciseClass: ExerciseClass, afterCompletion completionHandler:DeleteCheckInCompletionHandler) {
    var apiFlag = false

    // Code to execute the SiteClasses api endpoint from ExerciseClassService class method markUserCheckInScheduleClassBy to mark SiteClass of Checkin.
    CheckInService.deleteClassCheckedInBy(inputParam, completion: { (apiStatus, response) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
        exerciseClass.userCheckIn = false
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        apiFlag = false
        exerciseClass.userCheckIn = true
      }
      else{ // For Network Error.
        apiFlag = false
        exerciseClass.userCheckIn = true
      }
      
      // Code to upate UI in the Main thread when SiteClasses api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to notiFy tableview.
        self.tableViewCheckInClass.reloadData()
        
        // Code to call completion block.
        completionHandler(apiFlag)
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
  
  // MARK:  Memory management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}


/*
 * Extension of MVPMyMVPCheckInClassViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPCheckInClassViewController.
 */
// MARK:  Extension of MVPMyMVPCheckInClassViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPCheckInClassViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return userCheckInScheduleClassArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPCheckInTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPCHECKINTABLEVIEWCELL) as? MyMVPCheckInTableViewCell!)!
    
    let exerciseClassObject: ExerciseClass = userCheckInScheduleClassArray[indexPath.row]
    let classStartTime = ScheduleViewModel.getTimeStringFromDateString(exerciseClassObject.classStartTime!)
    let classEndTime = ScheduleViewModel.getTimeStringFromDateString(exerciseClassObject.classEndTime!)
    cell.labelClassDate.text = "\(classStartTime) - \(classEndTime)"
    
    let className = (exerciseClassObject.className! as String)
    let viewWidth = self.view.frame.size.width
    let labelWidth = ((viewWidth * 33) / 100) - 25
    let labelFont = cell.labelClassName.font as UIFont
    let truncatedClassName = SiteClubsViewModel.getSiteClubLocationTruncatedLabelStringFrom(className, font: labelFont, labelWidth: labelWidth)
    cell.labelClassName.text = truncatedClassName

    cell.buttonClassCheckIn.tag = indexPath.row
    if exerciseClassObject.userCheckIn == true{
      cell.buttonClassCheckIn.setBackgroundImage(UIImage(named: "checkedin"), forState: UIControlState.Normal)
    }
    else{
      cell.buttonClassCheckIn.setBackgroundImage(UIImage(named: "uncheckedin"), forState: UIControlState.Normal)
    }
    cell.buttonClassCheckIn.addTarget(self, action: #selector(MVPMyMVPCheckInClassViewController.markUserCheckInSiteClassBtnClicked(_:)), forControlEvents: .TouchUpInside)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewCheckInClass.reloadData()
  }
  
}


// MARK:  Extension of MVPMyMVPCheckInClassViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPCheckInClassViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    print("MVPMyMVPCheckInClassViewController announcementDelegate")
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

