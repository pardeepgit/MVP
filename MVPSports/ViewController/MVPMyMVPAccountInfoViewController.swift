//
//  MVPMyMVPAccountInfoViewController.swift
//  MVPSports
//
//  Created by Chetu India on 31/08/16.
//

import UIKit
import PKHUD


class MVPMyMVPAccountInfoViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewMyMvpAccountInfo: UITableView!
  @IBOutlet weak var labelBadgeCount: UILabel!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var arrayOfAccountInfoSectionObject = [String]()
  var dictionaryOfAccountInfoArrayForSectionObject = [String: [String]]()
  var dictionaryOfAccountLinksUrls = [String: String]()

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
    
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
    RemoteNotificationObserverManager.sharedInstance.delegate = self

    // Call method to set UI of screen.
    self.preparedScreenDesign()
    
    // Code to mark log event on to flurry for MyMVPAccountSetting screen view.
    dispatch_async(dispatch_get_main_queue(), {
      FlurryManager.sharedInstance.setFlurryLogForScreenType(ViewScreensEnum.MyMVPAccountSetting)
    })
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      /*
       * Code to validate arrayOfAccountLinksUrls have account links or not. If not in that case hit web api endpoint of fetchMyAccountLinks to fetch all account links of memeid
       */
      if dictionaryOfAccountLinksUrls.count == 0{
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
        self.fetchMyAccountLinks()
      }
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
    
  }
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    // Code to call method for preparing the account info resource urls.
    self.prepareStaticAccountInfoData()
  }
  
  // MARK:  prepareStaticAccountInfoData method.
  func  prepareStaticAccountInfoData() {
    // Code to prepare the AccountInfo objects array.
    arrayOfAccountInfoSectionObject = ["Account Information", "Billing","History","Connected Apps","Announcements"]

    let accountInfoArray = ["Summary","Contact Information","Change Username/Password"]
    dictionaryOfAccountInfoArrayForSectionObject["Account Information"] = accountInfoArray
    
    let billingInfoArray = ["Statements/Transaction","Update Credit Card on File"]
    dictionaryOfAccountInfoArrayForSectionObject["Billing"] = billingInfoArray

    let history = ["View History"]
    dictionaryOfAccountInfoArrayForSectionObject["History"] = history

    let connectedApps = ["Connected Apps / Accounts"]
    dictionaryOfAccountInfoArrayForSectionObject["Connected Apps"] = connectedApps

    let notificationSettings = ["Settings"]
    dictionaryOfAccountInfoArrayForSectionObject["Announcements"] = notificationSettings

    // Code to reload the data of tableview to show account information in listview.
    tableViewMyMvpAccountInfo.reloadData()
  }

  
  // MARK:  fetchMyAccountLinks method.
  func fetchMyAccountLinks() {
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut()
    let memid = loggedUserDict["memberId"]! as String

    /*
     * Code to initiate input param dictionary to fetch all rewards of memid.
     * Currently memid is static because login api is not working from client side to get the logged user information.
     */
    var inputField = [String: String]()
    inputField["memid"] = memid
    
    // Code to execute the getMyAccountLinksBy api endpoint from RewardService class method getMyMvpRewardBy to fetch all rewards of memid.
    AccountService.getMyAccountLinksBy(inputField, completion: { (responseStatus, accountLinksDict) -> () in
      
      if responseStatus == ApiResponseStatusEnum.Success{
        self.dictionaryOfAccountLinksUrls = accountLinksDict
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{
      }
      else if responseStatus == ApiResponseStatusEnum.NetworkError{
      }
      else if responseStatus == ApiResponseStatusEnum.ClientTokenExpiry{
      }
      else{
      }
      
      // Code to upate UI in the Main thread when GetAccountds api response.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide progress loader.
        HUD.hide(animated: true)
        
        // Code to notify UITableView to refresh the list for the records.
        self.tableViewMyMvpAccountInfo.reloadData()
      }
    })
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
 * Extension of MVPMyMVPAccountInfoViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPAccountInfoViewController.
 */
// MARK:  Extension of MVPMyMVPScheduleViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPAccountInfoViewController: UITableViewDataSource, UITableViewDelegate{
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return arrayOfAccountInfoSectionObject.count
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60.0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let viewForTableViewCellSection = UIView()
    viewForTableViewCellSection.backgroundColor = WHITECOLOR
    
    let viewForHeaderTableViewCellSectionSeparator = UIView()
    viewForHeaderTableViewCellSectionSeparator.frame = CGRectMake(30, 0, tableViewMyMvpAccountInfo.frame.size.width-60, 1)
    viewForHeaderTableViewCellSectionSeparator.backgroundColor = UNSELECTREWARDFILTERBGCOLOR

    let labelOfSectionAccountTitle = UILabel()
    labelOfSectionAccountTitle.frame = CGRectMake(0, 0, tableViewMyMvpAccountInfo.frame.size.width, 60)
    labelOfSectionAccountTitle.backgroundColor = CLEARCOLOR
    labelOfSectionAccountTitle.textColor = BLACKCOLOR
    labelOfSectionAccountTitle.textAlignment = NSTextAlignment.Center
    let sectionTitle = arrayOfAccountInfoSectionObject[section] as String
    labelOfSectionAccountTitle.text = sectionTitle.uppercaseString
    labelOfSectionAccountTitle.font = UIFont.boldSystemFontOfSize(17.0)

    // viewForTableViewCellSection.addSubview(viewForHeaderTableViewCellSectionSeparator)
    viewForTableViewCellSection.addSubview(labelOfSectionAccountTitle)
    return viewForTableViewCellSection
  }
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return dictionaryOfAccountInfoArrayForSectionObject[arrayOfAccountInfoSectionObject[section] as String]!.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 40.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPAccountInfoTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPACCOUNTINFOTABLEVIEWCELL) as? MyMVPAccountInfoTableViewCell!)!
    
    let accountInfoArrayForSection: [String] = dictionaryOfAccountInfoArrayForSectionObject[arrayOfAccountInfoSectionObject[indexPath.section] as String]!
    let accountTitleText = accountInfoArrayForSection[indexPath.row] as String
    cell.labelAccountTitle.text = accountTitleText
    
    let labelFont = cell.labelAccountTitle.font
    var labelWidth = UtilManager.sharedInstance.widthForLabel(accountTitleText, font: labelFont, height: 40.0)
    labelWidth = labelWidth + 10
    
    let bottomLineXposition = (self.view.frame.size.width - labelWidth) / 2

    // Code to upate UI in the Main thread when GetAccountds api response.
    dispatch_async(dispatch_get_main_queue()) {
      cell.viewBottomLine.frame = CGRectMake(bottomLineXposition, 39, labelWidth, 1)
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewMyMvpAccountInfo.reloadData()
    let accountInfoArrayForSection: [String] = dictionaryOfAccountInfoArrayForSectionObject[arrayOfAccountInfoSectionObject[indexPath.section] as String]!
    let accountInfoType = accountInfoArrayForSection[indexPath.row] as String
    
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let viewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPACCOUNTLINKSVIEWCONTROLLER) as! MVPMyMVPAccountLinksViewController
    
    switch accountInfoType {
    case AccountInfoTypeEnumeration.AccountSummary.rawValue:
      if let AccountSummaryUrl = self.dictionaryOfAccountLinksUrls["AccountSummary"]{
        viewController.accountLinkUrlString = AccountSummaryUrl as String
      }
      else{
        viewController.accountLinkUrlString = ""
      }
      self.navigationController?.pushViewController(viewController, animated: true)
      break

    case AccountInfoTypeEnumeration.ContactInformation.rawValue:
      if let ContactInfoUrl = self.dictionaryOfAccountLinksUrls["ContactInfo"]{
        viewController.accountLinkUrlString = ContactInfoUrl as String
      }
      else{
        viewController.accountLinkUrlString = ""
      }
      self.navigationController?.pushViewController(viewController, animated: true)
      break

    case AccountInfoTypeEnumeration.ChangeUsernamePassword.rawValue:
      if let ChangeUserNamePasswordUrl = self.dictionaryOfAccountLinksUrls["ChangeUserNamePassword"]{
        viewController.accountLinkUrlString = ChangeUserNamePasswordUrl as String
      }
      else{
        viewController.accountLinkUrlString = ""
      }
      self.navigationController?.pushViewController(viewController, animated: true)
      break

    case AccountInfoTypeEnumeration.StatementsTransaction.rawValue:
      if let StatementsTransUrl = self.dictionaryOfAccountLinksUrls["StatementsTrans"]{
        viewController.accountLinkUrlString = StatementsTransUrl as String
      }
      else{
        viewController.accountLinkUrlString = ""
      }
      self.navigationController?.pushViewController(viewController, animated: true)
      break

    case AccountInfoTypeEnumeration.UpdateCreditCard.rawValue:
      if let UpdateCreditCardUrl = self.dictionaryOfAccountLinksUrls["UpdateCreditCard"]{
        viewController.accountLinkUrlString = UpdateCreditCardUrl as String
      }
      else{
        viewController.accountLinkUrlString = ""
      }
      self.navigationController?.pushViewController(viewController, animated: true)
      break

    case AccountInfoTypeEnumeration.ViewHistory.rawValue:
      if let ViewHistoryUrl = self.dictionaryOfAccountLinksUrls["ViewHistory"]{
        viewController.accountLinkUrlString = ViewHistoryUrl as String
      }
      else{
        viewController.accountLinkUrlString = ""
      }
      self.navigationController?.pushViewController(viewController, animated: true)
      break

    case AccountInfoTypeEnumeration.ConnectedAppsAccounts.rawValue:
      NavigationViewManager.instance.navigateToConnectedAppsViewControllerFrom(self)
      break

    case AccountInfoTypeEnumeration.Notifications.rawValue:
      NavigationViewManager.instance.navigateToNotificationSettingViewControllerFrom(self)
      break

    default:
      break
    }
  }
  
}


// MARK:  Extension of MVPMyMVPAccountInfoViewController by DrawerTableViewDelegate method.
extension MVPMyMVPAccountInfoViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.MyAccount{
      self.handleOuterViewWithDrawerTapGesture()
    }
    else{
      self.popDrawerView()
    }
  }
}

// MARK:  Extension of MVPMyMVPAccountInfoViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPAccountInfoViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}
