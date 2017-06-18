//
//  MVPMyMVPAnnouncementViewController.swift
//  MVPSports
//
//  Created by Chetu India on 02/12/16.
//

import UIKit
import PKHUD


class MVPMyMVPAnnouncementViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewNotifications: UITableView!
  @IBOutlet weak var labelNoNotificationsAvailable: UILabel!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var myAnnouncementNotifications = [[String: AnyObject]]()

  
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
    labelNoNotificationsAvailable.text = NSLocalizedString(NOANNOUNCEMENTSAILABLEMSG, comment: "")
    labelNoNotificationsAvailable.hidden = true
    
    
    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      // Code to show progress loader.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      
      // Code to call fetchUserAnnouncementNotifications method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        
        // Code to execute ZeroNotificationCount service method.
        self.markUserZeroNotificationCount()
      })
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    
    // Code to hide or show labelNoNotificationsAvailable based on Notifications array count.
    if myAnnouncementNotifications.count > 0{
      // Code to notify UITableView instance to reload data in listview
      self.tableViewNotifications.reloadData()

      labelNoNotificationsAvailable.hidden = true
    }
    else{
      labelNoNotificationsAvailable.hidden = false
    }
  }
  
  
  
  // MARK:  markUserZeroNotificationCount method.
  func markUserZeroNotificationCount() {
    let savedDeviceToken = NotificationAnnouncementViewModel.getDeviceTokenFromUserDefault()
    
    // Code to initiate input param dictionary to mark Zero Notification count.
    var inputField = [String: String]()
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memid = loggedUserDict["memberId"]! as String
    inputField["memid"] = memid
    inputField["MemRefreshToken"] = savedDeviceToken
    
    // Code to execute the ZeroNotificationCount api service to mark notification count to zero.
    NotificationAnnouncementService.saveZeroNotificationCount(inputField, completion: { (apiStatus, response) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        
        // Code to save deafult badge count 0 by erased all badge count from local userDefault.
        NotificationAnnouncementViewModel.setNotifyBadgeCountToUserDefaultBy(0)
        UIApplication.sharedApplication().applicationIconBadgeNumber  = 0
      }
      
      // Code to fetch announcement notifications.
      self.fetchUserAnnouncementNotifications()
    })
  }
  
  // MARK:  fetchUserAnnouncementNotifications method.
  func fetchUserAnnouncementNotifications() {
    // Code to initiate input param dictionary to fetch all Site Clubs of application.
    var inputField = [String: String]()
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memid = loggedUserDict["memberId"]! as String
    inputField["MemberId"] = memid // "562571"
    
    // Code to execute the GetClubNotification api endpoint from NotificationAnnouncementService class method getMyAnnouncementNotificationsBy to fetch all Notifications of user.
    NotificationAnnouncementService.getMyAnnouncementNotificationsBy(inputField, completion: { (apiStatus, arrayOfNotifications) -> () in
      
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        self.myAnnouncementNotifications.removeAll()
        self.myAnnouncementNotifications = arrayOfNotifications as! [[String: AnyObject]]
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
  
  
  
  

  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  homeButtonTapped method.
  @IBAction func homeButtonTapped(sender: UIButton){
    // Code navigae to the Root ViewController.
    NavigationViewManager.instance.navigateToRootViewControllerFrom(self)
  }
  
  // MARK:  navigateToAnnouncementSettingButtonTapped method.
  @IBAction func navigateToAnnouncementSettingButtonTapped(sender: UIButton){
    NavigationViewManager.instance.navigateToNotificationSettingViewControllerFrom(self)
  }

  
  
  // MARK:  deleteAnnouncementBtnClicked method.
  func deleteAnnouncementBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    
    let alert = UIAlertController(title: NSLocalizedString(ALERTTITLE, comment: ""), message: "Do you want to delete this announcement ?", preferredStyle: UIAlertControllerStyle.Alert)
    // On 'YES' click.
    alert.addAction(UIAlertAction(title: NSLocalizedString(YESACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
      
      // Code to show progress loader for deleting notification anouncement.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      
      // Code to call fetchUserCheckInScheduleExerciseClasses method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        
        self.executeDeleteAnnoucementApiServiceBy(tagIndex)
      })
    }))
    
    // On 'No' click.
    alert.addAction(UIAlertAction(title: NSLocalizedString(NOACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
    }))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK:  executeDeleteAnnoucementApiServiceBy method.
  func executeDeleteAnnoucementApiServiceBy(tagIndex: Int) {
    let notificationObject = myAnnouncementNotifications[tagIndex] as [String: AnyObject]
    let notificationIndex = notificationObject["NotificationIndex"] as! Int
    
    // Code to initiate input param dictionary to Delete Notification individual announcement.
    var inputField = [String: String]()
    
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memid = loggedUserDict["memberId"]! as String
    
    inputField["memid"] = memid
    inputField["NotificationIndex"] = "\(notificationIndex)"
    
    // Code to execute the DeleteIndivualNotification api endpoint from NotificationAnnouncementService class method deleteNotificationAnnouncementBy to delete Notification object from announcemtnId.
    NotificationAnnouncementService.deleteNotificationAnnouncementBy(inputField, completion: { (apiStatus, responseData) -> () in
      
      var apiFlag = false
      var title = ""
      var message = ""
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        apiFlag = false
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else{ // For Network error.
        apiFlag = false
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        
        // Code to hide progress loader.
        HUD.hide(animated: true)

        if apiFlag == true{
          self.myAnnouncementNotifications.removeAtIndex(tagIndex)
          self.tableViewNotifications.reloadData()
        }
        else{
          // Code to show alert dialogue box.
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
    })
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
 * Extension of MVPMyMVPAnnouncementViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPAnnouncementViewController.
 */
// MARK:  Extension of MVPMyMVPAnnouncementViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPAnnouncementViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return myAnnouncementNotifications.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPNotificationsTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPNOTIFICATIONSTABLEVIEWCELL) as? MyMVPNotificationsTableViewCell!)!
    
    let notificationObject = myAnnouncementNotifications[indexPath.row] as [String: AnyObject]
    let notificationDesc = notificationObject["notification"] as! String
    cell.labelNotificationDescription.text = notificationDesc
    
    cell.buttonDeleteAnnouncement.tag = indexPath.row
    cell.buttonDeleteAnnouncement.addTarget(self, action: #selector(MVPMyMVPAnnouncementViewController.deleteAnnouncementBtnClicked(_:)), forControlEvents: .TouchUpInside)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewNotifications.reloadData()
  }
  
}


// MARK:  Extension of MVPMyMVPAnnouncementViewController by DrawerTableViewDelegate method.
extension MVPMyMVPAnnouncementViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.Announcements{
      self.handleOuterViewWithDrawerTapGesture()
    }
    else{
      self.popDrawerView()
    }
  }
}

