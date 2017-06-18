//
//  MVPMyMVPRewardsViewController.swift
//  MVPSports
//
//  Created by Chetu India on 18/08/16.
//

import UIKit
import PKHUD


class MVPMyMVPRewardsViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewMyMvpRewards: UITableView!
  @IBOutlet weak var labelNoRewardsAvailableLabel: UILabel!
  @IBOutlet weak var buttonAllRewardType: UIButton!
  @IBOutlet weak var buttonActiveRewardType: UIButton!
  @IBOutlet weak var buttonUsedRewardType: UIButton!
  @IBOutlet weak var labelBadgeCount: UILabel!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var myMvpRewardsArray = [Reward]()
  var myMvpTableViewRewardsArray = [Reward]()
  var typesOfRewardsFilterEnum = RewardTypesOptionEnum.Active
  
  // For Drawer View.
  var dimView = UIView()
  var tableview = DrawerTableView()
  var loggedUserDict = UserViewModel.getUserDictFromUserDefaut()

  
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    labelNoRewardsAvailableLabel.text = NSLocalizedString(NOREWARDSAILABLEMSG, comment: "")
    labelNoRewardsAvailableLabel.hidden = true

    
    // Code to mark log event on to flurry for MyMVPRewards screen view.
    dispatch_async(dispatch_get_main_queue(), {
      FlurryManager.sharedInstance.setFlurryLogForScreenType(ViewScreensEnum.MyMVPRewards)
    })
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()

    /*
     * Code to check device is connected to internet connection or not.
     */
    if Reachability.isConnectedToNetwork() == true {
      /*
       * Code to validate myMvpRewardsArray have revards or not. If not in that case hit web api endpoint of GetRewards to fetch all rewards of memeid
       */
      if myMvpRewardsArray.count == 0{
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
        self.fetchMyMvpRewards()
      }
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
     * Code to check whether user staus is changecd in application from Send Reward to friend email.
     * According to the user status flag boolean value we need to update the view accordingally.
     */
    let userStatusFlag = UserViewModel.getUserStatus() as Bool
    if userStatusFlag == true{
      // Code to set user status in application to false.
      UserViewModel.setUserStatusInApplication(false)
      
      if Reachability.isConnectedToNetwork() == true {
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
        self.fetchMyMvpRewards()
      }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    RemoteNotificationObserverManager.sharedInstance.delegate = nil
  }

  
  
  /*
   * preparedScreenDesign is created to set all UI design element configuration with some property.
   */
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    // Code for HUD initialization.
    HUD.dimsBackground = false
    HUD.allowsInteraction = false
    
    self.typesOfRewardsFilterEnum = RewardTypesOptionEnum.Active
    // Code to set view of Reward filter button type.
    self.setViewOfRewardFilterButton()
  }
  
  
  // MARK:  fetchMyMvpRewards method.
  func fetchMyMvpRewards() {
    /*
     * Code to initiate input param dictionary to fetch all rewards of memid.
     * Currently memid is static because login api is not working from client side to get the logged user information.
     */
    var inputField = [String: String]()
    inputField["memid"] = self.loggedUserDict["memberId"]! as String
    inputField["RequestedDate"] = "1/1/2016"
    
    // Code to execute the GetRewards api endpoint from RewardService class method getMyMvpRewardBy to fetch all rewards of memid.
    RewardService.getMyMvpRewardBy(inputField, completion: { (responseStatus, arrayOfRewardsObject) -> () in
      
      if responseStatus == ApiResponseStatusEnum.Success{
        self.myMvpRewardsArray = arrayOfRewardsObject as! [Reward]
        self.myMvpTableViewRewardsArray = arrayOfRewardsObject as! [Reward]
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{
      }
      else if responseStatus == ApiResponseStatusEnum.ClientTokenExpiry{
      }
      else if responseStatus == ApiResponseStatusEnum.NetworkError{
      }

      
      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        HUD.hide(animated: true)

        // Code to update the UI for the list.
        self.preparedScreenDesign()
      }
      
    })
  }
  
  
  
  
  // MARK:  sendBtnClicked method.
  func sendBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let selectedSendRewardToFriendMail = myMvpTableViewRewardsArray[tagIndex] as Reward

    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
     let mvpMyMVPRewardSendToFriendViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPREWARDSENDTOFRIENDVIEWCONTROLLER) as! MVPMyMVPRewardSendToFriendViewController
    mvpMyMVPRewardSendToFriendViewController.selectedSendRewardToFriendMail = selectedSendRewardToFriendMail
    self.navigationController?.pushViewController(mvpMyMVPRewardSendToFriendViewController, animated: true)
  }
  
  // MARK:  viewBtnClicked method.
  func viewBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let selectedSendRewardToFriendMail = myMvpTableViewRewardsArray[tagIndex] as Reward
    let pdfUrl = selectedSendRewardToFriendMail.pdfUrl! as String
    
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPRewardPdfViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPREWARDPDFVIEWCONTROLLER) as! MVPMyMVPRewardPdfViewController
    mvpMyMVPRewardPdfViewController.pdfUrl = pdfUrl
    mvpMyMVPRewardPdfViewController.urlLoadType = LoadUrlType.Reward
    self.navigationController?.pushViewController(mvpMyMVPRewardPdfViewController, animated: true)
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

  
  // MARK:  rewardsFilterTypeButtonTapped method.
  @IBAction func rewardsFilterTypeButtonTapped(sender: UIButton){
    let tagIndex = sender.tag
    
    switch tagIndex {
    case 101: // For All
      typesOfRewardsFilterEnum = RewardTypesOptionEnum.All
      
    case 102: // For Active
      typesOfRewardsFilterEnum = RewardTypesOptionEnum.Active
      
    case 103: // For Used
      typesOfRewardsFilterEnum = RewardTypesOptionEnum.Used
      
    default:
      print("default")
    }
    
    // Code to set view of Reward filter button type.
    self.setViewOfRewardFilterButton()
  }
  
  // MARK:  setViewOfRewardFilterButton method.
  func setViewOfRewardFilterButton() {
    buttonAllRewardType.backgroundColor = UNSELECTREWARDFILTERBGCOLOR
    buttonActiveRewardType.backgroundColor = UNSELECTREWARDFILTERBGCOLOR
    buttonUsedRewardType.backgroundColor = UNSELECTREWARDFILTERBGCOLOR

    buttonAllRewardType.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    buttonActiveRewardType.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    buttonUsedRewardType.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    var noRewardLabelStatusMessage = ""
    
    switch typesOfRewardsFilterEnum {
    case RewardTypesOptionEnum.All:
      buttonAllRewardType.backgroundColor = WHITECOLOR
      buttonAllRewardType.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)

      myMvpTableViewRewardsArray = myMvpRewardsArray
      noRewardLabelStatusMessage = NSLocalizedString(NOREWARDSAILABLEMSG, comment: "")

    case RewardTypesOptionEnum.Active:
      buttonActiveRewardType.backgroundColor = WHITECOLOR
      buttonActiveRewardType.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)

      myMvpTableViewRewardsArray = RewardViewModel.filterArrayOfRewardsWithType(RewardTypesOptionEnum.Active, And: myMvpRewardsArray)
      noRewardLabelStatusMessage = NSLocalizedString(NOACTIVEREWARDSAILABLEMSG, comment: "")

    case RewardTypesOptionEnum.Used:
      buttonUsedRewardType.backgroundColor = WHITECOLOR
      buttonUsedRewardType.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)

      myMvpTableViewRewardsArray = RewardViewModel.filterArrayOfRewardsWithType(RewardTypesOptionEnum.Used, And: myMvpRewardsArray)
      noRewardLabelStatusMessage = NSLocalizedString(NOUSEDREWARDSAILABLEMSG, comment: "")
    }
    
    // Code to notify UItableView for reload list of rewards.
    tableViewMyMvpRewards.reloadData()
    
    // Code to hide or show labelNoRewardsAvailableLabel based on Rewards array count.
    if myMvpTableViewRewardsArray.count > 0{
      labelNoRewardsAvailableLabel.hidden = true
    }
    else{
      labelNoRewardsAvailableLabel.text = noRewardLabelStatusMessage
      labelNoRewardsAvailableLabel.hidden = false
    }
  }
  
  
  
  
  
  /*
   * drawerButtonTapped method to open drawer view.
   */
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
  
  /*
   * handleOuterViewWithDrawerTapGesture method to handle tap listener of dim view and drawer view extra portion click view.
   */
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
 * Extension of MVPMyMVPRewardsViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPRewardsViewController.
 */
// MARK:  Extension of MVPMyMVPRewardsViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPRewardsViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 40.0
  }
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return myMvpTableViewRewardsArray.count
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPRewardsTableViewCell = (tableViewMyMvpRewards.dequeueReusableCellWithIdentifier(MYMVPREWARDSTABLEVIEWCELL) as? MyMVPRewardsTableViewCell!)!
    cell.buttonView.hidden = false
    cell.buttonSend.hidden = false
    
    let reward: Reward = myMvpTableViewRewardsArray[indexPath.row] as Reward
    let rewardName = reward.name! as String
    cell.labelRewardsDescription.text = rewardName
    
    cell.buttonView.tag = indexPath.row
    cell.buttonView.addTarget(self, action: #selector(MVPMyMVPRewardsViewController.viewBtnClicked(_:)), forControlEvents: .TouchUpInside)
    
    cell.buttonSend.tag = indexPath.row
    if RewardViewModel.validateRewardSendStatus(reward){
      cell.buttonSend.backgroundColor = SentRewardStatusColor
      cell.buttonSend.setTitle("SENT", forState: UIControlState.Normal)
    }
    else{
      cell.buttonSend.backgroundColor = SendRewardStatusColor
      cell.buttonSend.setTitle("SEND", forState: UIControlState.Normal)
    }
    cell.buttonSend.addTarget(self, action: #selector(MVPMyMVPRewardsViewController.sendBtnClicked(_:)), forControlEvents: .TouchUpInside)
    
    let rewardStatus = reward.status! as String
    if rewardStatus != "valid"{
      cell.buttonSend.hidden = true
      cell.buttonView.hidden = true
      cell.labelRewardsUsedDate.hidden = false
      
      if let expireDate = reward.expirationDate{
        let rewardExpireDate = expireDate as String
        if rewardExpireDate.characters.count > 0{
          let rewardUsedToDateString = RewardViewModel.getRewardUsedToDateStringFrom(rewardExpireDate)
          cell.labelRewardsUsedDate.text = "Used on: \(rewardUsedToDateString)"
        }
        else{
          cell.labelRewardsUsedDate.text = "Used on: Not Available"
        }
      }
      else{
        cell.labelRewardsUsedDate.text = "Used on: Not Available"
      }
    }
    else{
      cell.buttonSend.hidden = false
      cell.buttonView.hidden = false
      cell.labelRewardsUsedDate.hidden = true
      
      if RewardViewModel.validateRewardForGuestPassTypeBy(reward) == true{
        cell.buttonSend.hidden = false
      }
      else{
        cell.buttonSend.hidden = true
      }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewMyMvpRewards.reloadData()
  }
  
}


// MARK:  Extension of MVPMyMVPRewardsViewController by DrawerTableViewDelegate method.
extension MVPMyMVPRewardsViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.MyHealthPoints{
      self.handleOuterViewWithDrawerTapGesture()
    }
    else{
      self.popDrawerView()
    }
  }

}

// MARK:  Extension of MVPMyMVPRewardsViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPRewardsViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}
