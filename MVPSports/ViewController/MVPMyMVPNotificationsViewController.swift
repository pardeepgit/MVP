//
//  MVPMyMVPNotificationsViewController.swift
//  MVPSports
//
//  Created by Chetu India on 01/09/16.
//

import UIKit
import PKHUD


class MVPMyMVPNotificationsViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewMyMvpNotificationClubs: UITableView!
  @IBOutlet weak var labelNoClubsForNotifyAvailableLabel: UILabel!
  @IBOutlet weak var labelBadgeCount: UILabel!

  // MARK:  instance variables, constant decalaration and define with some values.
  var arrayOfNotificationClubsObject = [NotificationClub]()
  
  // For Drawer View.
  var dimView = UIView()
  var tableview = DrawerTableView()
  var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]

  
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    labelNoClubsForNotifyAvailableLabel.text = NSLocalizedString(NOCLUBSFORNOTIFYAVAILABLEMSG, comment: "")
    labelNoClubsForNotifyAvailableLabel.hidden = true
    
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
    RemoteNotificationObserverManager.sharedInstance.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      // Code to execute web api endpoint of GetClubToNotify to fetch all NotificationClubs of memeid.
      if arrayOfNotificationClubsObject.count == 0{
        // Code to show progress loader.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
        
        // Code to call api method after certain delay.
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
          self.fetchNotificationClubs()
        })
      }
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    // Code to hide or show labelNoClubsForNotifyAvailableLabel based on Notify Clubs array count.
    if arrayOfNotificationClubsObject.count > 0{
      
      // Code to reload the data of tableview to show exercise classes information in listview.
      tableViewMyMvpNotificationClubs.reloadData()
      labelNoClubsForNotifyAvailableLabel.hidden = true
    }
    else{
      labelNoClubsForNotifyAvailableLabel.hidden = false
    }
  }
  
  // MARK:  fetchNotificationClubs method.
  func fetchNotificationClubs() {
    /*
     * Code to initiate input param dictionary to fetch all rewards of memid.
     * Currently memid is static because login api is not working from client side to get the logged user information.
     */
    var inputField = [String: String]()
    let memberId = loggedUserDict["memberId"]! as String
    inputField["memberid"] = memberId
    
    // Code to execute the getNotificationClubBy api endpoint from NotificationService class method NotificationClub to fetch all NotificationClub of memberid.
    NotificationService.getNotificationClubBy(inputField, completion: { (responseStatus, arrayOfNotificationClubObject) -> () in
      if responseStatus == ApiResponseStatusEnum.Success{
        self.arrayOfNotificationClubsObject = arrayOfNotificationClubObject as! [NotificationClub]
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{
      }
      else if responseStatus == ApiResponseStatusEnum.NetworkError{
      }
      else if responseStatus == ApiResponseStatusEnum.ClientTokenExpiry{
      }

      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide loader.
        HUD.hide(animated: true)
        
        // Code to re-set UI screen design
        self.preparedScreenDesign()
      }
      
    })
  }

  
  
  
  // MARK:  notificationAlertBellBtnClicked method.
  @IBAction func notificationAlertBellBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
  
  // MARK:  homeButtonTapped method.
  @IBAction func homeButtonTapped(sender: UIButton){
    // Code navigae to the Root ViewController.
    NavigationViewManager.instance.navigateToRootViewControllerFrom(self)
  }

  
  
  
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    
    // Code to pop from current viewController to previous viewController from stack.
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  updateNotificationStatusBtnClicked method.
  func updateNotificationStatusBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let notificationClub = arrayOfNotificationClubsObject[tagIndex] as NotificationClub
    if notificationClub.isDefaultClub ==  true{
      notificationClub.isDefaultClub = false
    }
    else{
      notificationClub.isDefaultClub = true
    }

    // Code to show progress loader.
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))

    // Code to call api method after certain delay.
    let triggerTime = (Int64(NSEC_PER_SEC) * 1)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
      self.executeSetClubToNotifyApiServiceFor(notificationClub)
    })
  }
  
  // MARK:  executeSetClubToNotifyApiServiceFor method.
  func executeSetClubToNotifyApiServiceFor(notificationClub: NotificationClub) {
    
    var inputParam = [[String: AnyObject]]()
    inputParam = NotificationClubsViewModel.createInputArrayOfNotificationDictionaryOfNotificationClubArrayObjects(arrayOfNotificationClubsObject)
    
    var apiFlag = false
    var title = ""
    var message = ""
    
    // Code to execute setClubToNotify api method to mark notify club status.
    NotificationService.writeNotificationClubActivationStatus(inputParam, completion: { (responseStatus, responseData) -> () in
      
      if responseStatus == ApiResponseStatusEnum.Success{
        apiFlag = true
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{
        apiFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else if responseStatus == ApiResponseStatusEnum.NetworkError{
        apiFlag = false
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      else if responseStatus == ApiResponseStatusEnum.ClientTokenExpiry{
        apiFlag = false
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide loader with animated.
        HUD.hide(animated: true)
        
        if apiFlag == false{
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)

          if notificationClub.isDefaultClub ==  true{
            notificationClub.isDefaultClub = false
          }
          else{
            notificationClub.isDefaultClub = true
          }
        }

        // Code to notify table view for reload data.
        self.tableViewMyMvpNotificationClubs.reloadData()
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
 * Extension of MVPMyMVPNotificationsViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPNotificationsViewController.
 */
// MARK:  Extension of MVPMyMVPNotificationsViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPNotificationsViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return arrayOfNotificationClubsObject.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 70.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPNotificationClubsTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPNOTIFICATIONCLUBSTABLEVIEWCELL) as? MyMVPNotificationClubsTableViewCell!)!
    
    let notificationClub = arrayOfNotificationClubsObject[indexPath.row] as NotificationClub
    
    let clubName = notificationClub.clubName! as String
    let labelWidth = self.view.frame.size.width - 90
    let labelFont = cell.labelNotificationClubNameState.font as UIFont
    let truncatedClubName = SiteClubsViewModel.getSiteClubLocationTruncatedLabelStringFrom(clubName, font: labelFont, labelWidth: labelWidth)
    cell.labelNotificationClubNameState.text = truncatedClubName

    if notificationClub.isDefaultClub ==  true{
      cell.buttonNotificationClubActivation.setBackgroundImage(UIImage(named: "checkedin"), forState: UIControlState.Normal)
    }
    else{
      cell.buttonNotificationClubActivation.setBackgroundImage(UIImage(named: "uncheckedin"), forState: UIControlState.Normal)
    }
    cell.buttonNotificationClubActivation.tag = indexPath.row
    cell.buttonNotificationClubActivation.addTarget(self, action: #selector(MVPMyMVPNotificationsViewController.updateNotificationStatusBtnClicked(_:)), forControlEvents: .TouchUpInside)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewMyMvpNotificationClubs.reloadData()
  }
  
}


// MARK:  Extension of MVPMyMVPNotificationsViewController by DrawerTableViewDelegate method.
extension MVPMyMVPNotificationsViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    self.popDrawerView()
  }
}


// MARK:  Extension of MVPMyMVPNotificationsViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPNotificationsViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}

