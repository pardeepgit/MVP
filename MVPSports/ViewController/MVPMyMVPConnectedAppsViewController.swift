//
//  MVPMyMVPConnectedAppsViewController.swift
//  MVPSports
//
//  Created by Chetu India on 01/09/16.
//

import UIKit
import PKHUD


class MVPMyMVPConnectedAppsViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewMyMvpConnectedApps: UITableView!
  @IBOutlet weak var labelNoAppsAvailableLabel: UILabel!
  @IBOutlet weak var labelBadgeCount: UILabel!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var arrayOfConnectedAppsObject = [ConnectedApp]()
  var appType: ConnectedAppTypesEnum = ConnectedAppTypesEnum.Polar
  var access_token = ""
  var refresh_token = ""
  var userId = ""
  
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
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()
    
    /*
     * Code to check device is connected to internet connection or not.
     */
    if Reachability.isConnectedToNetwork() == true {
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      self.fetchConnectedApps()
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

    
    /*
     * Code to check whether Connected App status is changecd in application.
     * According to the Connected App status flag boolean value we need to update the view accordingally.
     */
    let connectedAppStatusFlag = UserViewModel.getConnectedAppsStatus() as Bool
    if connectedAppStatusFlag == true{
      
      // Code to set Connected Apps status in application to false.
      UserViewModel.setConnectedAppsStatusInApplication(false)
      
      // Code to get the connectedApps credentials from local saved .plist by userDefault.
      let connectedAppCredentials = UserViewModel.getConnectedAppCredentials() as [String: AnyObject]
      if connectedAppCredentials.count > 0{
        
        let connectedAppCredentialsTupple = self.prepareSaveDeviceSettingApiServiceRequestParamBy(connectedAppCredentials)
        let connectedAppCredentialsRequestParam = connectedAppCredentialsTupple.0 as [String: String]
        let connectedAppId = connectedAppCredentialsTupple.1 as Int

        // Code to update the ConnectedApps credentials to the server.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))
        self.executeSaveDeviceSettingApiWith(connectedAppCredentialsRequestParam, forApp: connectedAppId)
      }
    }
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    // Code to prepare static array for the connected apps.
    self.prepareDefaultConnectedAppsInfoData()
    
    // Code to reload the data of tableview to show account information in listview.
    tableViewMyMvpConnectedApps.reloadData()
    
    // Code to hide or show labelNoAppsAvailableLabel based on connected apps array count.
    if arrayOfConnectedAppsObject.count > 0{
      labelNoAppsAvailableLabel.hidden = true
    }
    else{
      labelNoAppsAvailableLabel.hidden = false
    }
  }
  
  
  
  
  // MARK:  prepareDefaultConnectedAppsInfoData method.
  func  prepareDefaultConnectedAppsInfoData() {
    let fitbitConnectedApp = ConnectedApp()
    fitbitConnectedApp.appName = "FitBit"
    fitbitConnectedApp.appid = 1

    let polarConnectedApp = ConnectedApp()
    polarConnectedApp.appName = "Polar"
    polarConnectedApp.appid = 2

    let underArmerConnectedApp = ConnectedApp()
    underArmerConnectedApp.appName = "Under Armour" 
    underArmerConnectedApp.appid = 5
    
    arrayOfConnectedAppsObject.append(fitbitConnectedApp)
    arrayOfConnectedAppsObject.append(polarConnectedApp)
    arrayOfConnectedAppsObject.append(underArmerConnectedApp)
  }
  
  // MARK:  fetchConnectedApps method.
  func fetchConnectedApps() {
    
    // Code to initiate input param dictionary to fetch authentication status of all Connected Apps by logged user memid.
    var inputField = [String: String]()
    let memberId = loggedUserDict["memberId"]! as String
    inputField["memid"] = memberId
    
    // Code to execute the GetConnectedAppsBy api endpoint from NotificationService class method ConectedApp to fetch all NotificationClub of memberid.
    NotificationService.getConnectedAppsBy(inputField, completion: { (responseStatus, arrayOfConnectedApps) -> () in

      if responseStatus == ApiResponseStatusEnum.Success{
        self.updateConnectedAppsListByApiRespnseConnectedApps(arrayOfConnectedApps as! [ConnectedApp])
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{
      }
      else if responseStatus == ApiResponseStatusEnum.NetworkError{
      }
      else if responseStatus == ApiResponseStatusEnum.ClientTokenExpiry{
      }
      else{
      }
      
      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        HUD.hide(animated: true)
        
        // Code to notify UITableView listview.
        self.tableViewMyMvpConnectedApps.reloadData()
      }

    })
  }
  
  // MARK:  updateConnectedAppsListByApiRespnseConnectedApps method.
  func updateConnectedAppsListByApiRespnseConnectedApps(arrayOfConnectedApps: [ConnectedApp]) {
    if arrayOfConnectedApps.count > 0{
      for index in 0..<arrayOfConnectedAppsObject.count {
        let connectedApp = arrayOfConnectedAppsObject[index] as ConnectedApp
        let appId = connectedApp.appid! as Int

        for index in 0..<arrayOfConnectedApps.count {
          let connectedAppObject = arrayOfConnectedApps[index]
          let connectedAppIdValue = connectedAppObject.appid
          
          if appId == connectedAppIdValue{
            connectedApp.tokenAuthenticity = connectedAppObject.tokenAuthenticity
            connectedApp.userid = connectedAppObject.userid
            connectedApp.memAccessToken = connectedAppObject.memAccessToken
            connectedApp.memRefreshToken = connectedAppObject.memRefreshToken
            break
          }
        }
      
      }
    }
  }
  
  

  
  // MARK:  connectedAppsHelpBtnClicked method.
  @IBAction func connectedAppsHelpBtnClicked(sender:UIButton!) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let viewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPACCOUNTLINKSVIEWCONTROLLER) as! MVPMyMVPAccountLinksViewController
    viewController.accountLinkUrlString = connectedAppsHelpPageURL
    self.navigationController?.pushViewController(viewController, animated: true)
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
  
  // MARK:  buttonLinkConnectedAppTapped method.
  func buttonLinkConnectedAppTapped(sender: UIButton){
    let tagIndex = sender.tag
    let connectedAppInfo = arrayOfConnectedAppsObject[tagIndex] as ConnectedApp
    
    // Code to get connection app id string value.
    let appId = connectedAppInfo.appid! as Int

    // Code to get connection app status whether it is connected or not.
    let status = connectedAppInfo.tokenAuthenticity! as Int
    if status == 0{ // Linked to ConnectedApp by AppId
      if appId != 0{
        // Code to navigate to the web view auth controller for Fitbit and UnderArmour.
        let authViewController = WebViewAuthViewController(nibName: WEBVIEWAUTHVIEWCONTROLLER, bundle: nil)
        authViewController.connectionAppId = appId
        self.presentViewController(authViewController, animated:true, completion:nil)
      }
    }
    else if status == -1{ // Linked again to manual un linked connected app.
      
      // Code to update the ConnectedApps credentials to the server.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))
      
      let inputParam = self.prepareSaveDeviceSettingApiServiceRequestFor(connectedAppInfo)
      self.executeSaveDeviceSettingApiWith(inputParam, forApp: appId)
    }
    else{ // UnLinked to ConnectedApp by AppId
      
      let appName = connectedAppInfo.appName! as String
      var messageString = NSLocalizedString(UNLINKMESSAGE, comment: "")
      messageString = "\(messageString) \(appName)"
      
      let alert = UIAlertController(title: "", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
      // On 'Yes' click.
      alert.addAction(UIAlertAction(title: NSLocalizedString(YESACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
        
        // Code to update the ConnectedApps credentials to the server.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))
        
        let inputParam = self.prepareSaveDeviceSettingApiServiceRequestFor(connectedAppInfo)
        self.executeSaveDeviceSettingApiWith(inputParam, forApp: appId)
      }))
      
      // On 'No' click.
      alert.addAction(UIAlertAction(title: NSLocalizedString(NOACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
      }))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  
  
  
  // MARK:  prepareSaveDeviceSettingApiServiceRequestParamBy method.
  func prepareSaveDeviceSettingApiServiceRequestParamBy(connectedAppCredentials: [String: AnyObject]) -> ([String: String], Int) {
    var inputParam = [String: String]()
    var appId = 0
    var userid = ""
    var memAccessToken = ""
    var memRefreshToken = ""

    if let appid = connectedAppCredentials["ConnectedAppId"] as? Int{
      appId = appid
    }

    if let crednetialDict = connectedAppCredentials["Credentials"] as? [String: String]{
      if let userId = crednetialDict["userid"]{
        userid = userId
      }
      if let MemAccessToken = crednetialDict["MemAccessToken"]{
        memAccessToken = MemAccessToken
      }
      if let MemRefreshToken = crednetialDict["MemRefreshToken"]{
        memRefreshToken = MemRefreshToken
      }
    }
 
    // Code to prepare request dict for ConnectedApp credentials.
    let loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    inputParam["memid"] = memberId
    inputParam["IsActive"] = "true"
    inputParam["IsNewUser"] = "true"
    inputParam["TokenAuthenticity"] = "10"

    inputParam["AppId"] = "\(appId)"
    inputParam["userid"] = userid
    inputParam["MemAccessToken"] = memAccessToken
    inputParam["MemRefreshToken"] = memRefreshToken
    
    return (inputParam, appId)
  }
  
  // MARK:  prepareSaveDeviceSettingApiServiceRequestFor method.
  func prepareSaveDeviceSettingApiServiceRequestFor(connectedApp: ConnectedApp) -> [String: String] {
    var inputParam = [String: String]()
    
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    inputParam["memid"] = memberId
    inputParam["IsActive"] = "true"
    inputParam["IsNewUser"] = "true"
    
    let tokenAuthenticityStatus = connectedApp.tokenAuthenticity! as Int
    let appid = connectedApp.appid! as Int
    let userid = connectedApp.userid! as String
    let memAccessToken = connectedApp.memAccessToken! as String
    let memRefreshToken = connectedApp.memRefreshToken! as String

    if tokenAuthenticityStatus == 1{
      inputParam["TokenAuthenticity"] = "-1"
    }
    else if tokenAuthenticityStatus == -1{
      inputParam["TokenAuthenticity"] = "10"
    }
    else{
      inputParam["TokenAuthenticity"] = "1"
    }
    
    inputParam["AppId"] = "\(appid)"
    inputParam["userid"] = userid
    inputParam["MemAccessToken"] = memAccessToken
    inputParam["MemRefreshToken"] = memRefreshToken

    return inputParam
  }
  
  
  
  // MARK:  executeSaveDeviceSettingApiWith method.
  func executeSaveDeviceSettingApiWith(inputParam: [String: String], forApp appId: Int) {
    var apiFlag = false
    var title = ""
    var message = ""
    
    // Code to execute the saveDeviceSettingBy api endpoint from NotificationService class method SaveDeviceSetting to save device setting for app.
    NotificationService.saveDeviceSettingBy(inputParam, completion: { (responseStatus, responseData) -> () in
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
        title = ""
        message = ""
      }
      
      if apiFlag ==  true{
        dispatch_async(dispatch_get_main_queue()) {
          // Code to hide progress hud.
          HUD.hide(animated: true)
          
          // Code to update the ConnectedApp status of appId by tokenAuthenticity status flag.
          self.updateSaveDeviceSettingStatusOfConnectedAppBy(appId)
        }
      }
      else{
        dispatch_async(dispatch_get_main_queue()) {
          // Code to hide progress hud.
          HUD.hide(animated: true)
          
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
  }
  
  // MARK:  updateSaveDeviceSettingStatusOfConnectedAppBy method.
  func updateSaveDeviceSettingStatusOfConnectedAppBy(connectedAppId: Int) {
    for index in 0..<arrayOfConnectedAppsObject.count {
      let connectedApp = arrayOfConnectedAppsObject[index] as ConnectedApp
      let appId = connectedApp.appid! as Int
      let tokenAuthenticity = connectedApp.tokenAuthenticity! as Int

      if appId == connectedAppId{
        if tokenAuthenticity == -1 || tokenAuthenticity == 0{
          connectedApp.tokenAuthenticity = 1
        }
        else{
          connectedApp.tokenAuthenticity = -1
        }
        
        break
      }
    }
    
    // Code to notify UITableView for the Connected App Link/UnLink status.
    self.tableViewMyMvpConnectedApps.reloadData()
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
 * Extension of MVPMyMVPConnectedAppsViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPConnectedAppsViewController.
 */
// MARK:  Extension of MVPMyMVPConnectedAppsViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPConnectedAppsViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return arrayOfConnectedAppsObject.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 70.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPConnectedAppsTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPCONNECTEDAPPSTABLEVIEWCELL) as? MyMVPConnectedAppsTableViewCell!)!
    
    let connectedAppInfo = arrayOfConnectedAppsObject[indexPath.row] as ConnectedApp
    
    let appid = "\(connectedAppInfo.appid! as Int)"
    cell.imageViewConnectedAppIcon.image = UIImage(named: appid)
    
    let connectedAppStatus = connectedAppInfo.tokenAuthenticity! as Int
    
    if connectedAppStatus > 0{ // App is connected
      cell.labelConnectedAppState.text = "Status: Active"
      cell.buttonLinkConnectedApp.setTitle("LINKED", forState: UIControlState.Normal)
    }
    else{ // App is not connected
      cell.labelConnectedAppState.text = "Status: Inactive"
      cell.buttonLinkConnectedApp.setTitle("LINK", forState: UIControlState.Normal)
    }
    
    cell.buttonLinkConnectedApp.tag = indexPath.row
    cell.buttonLinkConnectedApp.addTarget(self, action: #selector(MVPMyMVPConnectedAppsViewController.buttonLinkConnectedAppTapped(_:)), forControlEvents: .TouchUpInside)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewMyMvpConnectedApps.reloadData()
  }
  
}


// MARK:  Extension of MVPMyMVPConnectedAppsViewController by DrawerTableViewDelegate method.
extension MVPMyMVPConnectedAppsViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.ConnectedApps{
      self.handleOuterViewWithDrawerTapGesture()
    }
    else{
      self.popDrawerView()
    }
  }
}


/*
 * Extension of MVPMyMVPConnectedAppsViewController to add UITextField prototcol UITextFieldDelegate.
 * Override UITextFieldDelegate methods in MVPMyMVPConnectedAppsViewController to handle textfield action event and slector.
 */
// MARK:  UITextField Delegates methods
extension MVPMyMVPConnectedAppsViewController: UITextFieldDelegate{
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
    return true
  }
}


// MARK:  Extension of MVPMyMVPConnectedAppsViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPConnectedAppsViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}

