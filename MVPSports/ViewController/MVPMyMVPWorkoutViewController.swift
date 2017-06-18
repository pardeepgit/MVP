//
//  MVPMyMVPWorkoutViewController.swift
//  MVPSports
//
//  Created by Chetu India on 12/09/16.
//

import UIKit
import PKHUD


class MVPMyMVPWorkoutViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var viewHeaderView: UIView!
  @IBOutlet weak var labelHeaderTitle: UILabel!
  @IBOutlet weak var tableViewWorkoutJournal: UITableView!
  @IBOutlet weak var labelNoWorkoutJournalAvailableLabel: UILabel!

  @IBOutlet weak var viewCreateWorkout: UIView!
  @IBOutlet weak var buttonCreateWorkout: UIButton!
  @IBOutlet weak var buttonWorkout: UIButton!
  @IBOutlet weak var buttonJournal: UIButton!
  
  @IBOutlet weak var viewFilterWorkout: UIView!
  @IBOutlet weak var labelAll: UILabel!
  @IBOutlet weak var labelAnnualy: UILabel!
  @IBOutlet weak var labelMonthly: UILabel!
  @IBOutlet weak var labelWeekly: UILabel!
  
  @IBOutlet weak var viewFilterWorkoutHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var viewCreateWorkoutHeightConstraint: NSLayoutConstraint!

  
  // MARK:  instance variables, constant decalaration and define with infer type with default values.
  var userActivityType: UserActivityTypeEnumeration = UserActivityTypeEnumeration.Workout
  var workoutFilterOptionType = WorkoutFilterOptionTypeEnumeration.All
  var dimView = UIView()
  var tableview = DrawerTableView()
  
  var myMvpWorkoutsArray = [Workout]()
  var editWorkout = Workout()
  var editCellIndex = 0
  
  
  /*
   * ConnectedAppsTokenAuthenticity observer handler methods.
   */
  // MARK:  connectedAppsTokenAuthenticityObserverBy method.
  func connectedAppsTokenAuthenticityObserverBy(notification: NSNotification) {
    if notification.name == "ConnectedAppsTokenAuthenticity"{
      if let respDict = notification.object as? [String: AnyObject]{
        var tokenAuthenticityFlag = false
        var tokenAuthenticityMsg = ""
        
        if let flag = respDict["status"] as? Bool{
          tokenAuthenticityFlag = flag
        }
        if let msg = respDict["msg"] as? String{
          tokenAuthenticityMsg = msg
        }
        
        if tokenAuthenticityFlag == true{

          // Code to make call UIALert dialogue in main thread for the UI.
          dispatch_async(dispatch_get_main_queue()){
            
            let message = "Please reconnect your \(tokenAuthenticityMsg) app to continue to receive Health Points."
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
          }
          
        }
      }
    }
  }
  

  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the state of method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    labelNoWorkoutJournalAvailableLabel.hidden = true
    
    // Code to register observer on NSNotificationCenter singleton instance of application for ConnectedAppsTokenAuthenticity.
    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MVPMyMVPWorkoutViewController.connectedAppsTokenAuthenticityObserverBy(_:)) , name: "ConnectedAppsTokenAuthenticity", object: nil)

    // Code to mark log event on to flurry for WorkOut screen view.
    dispatch_async(dispatch_get_main_queue(), {
      FlurryManager.sharedInstance.setFlurryLogForScreenType(ViewScreensEnum.WorkOut)
    })
    
    // ASynchronous call for the token authenticity.
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(queue) { () -> Void in // Deafult priority background process queue.
      WorkoutService.validateTokenAuthenticityForConnectedAppsBy()
    }
    
    
    // Call method to set UI of screen.
    myMvpWorkoutsArray.removeAll()
    self.preparedScreenDesign()
    
    
    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      // Code to show progress loader.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      
      var inputParams = [String: String]()
      inputParams["period"] = "0"
      self.fetchMyMvpWorkoutsWith(inputParams)
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self
    
    
    /*
     * Code to check whether user staus is changecd in application from Create or Edit Workout.
     * According to the user status flag boolean value we need to update the view accordingally.
     */
    let userStatusFlag = UserViewModel.getUserStatus() as Bool
    if userStatusFlag == true{
      // Code to set user status in application to false.
      UserViewModel.setUserStatusInApplication(false)
      
      /*
       * Code to call method executeUpdatedFetchWorkoutJournalApi to initiate api service for updated or new Workout and Journal
       */
      self.executeUpdatedFetchWorkoutJournalApi()
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    // Code to remove added register observer from NSNotificationCenter of ConnectedAppsTokenAuthenticity.
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "ConnectedAppsTokenAuthenticity", object: nil)
  }
  
  
  
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    // Code to set UI view for the workout and Journal enumeration type.
    self.prepareWorkoutJournalTypeButtonDesignFor()
    
    // Code to set the UI for Workout Filter design screen
    self.prepareWorkoutFilterOptionLableDesignFor(workoutFilterOptionType)
  }
  
  
  
  // MARK:  fetchMyMvpWorkoutsWith method.
  func executeUpdatedFetchWorkoutJournalApi(){
    var inputParams = [String: String]()

    if userActivityType == UserActivityTypeEnumeration.Workout{ // For Workout
      if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.All{
        inputParams["period"] = "0"
      }
      else if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.Annual{
        inputParams["period"] = "3"
      }
      else if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.Weekly{
        inputParams["period"] = "2"
      }
      else if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.Monthly{
        inputParams["period"] = "1"
      }
    }
    else{ // For Journal
      inputParams["period"] = "0"
    }
    
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
    self.fetchMyMvpWorkoutsWith(inputParams)
  }
  
  
  // MARK:  fetchMyMvpWorkoutsWith method.
  func fetchMyMvpWorkoutsWith(input: [String: String]) {
    /*
     * Code to initiate input param dictionary to fetch all Workouts of memid.
     * Currently memid is login api is not working from client side to get the logged user information.
     */
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    var inputParams = input
    inputParams["memid"] = memberId
    
    // Code to execute the GetWorkOuts api endpoint from WorkoutService class method getMyMvpWorkoutsBy to fetch all workOuts of memid.
    WorkoutService.getMyMvpWorkoutsBy(inputParams, completion: { (responseStatus, arrayOfWorkoutsObject) -> () in
      
      if self.userActivityType == UserActivityTypeEnumeration.Workout{ // For Workout
        self.myMvpWorkoutsArray = arrayOfWorkoutsObject as! [Workout]
      }
      else{ // For Journal
        self.myMvpWorkoutsArray = WorkoutViewModel.filterJournalWorkoutFrom(arrayOfWorkoutsObject as! [Workout])
      }
      
      // Code to upate UI in the Main thread when GetRewards api response execute successfully.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide HUD loader.
        HUD.hide(animated: true)
        
        // Code to re-set the UI design for the screen.
        self.preparedScreenDesign()
        
        // Code to hide or show labelNoWorkoutJournalAvailableLabel based on Workout/Journal array count.
        if self.myMvpWorkoutsArray.count > 0{
          
          // Code to notify UITableView instance to refresh list by reloadData method.
          self.tableViewWorkoutJournal.reloadData()
          
          self.labelNoWorkoutJournalAvailableLabel.hidden = true
        }
        else{
          self.labelNoWorkoutJournalAvailableLabel.hidden = false
          
          if self.userActivityType == UserActivityTypeEnumeration.Workout{
            self.labelNoWorkoutJournalAvailableLabel.text = NSLocalizedString(NOWORKOUTSAVAILABLEMSG, comment: "")
          }
          else if self.userActivityType == UserActivityTypeEnumeration.Journal{
            self.labelNoWorkoutJournalAvailableLabel.text = NSLocalizedString(NOJOURNALSAVAILABLEMSG, comment: "")
          }
        }
      }
      
    })
  }
  
  
  
  // MARK:  editWorkoutBtnClicked method.
  func editWorkoutBtnClicked(sender:UIButton!) {
    // Code to get edit workout from cell indexPath row index position.
    let tagIndex = sender.tag
    let workout = myMvpWorkoutsArray[tagIndex] as Workout
    
    // Code to initiate storyboard instance for navigation to Create Workout viewController.
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPCreateWorkoutViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCREATEWORKOUTVIEWCONTROLLER) as! MVPMyMVPCreateWorkoutViewController
    
    mvpMyMVPCreateWorkoutViewController.editFlag = true
    mvpMyMVPCreateWorkoutViewController.editWorkout = workout
    self.navigationController?.pushViewController(mvpMyMVPCreateWorkoutViewController, animated: true)
  }
  

  
  
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  createWorkoutJournalButtonTapped method.
  @IBAction func createWorkoutJournalButtonTapped(sender: UIButton){
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPCreateWorkoutViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCREATEWORKOUTVIEWCONTROLLER) as! MVPMyMVPCreateWorkoutViewController
    self.navigationController?.pushViewController(mvpMyMVPCreateWorkoutViewController, animated: true)
  }
  
  /*
   * Method to invoke from workout and journal button selector target method.
   */
  // MARK:  workoutJournalButtonTapped method.
  @IBAction func workoutJournalButtonTapped(sender: UIButton){
    let buttonTag = sender.tag

    switch buttonTag {
    case 0:
      // Code to call method which is set UI design screen for Workout.
      userActivityType = UserActivityTypeEnumeration.Workout
      
      workoutFilterOptionType = WorkoutFilterOptionTypeEnumeration.All
      self.prepareWorkoutFilterOptionLableDesignFor(workoutFilterOptionType)
      break
      
    case 1:
      // Code to call method which is set UI design screen for Workout.
      userActivityType = UserActivityTypeEnumeration.Journal
      break
      
    default:
      print("default case.")
    }
    
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
    var inputParams = [String: String]()
    inputParams["period"] = "0"
    self.fetchMyMvpWorkoutsWith(inputParams)
  }
  
  
  
  // MARK:  prepareWorkoutJournalTypeButtonDesignFor method.
  func  prepareWorkoutJournalTypeButtonDesignFor() {
    buttonWorkout.backgroundColor = UnSelectSiteClassTypeBackgroundColor
    buttonWorkout.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    
    buttonJournal.backgroundColor = UnSelectSiteClassTypeBackgroundColor
    buttonJournal.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    
    switch userActivityType {
    case UserActivityTypeEnumeration.Workout:
      labelHeaderTitle.text = "Workouts"
      buttonWorkout.backgroundColor = WHITECOLOR
      buttonWorkout.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)
      
      viewFilterWorkout.hidden = false
      viewFilterWorkoutHeightConstraint.constant = 50.0

      break
      
    case UserActivityTypeEnumeration.Journal:
      labelHeaderTitle.text = "Journal"
      buttonJournal.backgroundColor = WHITECOLOR
      buttonJournal.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)
      
      viewFilterWorkout.hidden = true
      viewFilterWorkoutHeightConstraint.constant = 0.0
      
      break
    }
  }
  
  // MARK:  workoutFilterOptionButtonTapped method.
  @IBAction func workoutFilterOptionButtonTapped(sender: UIButton){
    var inputParams = [String: String]()
    let tagIndex = sender.tag
    
    switch tagIndex {
    case 101:
      workoutFilterOptionType = WorkoutFilterOptionTypeEnumeration.All
      self.prepareWorkoutFilterOptionLableDesignFor(workoutFilterOptionType)
      inputParams["period"] = "0"
      
    case 201:
      workoutFilterOptionType = WorkoutFilterOptionTypeEnumeration.Annual
      self.prepareWorkoutFilterOptionLableDesignFor(workoutFilterOptionType)
      inputParams["period"] = "3"
      
    case 301:
      workoutFilterOptionType = WorkoutFilterOptionTypeEnumeration.Monthly
      self.prepareWorkoutFilterOptionLableDesignFor(workoutFilterOptionType)
      inputParams["period"] = "2"
      
    case 401:
      workoutFilterOptionType = WorkoutFilterOptionTypeEnumeration.Weekly
      self.prepareWorkoutFilterOptionLableDesignFor(workoutFilterOptionType)
      inputParams["period"] = "1"
      
    default:
      print("")
    }
    
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
    self.fetchMyMvpWorkoutsWith(inputParams)
  }

  // MARK:  prepareWorkoutFilterOptionLableDesignFor method.
  func  prepareWorkoutFilterOptionLableDesignFor(type: WorkoutFilterOptionTypeEnumeration) {
    labelAll.layer.cornerRadius = VALUETENCORNERRADIUS
    labelAll.layer.masksToBounds = true
    
    labelAnnualy.layer.cornerRadius = VALUETENCORNERRADIUS
    labelAnnualy.layer.masksToBounds = true
    
    labelMonthly.layer.cornerRadius = VALUETENCORNERRADIUS
    labelMonthly.layer.masksToBounds = true
    
    labelWeekly.layer.cornerRadius = VALUETENCORNERRADIUS
    labelWeekly.layer.masksToBounds = true
    
    labelAll.backgroundColor = CLEARCOLOR
    labelAll.textColor = BLACKCOLOR
    
    labelAnnualy.backgroundColor = CLEARCOLOR
    labelAnnualy.textColor = BLACKCOLOR
    
    labelMonthly.backgroundColor = CLEARCOLOR
    labelMonthly.textColor = BLACKCOLOR
    
    labelWeekly.backgroundColor = CLEARCOLOR
    labelWeekly.textColor = BLACKCOLOR
    
    switch type {
    case WorkoutFilterOptionTypeEnumeration.All:
      labelAll.backgroundColor = BLACKCOLOR
      labelAll.textColor = WHITECOLOR
      break
      
    case WorkoutFilterOptionTypeEnumeration.Annual:
      labelAnnualy.backgroundColor = BLACKCOLOR
      labelAnnualy.textColor = WHITECOLOR
      break
      
    case WorkoutFilterOptionTypeEnumeration.Monthly:
      labelMonthly.backgroundColor = BLACKCOLOR
      labelMonthly.textColor = WHITECOLOR
      break
      
    case WorkoutFilterOptionTypeEnumeration.Weekly:
      labelWeekly.backgroundColor = BLACKCOLOR
      labelWeekly.textColor = WHITECOLOR
      break
    }
  }
  
  
  
  // MARK:  drawerButtonTapped method.
  @IBAction func drawerButtonTapped(sender: UIButton){
    dimView.frame = self.view.frame
    dimView.backgroundColor = BLACKCOLOR
    dimView.alpha = 0.0
    self.view.addSubview(dimView)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(MVPMyMVPScheduleViewController.handleOuterViewWithDrawerTapGesture))
    dimView.addGestureRecognizer(tap)
    
    let yPoint = 20 + viewHeaderView.frame.size.height
    let xPoint = self.view.frame.size.width/2
    tableview = DrawerTableView(frame: CGRectMake(self.view.frame.size.width, yPoint, self.view.frame.size.width/2, self.view.frame.size.height-yPoint), style: .Plain)
    tableview.parentViewController = self
    tableview.drawerDelegate = self
    self.view.addSubview(tableview)
    
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.dimView.alpha = 0.6
      
      self.tableview.frame = CGRectMake(xPoint, yPoint, self.tableview.frame.size.width, self.tableview.frame.size.height)
      }, completion: { finished in
        // Code to
    })
  }
  
  // MARK:  handleOuterViewWithDrawerTapGesture method.
  func handleOuterViewWithDrawerTapGesture() {
    let yPoint = 20 + viewHeaderView.frame.size.height
    let xPoint = self.view.frame.size.width
    
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.dimView.alpha = 0.0
      self.tableview.frame = CGRectMake(xPoint, yPoint, self.tableview.frame.size.width, self.tableview.frame.size.height)
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

  
  

  // MARK:  editJournalWorkoutBtnClicked method.
  func editJournalWorkoutBtnClicked(sender:UIButton!) {
    // Code to get edit workout from cell indexPath row index position.
    let tagIndex = sender.tag
    let workout = myMvpWorkoutsArray[tagIndex] as Workout
    
    // Code to initiate storyboard instance for navigation to Create Workout viewController.
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPCreateWorkoutViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCREATEWORKOUTVIEWCONTROLLER) as! MVPMyMVPCreateWorkoutViewController
    
    mvpMyMVPCreateWorkoutViewController.editFlag = true
    mvpMyMVPCreateWorkoutViewController.editWorkout = workout
    self.navigationController?.pushViewController(mvpMyMVPCreateWorkoutViewController, animated: true)
  }
  
  // MARK:  shareFacebookWorkoutBtnClicked method.
  func shareFacebookWorkoutBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let postContentDesc = self.getFacebookPostContentDescriptionText(tagIndex)
    
    let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
    content.contentURL = NSURL(string: "http://www.mvpsportsclubs.com/")
    content.contentTitle = "MVP Sports Clubs"
    content.contentDescription = postContentDesc
    content.imageURL = NSURL(string:"http://www.mvpsportsclubs.com/sites/default/files/images/default-bio.gif")
    
    let shareDialog = FBSDKShareDialog()
    shareDialog.fromViewController = self
    shareDialog.shareContent = content
    shareDialog.mode = FBSDKShareDialogMode.Native
    shareDialog.delegate = self
    
    if !shareDialog.canShow() {
      print("cannot show native share dialog")
      shareDialog.mode = FBSDKShareDialogMode.FeedBrowser
    }
    
    shareDialog.show()
  }
  
  // MARK:  getFacebookPostContentDescriptionText method.
  func getFacebookPostContentDescriptionText(shareWorkoutIndex: Int) -> String {
    var contentDescription = ""
    
    var SiteName = ""
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    if let siteName = loggedUserDict["siteName"]{
      SiteName = siteName as String
    }
    
    let workOut = myMvpWorkoutsArray[shareWorkoutIndex] as Workout
    if let workoutType = workOut.type{
      
      let workoutType = workoutType as String
      var workoutName = ""
      var instructorName = ""
      
      if let wName = workOut.Name{
        workoutName = wName as String
      }
      
      if let instName = workOut.instructorName{
        instructorName = instName as String
      }
      
      if workoutType == "Classes"{
        contentDescription = "I finished \(workoutName) at \(SiteName)!"
      }
      else if workoutType == "manual"{
        contentDescription = "I finished a workout at \(SiteName)!"
      }
      else if workoutType == "training"{
        contentDescription = "I worked out with \(instructorName) at \(SiteName)!"
      }
    }
    
    return contentDescription
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
 * Extension of MVPMyMVPWorkoutViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPWorkoutViewController.
 */
// MARK:  Extension of MVPMyMVPWorkoutViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPWorkoutViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return myMvpWorkoutsArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if userActivityType == UserActivityTypeEnumeration.Workout{
      return 120.0
    }
    else{
      return 180.0
    }
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    if userActivityType == UserActivityTypeEnumeration.Workout{
      let cell: MyMVPWorkoutTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPWORKOUTTABLEVIEWCELL) as? MyMVPWorkoutTableViewCell!)!
      
      let workout = myMvpWorkoutsArray[indexPath.row] as Workout
      let duration = workout.duration! as Int
      let dateCreated = workout.datecreated! as String
      
      if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.All{
        let modifiedCreatedDate = WorkoutViewModel.getDateStringFromWorkoutCreatedDateString(dateCreated)
        let workoutName = workout.Name! as String
        cell.labelWorkoutName.text = "\(workoutName) \(modifiedCreatedDate)"
      }
      else if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.Annual{
        let year = WorkoutViewModel.getYearStringFromWorkoutCreatedDateString(dateCreated)
        cell.labelWorkoutName.text = year
      }
      else if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.Monthly{
        let monthYear = WorkoutViewModel.getMonthYearStringFromWorkoutCreatedDateString(dateCreated)
        cell.labelWorkoutName.text = monthYear
      }
      else if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.Weekly{
        let modifiedCreatedDate = WorkoutViewModel.getDateStringFromWorkoutCreatedDateString(dateCreated)
        cell.labelWorkoutName.text = "Week Ending \(modifiedCreatedDate)"
      }

      cell.textFieldWorkoutCalorie.text = "\(workout.calories! as Int)"
      cell.textFieldWorkoutDuration.text = "\(duration / 60000)m"
      cell.textFieldWorkoutDistance.text = "\(workout.distance! as Float)mi"
      cell.textFieldWorkoutSteps.text = "\(workout.steps! as Int)"
      
      cell.buttonWorkoutEdit.tag = indexPath.row
      cell.buttonWorkoutEdit.addTarget(self, action: #selector(MVPMyMVPWorkoutViewController.editWorkoutBtnClicked(_:)), forControlEvents: .TouchUpInside)
      
      if workoutFilterOptionType == WorkoutFilterOptionTypeEnumeration.All{
        cell.buttonWorkoutEdit.hidden = false
      }
      else{
        cell.buttonWorkoutEdit.hidden = true
      }
      
      return cell
    }
    else{
      let cell: MyMVPJournalTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPJOURNALTABLEVIEWCELL) as? MyMVPJournalTableViewCell!)!
      
      let journalWorkout = myMvpWorkoutsArray[indexPath.row] as Workout
      let workoutName = journalWorkout.Name! as String
      let dateCreated = journalWorkout.datecreated! as String
      let duration = journalWorkout.duration! as Int
      let calorie = journalWorkout.calories! as Int
      let distance = journalWorkout.distance! as Float
      
      cell.labelJournalWorkoutTimeAgo.text = "\(WorkoutViewModel.getDurationBetweenCreatedWorkoutTimeFromCurrentTime(dateCreated)) Ago Via \(workoutName)"
      cell.labelJournalWorkoutTimeTaken.text = "Time: \(WorkoutViewModel.getHoursMinutesStringFromDuration(duration))"
      cell.labelJournalWorkoutCalorieBurned.text = "Calorie Burned: \(calorie)"
      cell.labelJournalWorkoutDistanceCovered.text = "Distance: \(distance)mi"
      
      cell.buttonFacebookShare.tag = indexPath.row
      cell.buttonFacebookShare.addTarget(self, action: #selector(MVPMyMVPWorkoutViewController.shareFacebookWorkoutBtnClicked(_:)), forControlEvents: .TouchUpInside)

      cell.buttonJournalWorkout.tag = indexPath.row
      cell.buttonJournalWorkout.addTarget(self, action: #selector(MVPMyMVPWorkoutViewController.editJournalWorkoutBtnClicked(_:)), forControlEvents: .TouchUpInside)

      return cell
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewWorkoutJournal.reloadData()
  }
  
}


// MARK:  Extension of MVPMyMVPWorkoutViewController by DrawerTableViewDelegate method.
extension MVPMyMVPWorkoutViewController: DrawerTableViewDelegate{
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    self.popDrawerView()
  }
  
}


/*
 * Extension of MVPMyMVPWorkoutViewController to add UITextField prototcol UITextFieldDelegate.
 * Override the protocol method of textfield delegate in MVPMyMVPWorkoutViewController to handle textfield action event and slector method.
 */
// MARK:  UITextField Delegates methods
extension MVPMyMVPWorkoutViewController: UITextFieldDelegate{
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
    let workout = myMvpWorkoutsArray[editCellIndex] as Workout
    var calorie = "\(workout.calories! as Int)" as String
    var duration = "\(workout.duration! as Int / 60000)"
    
    print(calorie)
    let textfieldTag = textField.tag
    if textfieldTag == 101{ // For Calorie
      if string == ""{ // When user tapped back slash
        if calorie.characters.count == 0{
          return false
        }
        else{
          if calorie == "0"{
            workout.calories = 0
            return true
          }
          else{
            let newString = calorie.substringToIndex(calorie.endIndex.predecessor())
            if newString.characters.count == 0{
              workout.calories = 0
            }
            else{
              workout.calories = Int(newString)
            }
            return true
          }
        }
      }
      else{ // When user tapped any digit character.
        let aSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        if string == numberFiltered{ // When user tapped a valid keyboard key.
          
          if (calorie.characters.count == 0 || calorie == "0") && string == "0"{
            return false
          }
          else{
            if calorie == "0"{
              textField.text = string
              workout.calories = Int(string)
              return false
            }
            else{
              calorie = "\(calorie)\(string)"
              workout.calories = Int(calorie)
              return true
            }
          }
        }
        else{ // return false when user entered non valid keyboard key.
          return false
        }
      }
    }
    else if textfieldTag == 201{ // For Duration
      if string == ""{ // When user tapped back slash
        if duration.characters.count == 0{
          return false
        }
        else{
          if duration == "0"{
            workout.duration = 0
            textField.text = "0 m"
            return false
          }
          else{
            let newString = duration.substringToIndex(duration.endIndex.predecessor())
            if newString.characters.count == 0{
              workout.duration = 0
              textField.text = "0 m"
              return false
            }
            else{
              workout.duration = Int(newString)!*60000
              textField.text = "\(newString) m"
              return false
            }
          }
        }
        
      }
      else{ // When user tapped any digit character.
        let aSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        if string == numberFiltered{ // When user tapped a valid keyboard key.
          
          if (duration.characters.count == 0 || duration == "0") && string == "0"{
            return false
          }
          else{
            if duration == "0"{
              textField.text = "\(string) m"
              workout.duration = Int(string)! * 60000
              return false
            }
            else{
              duration = "\(duration)\(string)"
              textField.text = "\(duration) m"
              workout.duration = Int(duration)! * 60000
              return false
            }
          }
        }
        else{ // return false when user entered non valid keyboard key.
          return false
        }
      }
    }
    else if textfieldTag == 301{ // For Distance
      
      let aSet = NSCharacterSet(charactersInString:"0123456789.").invertedSet
      let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
      let numberFiltered = compSepByCharInSet.joinWithSeparator("")
      return string == numberFiltered
    }
    else{
    }
    
    return true
  }
  
}


// MARK:  Extension of MVPMyMVPWorkoutViewController by FBSDKSharingDelegate and FacebookManagerDelegate delegate methods.
extension MVPMyMVPWorkoutViewController: FBSDKSharingDelegate{

  /*
   @abstract Sent to the delegate when the share completes without error or cancellation.
   @param sharer The FBSDKSharing that completed.
   @param results The results from the sharer.  This may be nil or empty.
   */
  func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!){
    print(results)
  }
  
  /*
   @abstract Sent to the delegate when the sharer encounters an error.
   @param sharer The FBSDKSharing that completed.
   @param error The error.
   */
  func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!){
    print(error)
  }
  
  /*
   @abstract Sent to the delegate when the sharer is cancelled.
   @param sharer The FBSDKSharing that completed.
   */
  func sharerDidCancel(sharer: FBSDKSharing!){
    print(sharer)
  }

}


// MARK:  Extension of MVPMyMVPWorkoutViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPWorkoutViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    print("MVPMyMVPWorkoutViewController announcementDelegate")
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

