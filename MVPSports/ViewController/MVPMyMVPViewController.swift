//
//  MVPMyMVPViewController.swift
//  MVPSports
//
//  Created by Chetu India on 17/08/16.
//

import UIKit
import PKHUD


class MVPMyMVPViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewMyMvp: UITableView!
  @IBOutlet weak var labelNoRewardsAvailableLabel: UILabel!
  
  // For Bar Chart View
  @IBOutlet weak var viewHealthPointBarChartView: UIView!
  @IBOutlet weak var viewHealthPointStatusView: UIView!
  @IBOutlet weak var labelTotalHealthPointEarnedTitle: UILabel!
  @IBOutlet weak var labelTotalHealthPointEarned: UILabel!
  @IBOutlet weak var labelUntilNextLevelRemainingPoint: UILabel!
  @IBOutlet weak var labelUntilNextLevelRemainingPointTitle: UILabel!
  @IBOutlet weak var labelBadgeCount: UILabel!
  
  @IBOutlet weak var labelLoggedUserName: UILabel!
  @IBOutlet weak var labelLoggedUserMemberType: UILabel!
  @IBOutlet weak var imageViewLoggedUserImageView: UIImageView!
  @IBOutlet weak var accountViewHeightConstraint: NSLayoutConstraint!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var arrayOfHealthPointLevelObjects = [[String: AnyObject]]()
  var arrayOfGraphYlabelValues = [Int]() // [100, 200, 300, 400, 600] //
  var arrayOfGraphEarnedPointYlabelValues =  [Int]() // [100, 120, 180, 220, 0] //
  var arrayOfGraphXlabelValues = [String]() // ["Level 1", "Level 2", "Level 3", "Level 4", "Level 5"] //
  
  var earnedPoint = 0
  var nextLevelPoint = 0
  var myMvpRewardsArray = [Reward]()
  var myMvpTableViewRewardsArray = [Reward]()

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

    labelNoRewardsAvailableLabel.text = NSLocalizedString(NOACTIVEREWARDSAILABLEMSG, comment: "")
    labelNoRewardsAvailableLabel.hidden = true

    // Code to mark log event on to flurry for MyMVP screen view.
    dispatch_async(dispatch_get_main_queue(), {
      FlurryManager.sharedInstance.setFlurryLogForScreenType(ViewScreensEnum.MyMVP)
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
   * preparedScreenDesign method is created to set all UI design element configuration with some property.
   */
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    /*
     * Code to Change the lable font size for the iPhone_5 device.
     */
    if DeviceType.IS_IPHONE_5 {
      labelTotalHealthPointEarnedTitle.font = TWELVESYSTEMLIGHTFONT
      labelUntilNextLevelRemainingPointTitle.font = TWELVESYSTEMLIGHTFONT
    }
    else if DeviceType.IS_IPHONE_6 {
    }
    else if DeviceType.IS_IPHONE_6P {
    }
    
    if DeviceType.IS_IPHONE_4_OR_LESS {
      accountViewHeightConstraint.constant = 195
    }
    else{
      accountViewHeightConstraint.constant = 215
    }

    
    // Code to set border and round rect to the Bar Chart Status View.
    viewHealthPointStatusView.layer.borderColor = BLACKCOLOR.CGColor
    viewHealthPointStatusView.layer.borderWidth = VALUEONEBORDERWIDTH
    viewHealthPointStatusView.layer.cornerRadius = VALUEFIVECORNERRADIUS
    
    // Code to set logged user name to lable value.
    let firstName = loggedUserDict["firstName"]! as String
    let labelWidth = self.view.frame.size.width - 150
    let labelFont = labelLoggedUserName.font as UIFont
    let truncatedFirstName = SiteClubsViewModel.getSiteClubLocationTruncatedLabelStringFrom(firstName, font: labelFont, labelWidth: labelWidth)
    labelLoggedUserName.text = truncatedFirstName
    
    if let memberShipDesc = loggedUserDict["memberShipDesc"] {
      labelLoggedUserMemberType.text = "\(memberShipDesc)"
    }
    else{
      labelLoggedUserMemberType.text = ""
    }

    
    let img = loggedUserDict["img"]! as String
    if img.characters.count > 0{
      let decodedData = NSData(base64EncodedString: img, options: NSDataBase64DecodingOptions(rawValue: 0))
      let decodedimage = UIImage(data: decodedData!)
      imageViewLoggedUserImageView.image = decodedimage! as UIImage
    }

    
    // Code to call method to prepare array of health point objects.
    self.prepareHealthPointChartGraphDataByEarnedPoint()
    
    myMvpTableViewRewardsArray = RewardViewModel.filterArrayOfRewardsWithType(RewardTypesOptionEnum.Active, And: myMvpRewardsArray)

    // Code to call notify method ot UITableView to reload data.
    self.tableViewMyMvp.reloadData()
    
    // Code to hide or show labelNoRewardsAvailableLabel based on Rewards array count.
    if myMvpTableViewRewardsArray.count > 0{
      labelNoRewardsAvailableLabel.hidden = true
    }
    else{
      labelNoRewardsAvailableLabel.hidden = false
    }
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
 
        // Code to re-set UI screen design.
        self.preparedScreenDesign()
      }
      
    })
  }
  
  
  
  
  
  /*
   * Method to prepare health point level bar chart graph x-y label from array of health point level.
   */
  // MARK:  prepareHealthPointChartGraphDataByEarnedPoint method.
  func prepareHealthPointChartGraphDataByEarnedPoint() {
    
    var optInViewDataDict = [String: AnyObject]()
    optInViewDataDict = BarChartViewModel.getOptInData()
    
    if optInViewDataDict.count > 0{
      if let optInStatusType = optInViewDataDict["optInStatus"] as? Int{
        
        if (optInStatusType == UserOptInStatusEnum.DefaultUpChart.hashValue) || (optInStatusType == UserOptInStatusEnum.HpChart.hashValue){
          if let yLabelValueArray = optInViewDataDict["yLabel"] as? [Int]{
            self.arrayOfGraphYlabelValues = yLabelValueArray
          }
          if let xLabelValueArray = optInViewDataDict["xLabel"] as? [String]{
            self.arrayOfGraphXlabelValues = xLabelValueArray
          }
          if let earnpoint = optInViewDataDict["earnedPoint"] as? Int{
            self.earnedPoint = earnpoint
          }
          
          if !self.arrayOfGraphYlabelValues.isEmpty && !self.arrayOfGraphXlabelValues.isEmpty{
            self.arrayOfGraphEarnedPointYlabelValues = BarChartViewModel.createArrayOfErnedPointArrayForPointLevelByEarnedLevel(self.arrayOfGraphYlabelValues, with: self.earnedPoint)
            self.nextLevelPoint = BarChartViewModel.getNextLevelPointOfErnedPointBy(self.arrayOfGraphYlabelValues, with: self.earnedPoint)
            
            // Code to call method to create HpChart.
            self.createBarChartGraphForHealthPoint()
          }
        }
        else if optInStatusType == UserOptInStatusEnum.OptInView.hashValue{
          // Code to create dafault array for the Default HpChart.
          self.prepareDefaultHpChartViewData()
          
          // Code to call method to create HpChart.
          self.createBarChartGraphForHealthPoint()
 
          // Code to call method to set OptInView.
          self.setOptInViewForType(optInStatusType, dataInfo: [String: String]())
        }
        else if optInStatusType == UserOptInStatusEnum.PunchCardSession.hashValue{
          // Code to create dafault array for the Default HpChart.
          self.prepareDefaultHpChartViewData()
          
          // Code to call method to create HpChart.
          self.createBarChartGraphForHealthPoint()
          
          // Code to call method to set OptInView.
          self.setOptInViewForType(optInStatusType, dataInfo: [String: String]())
        }
      }
    }
  }

  /*
   * Method to create Bar Chart Graph for the Health Point Level of logged user and by earned point.
   */
  // MARK:  createBarChartGraphForHealthPoint method.
  func createBarChartGraphForHealthPoint() {
    // Code to set the value to label of earned and next level.
    self.labelTotalHealthPointEarned.text = "\(self.earnedPoint)"
    self.labelUntilNextLevelRemainingPoint.text = "\(self.nextLevelPoint)"
    
    let chartFrameWidth = (self.view.frame.size.width / 2)
    let chartFrame = CGRectMake(0.0, 0.0, chartFrameWidth, 120)
    let chart = BarChartViewModel.createBarChartViewWithFrame(chartFrame) as SimpleBarChart
    chart.delegate = self
    chart.dataSource = self
    chart.incrementValue = 100.0//CGFloat(BarChartViewModel.getChartYlableIncrementValue(arrayOfGraphYlabelValues))
    chart.reloadData()
    
    viewHealthPointBarChartView.willRemoveSubview(chart)
    viewHealthPointBarChartView.addSubview(chart)
  }
  
  // MARK:  prepareDefaultHpChartViewData method.
  func prepareDefaultHpChartViewData() {
    self.arrayOfGraphYlabelValues = [100, 200, 400, 600]
    self.arrayOfGraphXlabelValues = ["Level 1", "Level 2", "Level 3", "Level 4"]
    self.arrayOfGraphEarnedPointYlabelValues = BarChartViewModel.createArrayOfErnedPointArrayForPointLevelByEarnedLevel(self.arrayOfGraphYlabelValues, with: 0)
    
    self.earnedPoint = 0
    self.nextLevelPoint = BarChartViewModel.getNextLevelPointOfErnedPointBy(self.arrayOfGraphYlabelValues, with: earnedPoint)
  }

  // MARK:  setOptInViewForType method.
  func setOptInViewForType(optInType: Int, dataInfo: [String: String]) {
    
  }
  
  
  
  
  
  
  
  // MARK:  :--- All Selector Target Methods ---:
  
  // MARK:  sendBtnClicked method.
  func sendBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let selectedSendRewardToFriendMail = myMvpRewardsArray[tagIndex] as Reward
    
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPRewardSendToFriendViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPREWARDSENDTOFRIENDVIEWCONTROLLER) as! MVPMyMVPRewardSendToFriendViewController
    mvpMyMVPRewardSendToFriendViewController.selectedSendRewardToFriendMail = selectedSendRewardToFriendMail
    self.navigationController?.pushViewController(mvpMyMVPRewardSendToFriendViewController, animated: true)
  }
  
  // MARK:  viewBtnClicked method.
  func viewBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let selectedSendRewardToFriendMail = myMvpRewardsArray[tagIndex] as Reward
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
  
  // MARK:  viewAllRewardBtnClicked method.
  @IBAction func viewAllRewardBtnClicked(sender:UIButton!) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPRewardsViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPREWARDSVIEWCONTROLLER) as! MVPMyMVPRewardsViewController
    self.navigationController?.pushViewController(mvpMyMVPRewardsViewController, animated: true)
  }

  // MARK:  viewAccountDetailBtnClicked method.
  @IBAction func viewAccountDetailBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToMyAccountViewControllerFrom(self)
  }

  // MARK:  viewAccountDetailBtnClicked method.
  @IBAction func viewConnectedAppsBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToConnectedAppsViewControllerFrom(self)
  }

  // MARK:  healthPointDetailBtnClicked method.
  @IBAction func healthPointDetailBtnClicked(sender:UIButton!) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let viewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPACCOUNTLINKSVIEWCONTROLLER) as! MVPMyMVPAccountLinksViewController
    viewController.accountLinkUrlString = healthPointPageURL
    self.navigationController?.pushViewController(viewController, animated: true)
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

  // MARK:  Memoey management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}


/*
 * Extension of MVPMyMVPViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPViewController.
 */
// MARK:  Extension of MVPMyMVPViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 35.0
  }
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    /*
     * Code to return number of rows for the My MVP Rewards based on device type to display in proper size.
     */
    if DeviceType.IS_IPHONE_5 {
      if myMvpTableViewRewardsArray.count > 1{
        return 1
      }
      else{
        return myMvpTableViewRewardsArray.count
      }
    }
    else if DeviceType.IS_IPHONE_6 {
      if myMvpTableViewRewardsArray.count > 4{
        return 4
      }
      else{
        return myMvpTableViewRewardsArray.count
      }
    }
    else if DeviceType.IS_IPHONE_6P {
      if myMvpTableViewRewardsArray.count > 6{
        return 6
      }
      else{
        return myMvpTableViewRewardsArray.count
      }
    }
    else{
      return myMvpTableViewRewardsArray.count
    }
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPRewardsTableViewCell = (tableViewMyMvp.dequeueReusableCellWithIdentifier(MYMVPREWARDSTABLEVIEWCELL) as? MyMVPRewardsTableViewCell!)!
    cell.buttonView.hidden = false
    cell.buttonSend.hidden = false
    
    let reward: Reward = myMvpTableViewRewardsArray[indexPath.row] as Reward
    let rewardName = reward.name! as String
    cell.labelRewardsDescription.text = rewardName
    
    cell.buttonView.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    cell.buttonView.layer.masksToBounds = true
    cell.buttonView.tag = indexPath.row
    cell.buttonView.addTarget(self, action: #selector(MVPMyMVPRewardsViewController.viewBtnClicked(_:)), forControlEvents: .TouchUpInside)

    cell.buttonSend.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    cell.buttonSend.layer.masksToBounds = true
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
    tableViewMyMvp.reloadData()
  }

}


/*
 * Extension of MVPMyMVPViewController to add SimpleBarChart prototcol SimpleBarChartDataSource and SimpleBarChartDelegate.
 * Override the protocol method to add BarChartGraph in MVPMyMVPViewController.
 */
// MARK:  Extension of MVPMyMVPViewController by SimpleBarChart DataSource & Delegates method.
extension MVPMyMVPViewController: SimpleBarChartDataSource, SimpleBarChartDelegate{
  
  func numberOfBarsInBarChart(barChart: SimpleBarChart!) -> UInt {
    return UInt(arrayOfGraphYlabelValues.count)
  }
  
  func barChart(barChart: SimpleBarChart!, valueForBarAtIndex index: UInt) -> CGFloat {
    return CGFloat(arrayOfGraphYlabelValues[Int(index)])
  }
  
  func barChart(barChart: SimpleBarChart!, valueForFilledBarAtIndex index: UInt) -> CGFloat {
    return CGFloat(arrayOfGraphEarnedPointYlabelValues[Int(index)])
  }
  
  
  func barChart(barChart: SimpleBarChart!, textForBarAtIndex index: UInt) -> String! {
    return "\(arrayOfGraphYlabelValues[Int(index)])"
  }
  
  func barChart(barChart: SimpleBarChart!, textForFilledBarAtIndex index: UInt) -> String! {
    return "\(arrayOfGraphEarnedPointYlabelValues[Int(index)])"
  }
  
  func barChart(barChart: SimpleBarChart!, xLabelForBarAtIndex index: UInt) -> String! {
    return arrayOfGraphXlabelValues[Int(index)]
  }
  
  func barChart(barChart: SimpleBarChart!, colorForBarAtIndex index: UInt) -> UIColor! {
    return LIGHTGRAYCOLOR
  }
  
}


// MARK:  Extension of MVPMyMVPViewController by DrawerTableViewDelegate method.
extension MVPMyMVPViewController: DrawerTableViewDelegate{
  
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


// MARK:  Extension of MVPMyMVPViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}

