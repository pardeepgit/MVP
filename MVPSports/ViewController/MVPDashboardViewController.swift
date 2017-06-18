//
//  MVPDashboardViewController.swift
//  MVPSports
//
//  Created by Chetu India on 09/08/16.
//

import UIKit
import PKHUD
import EventKit
import MapKit
import Flurry_iOS_SDK


class MVPDashboardViewController: UIViewController {
  
  // MARK:  Widget UI elements declarations.
  @IBOutlet weak var tableViewDashboardList: UITableView!
  @IBOutlet weak var labelNoSiteClassAvailableLabel: UILabel!
  @IBOutlet weak var viewBottomView: UIView!
  @IBOutlet weak var labelSiteName: UILabel!
  @IBOutlet weak var labelBadgeCount: UILabel!

  // Widget for LoginView and Bar Chart Graph.
  @IBOutlet weak var viewLoggedUserHealthPointView: UIView!
  @IBOutlet weak var viewLoginView: UIView!
  
  @IBOutlet weak var viewHealthPointBarChartView: UIView!
  @IBOutlet weak var viewHealthPointStatusView: UIView!
  @IBOutlet weak var buttonMemberSectionSelection: UIButton!
  @IBOutlet weak var labelTotalHealthPointEarnedTitle: UILabel!
  @IBOutlet weak var labelTotalHealthPointEarned: UILabel!
  @IBOutlet weak var labelUntilNextLevelRemainingPointTitle: UILabel!
  @IBOutlet weak var labelUntilNextLevelRemainingPoint: UILabel!
  @IBOutlet weak var buttonLogin: UIButton!
  @IBOutlet weak var labelPunchCardSessionLeft: UILabel!
  @IBOutlet weak var labelChangeLocation: UILabel!

  // Widget for CheckIn, Workout and ContactUs
  @IBOutlet weak var labelCheckIn: UILabel!
  @IBOutlet weak var labelWorkout: UILabel!
  @IBOutlet weak var buttonCheckIn: UIButton!
  @IBOutlet weak var buttonWorkout: UIButton!
  @IBOutlet weak var buttonContactUs: UIButton!
  
  @IBOutlet weak var hpChartViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var checkInWorkoutViewHeightConstraint: NSLayoutConstraint!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var dashboardSectionArray = [String]()
  var dashboardCellValueForSection = [String: AnyObject]()
  
  var arrayOfSiteClubObject = [SiteClub]()
  var arrayOfExerciseSiteClass = [ExerciseClass]()
  var arrayOfHealthPointLevelObjects = [[String: AnyObject]]()
  var arrayOfGraphYlabelValues = [Int]() // [100, 200, 300, 400, 600] //
  var arrayOfGraphEarnedPointYlabelValues =  [Int]() // [100, 120, 180, 220, 0] //
  var arrayOfGraphXlabelValues = [String]() // ["Level 1", "Level 2", "Level 3", "Level 4", "Level 5"] //
  var hpChartFlag = false
  
  var earnedPoint = 0
  var nextLevelPoint = 0
  var siteId = ""
  var siteName = ""
  var userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
  var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
  var locationManager: CLLocationManager!
  
  // For Drawer View.
  var dimView = UIView()
  var tableview = DrawerTableView()
  
  var apiCounter = 0
  var validateApiCounter = 0
  var loaderFlag = false
  
  
  /*
   * receiveNotificationObserverBy method .
   */
  // MARK:  receiveNotificationObserverBy method.
  func receiveNotificationObserverBy(notification: NSNotification) {
    
    if notification.name == "DashboardSiteClassesByDate"{
      if let respDict = notification.object as? [String: AnyObject]{
        print(respDict)
        validateApiCounter = validateApiCounter + 1
      }
    }
    else if notification.name == "UserOptInStatus"{
      if let respDict = notification.object as? [String: AnyObject]{
        print(respDict)
        validateApiCounter = validateApiCounter + 1
      }
    }
    
    if validateApiCounter == apiCounter{
      dispatch_async(dispatch_get_main_queue()) {
        if self.loaderFlag == true{
          self.loaderFlag = false

          // Code to hide progress hud.
          HUD.hide(animated: true)
          self.updateScreenForNotificationObserverObjectBy((notification.object as? [String: AnyObject])!)
        }
        else{
          // HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))
          
          // Code to call fetchUserCheckInScheduleExerciseClasses method after certain one second delay.
          let triggerTime = (Int64(NSEC_PER_SEC) * 1)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.updateScreenForNotificationObserverObjectBy((notification.object as? [String: AnyObject])!)
          })
        }
      }
    }
    
  }
  
  // MARK:  updateScreenForNotificationObserverObjectBy method.
  func updateScreenForNotificationObserverObjectBy(object: [String: AnyObject]) {
    validateApiCounter = 0
    
    dispatch_async(dispatch_get_main_queue()) {
      // Code to fetch Site Classes from local cache sqlite database.
      ExerciseClassViewModel.fetchSiteClassesFromLocalCacheByType(SiteClassesTypeEnum.ByDate, completion: { (exerciseSiteClassArrayFromLocal) -> () in
        
        if exerciseSiteClassArrayFromLocal.count > 0{
          self.arrayOfExerciseSiteClass = exerciseSiteClassArrayFromLocal
        }
        else{
          self.arrayOfExerciseSiteClass = [ExerciseClass]()
        }
        
        // Code to call method to update UI in main thread.
        self.preparedScreenDesign()
      })
      
    }
  }
  
  // MARK:  updateDashboardScreenForUpdatedUnLoggedUserStatus method.
  func updateDashboardScreenForUpdatedUnLoggedUserStatus() {
    // Code to set default api flag for local cache.
    UtilManager.sharedInstance.setDefaultApiFlagForLocalCacheFunctionality()
    
    
    // Code to get updated information of user user flag and user dict information.
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    
    // Code to remove all ExerciseClass from array.
    arrayOfExerciseSiteClass.removeAll()
    
    // Code to call method to update UI in main thread.
    self.preparedScreenDesign()
    
    /*
     * Code to call method executeApiServiceMethodForDashboard to initiate api service for dashboard screen.
     */
    self.executeApiServiceMethodForDashboard()
  }

  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    labelNoSiteClassAvailableLabel.text = NSLocalizedString(NOCLASSESAVAILABLEMSG, comment: "")
    labelNoSiteClassAvailableLabel.hidden = true
    
    // Code to mark log event on to flurry for Dashboard screen view.
    dispatch_async(dispatch_get_main_queue(), {
        FlurryManager.sharedInstance.setFlurryLogForScreenType(ViewScreensEnum.Dashboard)
    })

    
    // Code to call method preparedScreenDesign to prepare UI view.
    self.preparedScreenDesign()
    
    // Code to validate for the user tapped on device notification.
    let notifyTappedStatus = NotificationAnnouncementViewModel.getNotifyTappedStatusFromUserDefaultBy()
    if notifyTappedStatus == true{
      // Code to set to update tapped notify status to become false.
      NotificationAnnouncementViewModel.setNotifyTappedStatusToUserDefaultBy(false)

      // Code to navigate user to annoucemnet screen for the notification.
      self.notificationAlertBellBtnClicked(UIButton())
    }
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
    RemoteNotificationObserverManager.sharedInstance.delegate = self

    // Code to register observer on NSNotificationCenter singleton instance of application for SiteClass and UserOptInStatus.
    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MVPDashboardViewController.receiveNotificationObserverBy(_:)) , name: "DashboardSiteClassesByDate", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MVPDashboardViewController.receiveNotificationObserverBy(_:)) , name: "UserOptInStatus", object: nil)
    
    // Code to get updated information of user user flag and user dict information.
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    
    // Code to fetch Site Classes from local cache sqlite database.
    ExerciseClassViewModel.fetchSiteClassesFromLocalCacheByType(SiteClassesTypeEnum.ByDate, completion: { (exerciseSiteClassArrayFromLocal) -> () in
      
      if exerciseSiteClassArrayFromLocal.count > 0{
        self.arrayOfExerciseSiteClass = exerciseSiteClassArrayFromLocal
      }
      else{
        self.arrayOfExerciseSiteClass = [ExerciseClass]()
      }

      // Code to call method to update UI in main thread.
      self.preparedScreenDesign()
      
      /*
       * Code to call method executeApiServiceMethodForDashboard to initiate api service for dashboard screen.
       */
      self.executeApiServiceMethodForDashboard()
      
    })
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    RemoteNotificationObserverManager.sharedInstance.delegate = nil
    
    // Code to remove added register observer from NSNotificationCenter of SiteClass and UserOptIn status.
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "DashboardSiteClassesByDate", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "UserOptInStatus", object: nil)
  }
  
  
  
  /*
   * prepareUiComponent method is created to set all UI design element configuration with some property.
   */
  // MARK:  prepareUiComponent method.
  func prepareUiComponent() {
    /*
     * Code to Change the lable font size for the iPhone_5 device.
     */
    if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
      labelTotalHealthPointEarnedTitle.font = TWELVESYSTEMLIGHTFONT
      labelUntilNextLevelRemainingPointTitle.font = TWELVESYSTEMLIGHTFONT
    }
    else if DeviceType.IS_IPHONE_6 {
    }
    else if DeviceType.IS_IPHONE_6P {
    }
    
    
    if DeviceType.IS_IPHONE_4_OR_LESS {
      checkInWorkoutViewHeightConstraint.constant = 210
    }
    else{
      checkInWorkoutViewHeightConstraint.constant = 180
    }
    
    // Login View and Bar Chart Status view
    buttonLogin.layer.cornerRadius = VALUEFIFTEENCORNERRADIUS
    viewHealthPointStatusView.layer.borderColor = BLACKCOLOR.CGColor
    viewHealthPointStatusView.layer.borderWidth = VALUEONEBORDERWIDTH
    viewHealthPointStatusView.layer.cornerRadius = VALUETENCORNERRADIUS
    
    // Code to set corner round rect become circle of check in and workout button.
    buttonContactUs.layer.cornerRadius = VALUEFIFTEENCORNERRADIUS
    
    // Code to set the label text of labelChangeLocation UILabel.
    labelChangeLocation.text = "CHANGE\("\n")LOCATION"
    
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // When user is logged in
      labelCheckIn.textColor = BLACKCOLOR
      labelWorkout.textColor = BLACKCOLOR
      
      buttonCheckIn.setBackgroundImage(UIImage(named: "checkinenabled"), forState: UIControlState.Normal)
      buttonWorkout.setBackgroundImage(UIImage(named: "workoutenabled"), forState: UIControlState.Normal)
      
      // Code to Hide LoginView when user is logged in.
      viewLoginView.hidden = true
      buttonLogin.hidden = true
    }
    else{ //When user is not logged in
      labelCheckIn.textColor = LIGHTGRAYCOLOR
      labelWorkout.textColor = LIGHTGRAYCOLOR
      
      buttonCheckIn.setBackgroundImage(UIImage(named: "checkindisabled"), forState: UIControlState.Normal)
      buttonWorkout.setBackgroundImage(UIImage(named: "workoutdisabled"), forState: UIControlState.Normal)
      
      // Code to UnHide LoginView when user is logged out.
      viewLoginView.hidden = false
      buttonLogin.hidden = false
    }
  }
  
  /*
   * preparedScreenDesign method is created to set all UI design element configuration with some property.
   */
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    // Code to call method to set view of widget components.
    self.prepareUiComponent()
    
    
    // When user is un logged and call method for default Site Club.
    self.userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if self.userLoginFlag == false{
      
      // Code for the CLLocationManager instance for current location.
      if (CLLocationManager.locationServicesEnabled()){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // requestWhenInUseAuthorization
        locationManager.startUpdatingLocation()
      }
    }
    
    // Code to set user default
    if siteName.characters.count > 0{
      labelSiteName.text = siteName as String
    }
    
    // Code to prepare health point chart view.
    self.prepareHealthPointChartGraphDataByEarnedPoint(self.earnedPoint)
    
    // Code to hide or show labelNoSiteClassAvailableLabel based on Exercise Site Class array count.
    if arrayOfExerciseSiteClass.count > 0{
      labelNoSiteClassAvailableLabel.hidden = true
    }
    else{
      labelNoSiteClassAvailableLabel.hidden = false
    }
    
    // Code to call notify method on UITableView instance to load table view information.
    tableViewDashboardList.reloadData()
  }
  
  
  
  
  
  
  
  /*
   * executeApiServiceMethodForDashboard method is design to execute Api Endpoint service method for the Dashboard screen for both logged and un logged user.
   */
  // MARK:  executeApiServiceMethodForDashboard method.
  func executeApiServiceMethodForDashboard() {
    if arrayOfExerciseSiteClass.count > 0{ // In Background process.
      if Reachability.isConnectedToNetwork() == true && DashboardViewModel.validateDashoboardApiStatusForExecution() == true {
        
        // Code to execute an Asynchronous call of api endpoint services.
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () -> Void in // Deafult priority background process queue.
          self.fetchDashboardDataByApiService()
        }
      }
    }
    else{
      // Code to check device is connected to internet connection or not.
      if Reachability.isConnectedToNetwork() == true {
        
        if DashboardViewModel.validateDashoboardApiStatusForExecution() == true{
          self.loaderFlag = true
          // Code to show progress loader with Loading... message in the progress loader.
          HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
          
          let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
          dispatch_async(queue) { () -> Void in // Deafult priority background process queue.
            self.fetchDashboardDataByApiService()
          }
        }
      }
      else{
        self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
      }
    }
  }
  
  /*
   * fetchDashboardDataByApiService method is design to fetch all data information for the dashboard.
   */
  // MARK:  fetchDashboardDataByApiService method.
  func fetchDashboardDataByApiService() {
    // Code to check whether user logged or not to the application. Based on that we get user home or default site club id to execute next api endpoint services.
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // When user is logged in
      siteId = loggedUserDict["Siteid"]! as String
      siteName = loggedUserDict["siteName"]! as String
      
      self.updateSiteClubNameLabelTextValue()
      
      self.executeDashboardInfoApiFor(siteId)
    }
    else{ // When user is not logged in.
      if self.arrayOfSiteClubObject.count > 0{
        self.getUnLoggedUserDefaultSiteClub()
      }
      else{
        let inputField = [String: String]()
        // Code to execute the getDefaultSiteClubsBy api endpoint from SiteClubService class method getDefaultSiteClubsBy to fetch all SiteClub of application default SiteClub by GetClubNames api service.
        SiteClubService.getDefaultSiteClubsBy(inputField, completion: { (apiStatus, arrayOfSiteClubs) -> () in
          // Code to assign array of SiteClub model class object.
          self.arrayOfSiteClubObject = arrayOfSiteClubs as! [SiteClub]
          
          self.getUnLoggedUserDefaultSiteClub()
        })
      }
      
    }
  }
  
  // MARK:  getUnLoggedUserDefaultSiteClub method.
  func getUnLoggedUserDefaultSiteClub() {
    var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
    if unLoggedUserDict.count > 0{ // Code to validate for un logged user default Site Class already in local .plist DB.
      if let siteid = unLoggedUserDict["siteId"]{
        self.siteId = siteid as String
      }
      if let sitename = unLoggedUserDict["siteName"]{
        self.siteName = sitename as String
      }
      
      self.updateSiteClubNameLabelTextValue()
      
      // Code to execute dashboard screen api endpoint services to fetch by default site id.
      self.executeDashboardInfoApiFor(self.siteId)
    }
    else{
      // Code to call a method to get site id from site clubs array of objects.
      self.siteId = self.getDefaultSiteClubId(self.arrayOfSiteClubObject)
      
      self.updateSiteClubNameLabelTextValue()
      
      // Code to execute dashboard screen api endpoint services to fetch by default site id.
      self.executeDashboardInfoApiFor(self.siteId)
    }
  }
  
  
  
  /*
   * executeDashboardInfoApiFor method tto execute SiteClass api endpoint service to get SiteClass and.
   * User Health Points if user is logged into app.
   */
  // MARK:  executeDashboardInfoApiFor method.
  func executeDashboardInfoApiFor(siteId: String) {
    // Set Default value to api counter and validater for the verififcation.
    apiCounter = 0
    validateApiCounter = 0
    
    apiCounter = apiCounter + 1
    DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.SiteClass, andStatus: false)
    // Code to execute Api endpoint services for the Dashboard screen SiteClasses and for logged user HealthPoint.
    var siteClassInputField = [String: String]()
    siteClassInputField["siteid"] = siteId
    DashboardViewModel.getSiteClassesOfSiteClubFromApiServerBy(siteClassInputField)
    
    // Code to check whether user is logged into application or not to get OptIn status.
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if self.userLoginFlag == true{
      
      apiCounter = apiCounter + 1
      DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.OptIn, andStatus: false)
      
      // Default inputParam dictionary for the OptInStatus api endpoint services.
      var userInputParam = [String: String]()
      userInputParam["memid"] = self.loggedUserDict["memberId"]! as String
      DashboardViewModel.getLoggedUserOptInStatusBy(userInputParam)
    }
  }
  
  
  
  // MARK:  updateSiteClubNameLabelTextValue method.
  func updateSiteClubNameLabelTextValue() {
    dispatch_async(dispatch_get_main_queue()) {
      // Code to set user default
      if self.siteName.characters.count > 0{
        self.labelSiteName.text = self.siteName as String
      }
    }
  }
  
  
  
  
  
  /*
   * getDefaultSiteClubId method to get user default Site Club id.
   */
  // MARK:  getDefaultSiteClubId method.
  func getDefaultSiteClubId(arrayOfSiteClubs: [SiteClub]) -> String {
    var siteid = ""
    var findBurtonClub = false
    var defaultSiteClub = SiteClub()
    
    for index in 0 ..< arrayOfSiteClubs.count{
      let siteClub = arrayOfSiteClubs[index] as SiteClub
      let clubName = siteClub.clubName! as String
      
      if clubName.lowercaseString.rangeOfString("burton") != nil{
        findBurtonClub = true
        defaultSiteClub = siteClub
        break
      }
    }
    
    if findBurtonClub != true{
      if arrayOfSiteClubs.count > 0{
        defaultSiteClub = arrayOfSiteClubs[0] as SiteClub
      }
    }
    
    siteid = defaultSiteClub.clubid! as String
    self.siteName = defaultSiteClub.clubName! as String
    
    // Code to save UnLogged user default site club info in local .plist file.
    var unLoggedUserDict = [String: String]()
    unLoggedUserDict["siteId"] = siteid
    unLoggedUserDict["siteName"] = self.siteName
    UserViewModel.saveUnLoggedUserDictInUserDefault(unLoggedUserDict)
    
    // Code to save Burton St location as current location when user disabled location services.
    var userCordinate = [String: String]()
    let lat = defaultSiteClub.lat! as String
    let long = defaultSiteClub.lang! as String
    userCordinate["lat"] = lat
    userCordinate["lang"] = long
    NSUserDefaults.standardUserDefaults().setValue(userCordinate, forKey: "currentlocation")
    NSUserDefaults.standardUserDefaults().synchronize()

    return siteid
  }
  
  func getNearestSiteClubByCurrentLocation(currentLocationDict: [String: String]) -> String {
    let currentLocationLat = currentLocationDict["lat"]! as String
    let currentLocationLang = currentLocationDict["lang"]! as String
    
    var nearestSiteClubIndex = 0
    var nearestSiteClubDist = 0
    
    for index in 0..<self.arrayOfSiteClubObject.count {
      let siteClub = self.arrayOfSiteClubObject[index]
      let siteClubLat = siteClub.lat! as String
      let siteClubLang = siteClub.lang! as String
      
      if ScheduleViewModel.validateSiteClubCordinates(siteClubLat, and: siteClubLang) && ScheduleViewModel.validateSiteClubCordinates(currentLocationLat, and: currentLocationLang) {
        let currentLocationCoord = CLLocationCoordinate2D(latitude: Double(currentLocationLat)!, longitude: Double(currentLocationLang)!)
        let siteClubCoord = CLLocationCoordinate2D(latitude: Double(siteClubLat)!, longitude: Double(siteClubLang)!)
        
        let currentLocationPoint = MKMapPointForCoordinate(currentLocationCoord)
        let siteClubPoint = MKMapPointForCoordinate(siteClubCoord)
        let meter = MKMetersBetweenMapPoints(currentLocationPoint, siteClubPoint)
        let meterIntValue = Int(meter)
        
        if nearestSiteClubDist != 0{
          if meterIntValue < nearestSiteClubDist{
            nearestSiteClubDist = meterIntValue
            nearestSiteClubIndex = index
          }
        }
        else{
          nearestSiteClubDist = meterIntValue
          nearestSiteClubIndex = index
        }
      }
    }
    
    let siteClub = self.arrayOfSiteClubObject[nearestSiteClubIndex]
    let siteid = siteClub.clubid! as String
    self.siteName = siteClub.clubName! as String
    
    // Code to save UnLogged user default site club info in local .plist file.
    var unLoggedUserDict = [String: String]()
    unLoggedUserDict["siteId"] = siteid
    unLoggedUserDict["siteName"] = self.siteName
    UserViewModel.saveUnLoggedUserDictInUserDefault(unLoggedUserDict)
    
    return siteid
  }
  
  func setNearestSiteClubAsDefaultSiteClub() {
    if let currentLocationDict = NSUserDefaults.standardUserDefaults().valueForKey("currentlocation") as? [String: String]{
      let currentLocationLat = currentLocationDict["lat"]! as String
      let currentLocationLang = currentLocationDict["lang"]! as String
      
      var nearestSiteClubIndex = 0
      var nearestSiteClubDist = 0
      
      for index in 0..<self.arrayOfSiteClubObject.count {
        let siteClub = self.arrayOfSiteClubObject[index]
        let siteClubLat = siteClub.lat! as String
        let siteClubLang = siteClub.lang! as String
        
        if ScheduleViewModel.validateSiteClubCordinates(siteClubLat, and: siteClubLang) && ScheduleViewModel.validateSiteClubCordinates(currentLocationLat, and: currentLocationLang) {
          let currentLocationCoord = CLLocationCoordinate2D(latitude: Double(currentLocationLat)!, longitude: Double(currentLocationLang)!)
          let siteClubCoord = CLLocationCoordinate2D(latitude: Double(siteClubLat)!, longitude: Double(siteClubLang)!)
          
          let currentLocationPoint = MKMapPointForCoordinate(currentLocationCoord)
          let siteClubPoint = MKMapPointForCoordinate(siteClubCoord)
          let meter = MKMetersBetweenMapPoints(currentLocationPoint, siteClubPoint)
          let meterIntValue = Int(meter)
          
          if nearestSiteClubDist != 0{
            if meterIntValue < nearestSiteClubDist{
              nearestSiteClubDist = meterIntValue
              nearestSiteClubIndex = index
            }
          }
          else{
            nearestSiteClubDist = meterIntValue
            nearestSiteClubIndex = index
          }
        }
      }
      
      let siteClub = self.arrayOfSiteClubObject[nearestSiteClubIndex]
      let nearestSiteId = siteClub.clubid! as String
      let nearestSiteName = siteClub.clubName! as String
      print(nearestSiteName)
      
      let nearestSiteClubFlag = self.validateNearestSiteClubWithDeafultSiteClub(nearestSiteId)
      if nearestSiteClubFlag == false{
        self.siteName = nearestSiteName
        
        // Code to save UnLogged user default site club info in local .plist file.
        var unLoggedUserDict = [String: String]()
        unLoggedUserDict["siteId"] = nearestSiteId
        unLoggedUserDict["siteName"] = nearestSiteName
        UserViewModel.saveUnLoggedUserDictInUserDefault(unLoggedUserDict)
        
        // When user is un logged and call method for default Site Club.
        self.userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
        if self.userLoginFlag == false{
          
          // Code to update UI in the Main thread.
          dispatch_async(dispatch_get_main_queue()) {
            // Code to hide progress loader with animated.
            HUD.hide(animated: true)
            
            self.updateSiteClubNameLabelTextValue()
            
            /*
             * Code to call method executeApiServiceMethodForDashboard to initiate api service for dashboard screen.
             */
            self.executeApiServiceMethodForDashboard()
          }
          
        }
      }
    }
  }
  
  func validateNearestSiteClubWithDeafultSiteClub(nearestSiteId: String) -> Bool{
    var checkFlag = true
    var defaultSiteId = ""
    
    var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
    if unLoggedUserDict.count > 0{ // Code to validate for un logged user default Site Class already in local .plist DB.
      if let siteid = unLoggedUserDict["siteId"]{
        defaultSiteId = siteid as String
      }
      
      if defaultSiteId == nearestSiteId{
        checkFlag = true
      }
      else{
        checkFlag = false
      }
    }
    else{
      checkFlag = false
    }
    
    return checkFlag
  }
  
  
  
  
  
  
  /*
   * Method to prepare health point level bar chart graph x-y label from array of health point level.
   */
  // MARK:  prepareHealthPointChartGraphDataByEarnedPoint method.
  func prepareHealthPointChartGraphDataByEarnedPoint(earnedPoint: Int) {
    hpChartViewHeightConstraint.constant = 120
    labelPunchCardSessionLeft.hidden = true
    viewLoggedUserHealthPointView.hidden = false
    buttonLogin.backgroundColor = UsedPunchCardSessionFilledColor
    
    for view in buttonLogin.subviews{
      if view .isKindOfClass(UIButton){
        view.removeFromSuperview()
      }
    }
    
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // When user is logged in
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
              self.createHealthPointBarChartGraph()
            }
          }
          else if optInStatusType == UserOptInStatusEnum.OptInView.hashValue{
            // Code to create dafault array for the Default HpChart.
            self.prepareDefaultHpChartViewData()
            
            // Code to call method to create HpChart.
            self.createHealthPointBarChartGraph()
            
            // Code to UnHide LoginView for the OptIn .
            viewLoginView.hidden = false
            buttonLogin.hidden = false
            
            buttonLogin.setTitle("OPT IN TO VIEW", forState: UIControlState.Normal)
            buttonLogin.tag = 201 // For OptIn View click.
          }
          else if optInStatusType == UserOptInStatusEnum.PunchCardSession.hashValue{
            
            // Code to create dafault array for the Default HpChart.
            self.prepareDefaultHpChartViewData()
            
            // Code to call method to create HpChart.
            self.createHealthPointBarChartGraph()

            viewLoggedUserHealthPointView.hidden = true

            // Code to call visit left method
            var visitLeft = "0"
            if let leftVisit = optInViewDataDict["visitLeft"] as? String{
              visitLeft = leftVisit
            }
            
            // Code to call for totalSession.
            var totalSession = "0"
            if let total = optInViewDataDict["totalSession"] as? String{
              totalSession = total
            }
            
            // Code to update the logged user OptIn status view for the PunchCard case.
            self.setPunchCardSessionButtonViewForVisitLeft(visitLeft, ForSession: totalSession)
          }
          else if optInStatusType == UserOptInStatusEnum.HideHpView.hashValue{
            // Code to Hide the HpChart View.
            hpChartViewHeightConstraint.constant = 0
          }
          
        }
      }
    }
    else{
      // Code to UnHide LoginView for the OptIn .
      viewLoginView.hidden = false
      buttonLogin.hidden = false
      
      buttonLogin.setTitle("LOG IN TO VIEW", forState: UIControlState.Normal)
      buttonLogin.tag = 101 // For OptIn View click.
      
      // Code to create dafault array for the Default HpChart.
      self.prepareDefaultHpChartViewData()
      
      // Code to call method to create HpChart.
      self.createHealthPointBarChartGraph()
    }
  }
  
  
  func setPunchCardSessionButtonViewForVisitLeft(visitLeft: String, ForSession totalSession: String) {
    // Code to UnHide LoginView for the OptIn .
    viewLoginView.hidden = false
    buttonLogin.hidden = false
    labelPunchCardSessionLeft.hidden = false
    buttonLogin.tag = 301 // For Punch Card Session click.

    var buyMoreFlag = false
    var totalCardSession = 0
    var leftCardSession = 0
    var usedCardSession = 0

    if totalSession.characters.count > 0{
      totalCardSession = Int(totalSession)!
    }
    if visitLeft.characters.count > 0{
      leftCardSession = Int(visitLeft)!
    }
    usedCardSession = totalCardSession - leftCardSession
    
    if leftCardSession == 0{
      buyMoreFlag = true
    }
    else{
      buyMoreFlag = false

      let buttonWidth = Int(self.view.frame.size.width - 60) // Int(buttonLogin.frame.size.width)
      let filledWidth = (buttonWidth * usedCardSession) / 100
      
      let upperLayerButton = UIButton(frame: CGRectMake(0, 0, CGFloat(filledWidth), CGFloat(40)))
      upperLayerButton.tag = 301 // For Punch Card Session click.
      upperLayerButton.backgroundColor = UsedPunchCardSessionFilledColor
      upperLayerButton.addTarget(self, action: #selector(MVPDashboardViewController.loginViewBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
      
      let path = UIBezierPath(roundedRect:upperLayerButton.bounds, byRoundingCorners:[.TopLeft, .BottomLeft], cornerRadii: CGSizeMake(14, 14))
      let maskLayer = CAShapeLayer()
      maskLayer.path = path.CGPath
      upperLayerButton.layer.mask = maskLayer
      
      buttonLogin.backgroundColor = UnUsedPunchCardSessionFilledColor
      buttonLogin.addSubview(upperLayerButton)
    }
    
    if buyMoreFlag == true{
      buttonLogin.setTitle("BUY MORE", forState: UIControlState.Normal)
      labelPunchCardSessionLeft.text = "Time to purchase some new sessions!"
    }
    else{
      buttonLogin.setTitle("", forState: UIControlState.Normal)
      labelPunchCardSessionLeft.text = "You've used \(usedCardSession) of \(totalCardSession) punchcard sessions."
    }
    
  }
  
  /*
   * createHealthPointBarChartGraph method to create user Health point Bar Chart Graph for logged user earned point.
   */
  // MARK:  createHealthPointBarChartGraph method.
  func createHealthPointBarChartGraph() {
    viewHealthPointBarChartView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
    let chartFrameWidth = (self.view.frame.size.width / 2)
    let chartFrame = CGRectMake(0.0, 0.0, chartFrameWidth, 120)
    let chart = BarChartViewModel.createBarChartViewWithFrame(chartFrame) as SimpleBarChart
    chart.delegate = self
    chart.dataSource = self
    chart.incrementValue = 100.0//CGFloat(BarChartViewModel.getChartYlableIncrementValue(arrayOfGraphYlabelValues))
    chart.reloadData()
    viewHealthPointBarChartView.willRemoveSubview(chart)
    viewHealthPointBarChartView.addSubview(chart)
    
    labelTotalHealthPointEarned.text = "\(earnedPoint)"
    labelUntilNextLevelRemainingPoint.text = "\(nextLevelPoint)"
  }
  
  /*
   * prepareDefaultHpChartViewData method to prepare Dafault HpChart view data info.
   */
  // MARK:  prepareDefaultHpChartViewData method.
  func prepareDefaultHpChartViewData() {
    self.arrayOfGraphYlabelValues = [100, 200, 400, 600]
    self.arrayOfGraphXlabelValues = ["Level 1", "Level 2", "Level 3", "Level 4"]
    self.arrayOfGraphEarnedPointYlabelValues = BarChartViewModel.createArrayOfErnedPointArrayForPointLevelByEarnedLevel(self.arrayOfGraphYlabelValues, with: 0)
    
    self.earnedPoint = 0
    self.nextLevelPoint = BarChartViewModel.getNextLevelPointOfErnedPointBy(self.arrayOfGraphYlabelValues, with: earnedPoint)
  }
  
  
  
  
  
  
  
  
  // MARK:  healthRewardAccountBtnClicked method.
  @IBAction func healthRewardAccountBtnClicked(sender:UIButton!) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPVIEWCONTROLLER) as! MVPMyMVPViewController
    mvpMyMVPViewController.arrayOfHealthPointLevelObjects = self.arrayOfHealthPointLevelObjects
    mvpMyMVPViewController.earnedPoint = self.earnedPoint
    self.navigationController?.pushViewController(mvpMyMVPViewController, animated: true)
  }
  
  // MARK:  notificationAlertBellBtnClicked method.
  @IBAction func notificationAlertBellBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
  
  // MARK:  changeLocationBtnClicked method.
  @IBAction func changeLocationBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToChangeLocationViewControllerFrom(self)
  }
  
  // MARK:  loginViewBtnClicked method.
  @IBAction func loginViewBtnClicked(sender:UIButton!) {
    let btnTag = sender.tag
    switch btnTag {
    case 101:
      NavigationViewManager.instance.navigateToLoginViewControllerFrom(self)
      
    case 201: // For OptIn View
      self.navigateToAccountLinksViewControllerFor(optInPageURL)
      
    case 301: // For Punch Card
      self.navigateToAccountLinksViewControllerFor(purchasePunchCardPageURL)
      
    default:
      print("default")
    }
  }
  
  // MARK:  loginViewBtnClicked method.
  @IBAction func upcomingClassesBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToScheduleViewControllerFrom(self)
  }
  
  // MARK:  checkInViewBtnClicked method.
  @IBAction func checkInViewBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToCheckInViewControllerFrom(self)
  }
  
  // MARK:  workoutViewBtnClicked method.
  @IBAction func workoutViewBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToTrackWorkoutViewControllerFrom(self)
  }
  
  // MARK:  contactUsViewBtnClicked method.
  @IBAction func contactUsViewBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToContactHourViewControllerFrom(self)
  }
  
  // MARK:  navigateToAccountLinksViewControllerFor method.
  func navigateToAccountLinksViewControllerFor(urlLink: String) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let viewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPACCOUNTLINKSVIEWCONTROLLER) as! MVPMyMVPAccountLinksViewController
    viewController.accountLinkUrlString = urlLink
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  // MARK:  homeButtonTapped method.
  @IBAction func homeButtonTapped(sender: UIButton){
    
    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      if DashboardViewModel.validateDashoboardApiStatusForExecution() == true{
        if self.siteId.characters.count > 0{
          self.loaderFlag = true

          // Code to show progress loader with Loading... message in the progress loader.
          HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
          
          // Code to execute dashboard screen api endpoint services to fetch by default site id.
          self.executeDashboardInfoApiFor(self.siteId)
        }
      }
      else{
        // Code to show progress loader with Loading... message in the progress loader.
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
        
        let triggerTime = (Int64(NSEC_PER_SEC) * 2)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
          // Code to hide progress hud.
          HUD.hide(animated: true)
        })
      }
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
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
        // Code to remove drawer tableview from self view
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
  
  
  
  
  
  
  // MARK:  executeSiteClassFavouriteOrUnFavouriteApiByFavourite method.
  func executeSiteClassFavouriteOrUnFavouriteApiByFavourite(favFlag: Bool, and exerciseClass: ExerciseClass) {
    let inputField = ExerciseClassViewModel.prepareMarkFavouriteOrUnFavouriteSiteClassApiRequestParamBy(exerciseClass, and: favFlag)
    
    var apiFlag = false
    var title = ""
    var message = ""
    
    // Code to execute the SetFavorites api for Site Class.
    ExerciseClassService.setFavouriteToScheduleExerciseClassesBy(inputField, favouriteFlag: favFlag, completion: { (responseStatus, responseData) -> () in
      
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
        
        if apiFlag == true{
          if favFlag ==  true{
            // Code to update ExerciseClass class model favorite field value.
            exerciseClass.userFavourite = false
            
            // Code to update favorite field for the Site Class from local cache database table.
            ScheduleSiteClassViewModel.updateSiteClassFavouriteFlagForSiteClass(exerciseClass, forSiteClassType: SiteClassesTypeEnum.ByDate, withFavoriteStatus: false)
          }
          else{
            // Code to update ExerciseClass class model favorite field value.
            exerciseClass.userFavourite = true
            
            // Code to update favorite field for the Site Class from local cache database table.
            ScheduleSiteClassViewModel.updateSiteClassFavouriteFlagForSiteClass(exerciseClass, forSiteClassType: SiteClassesTypeEnum.ByDate, withFavoriteStatus: true)
          }
        }
        else{
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
        
        // Code to notify table view for reload data.
        self.tableViewDashboardList.reloadData()
      }
      
    })
  }
  
  // MARK:  markSiteClassUserFavouriteBtnClicked method.
  func markSiteClassUserFavouriteBtnClicked(sender:UIButton!) {
    let indexTag = sender.tag
    let exerciseClassObject: ExerciseClass = arrayOfExerciseSiteClass[indexTag]
    let favouriteFlag = exerciseClassObject.userFavourite! as Bool
    
    // Code to validate site class is laready marked favourite or not.
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
    
    // Code to call api method after certain delay.
    let triggerTime = (Int64(NSEC_PER_SEC) * 1)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
      self.executeSiteClassFavouriteOrUnFavouriteApiByFavourite(favouriteFlag, and: exerciseClassObject)
    })
  }
  
  
  
  
  /*
   * addToCalenderBtnClicked method to add class event into the device calendar and update the UI in the main thread.
   * If class event is already added into the device calendar by validate class event identifier from user deafult to event kit then remove the event and update the UI in main thread.
   */
  // MARK:  addToCalenderBtnClicked method.
  func addToCalenderBtnClicked(sender:UIButton!) {
    let calenderIndexTag = sender.tag
    let exerciseClassObject: ExerciseClass = arrayOfExerciseSiteClass[calenderIndexTag]
    
    // Code to check class event is scheduled in device calendar event or not according to set active, inactive calendar background image to cell.buttonCalender
    if ExerciseClassViewModel.checkClassEventScheduleFromEventKit(exerciseClassObject){
      
      // Code to show alert dialogue message when event was already added into device calender.
      self.showAlerrtDialogueWithTitle(NSLocalizedString(ALERTTITLE, comment: ""), AndErrorMsg: NSLocalizedString(EVENTALREADYADDEDMSG, comment: ""))
    }
    else{
      
      // Code to initiate instance object for EKEventStore.
      let calendarStore = EKEventStore()
      calendarStore.requestAccessToEntityType(.Event) {(granted, error) in
        
        if !granted {
          dispatch_async(dispatch_get_main_queue(), {
            // Code to show alert dialogue to enable Calendar permission for app from devicve setting of app.
            self.showAlerrtDialogueWithTitle(NSLocalizedString(ALERTTITLE, comment: ""), AndErrorMsg: NSLocalizedString(PERMISSIONALERTMESSAGE, comment: ""))
          })
        }
        else{
          let startDate = exerciseClassObject.classStartTime! as String
          let endDate = exerciseClassObject.classEndTime! as String
          
          // Code to prepare EKEvent instance with information by ExerciseClass object information.
          let classEvent = EKEvent(eventStore: calendarStore)
          classEvent.title = exerciseClassObject.className!
          classEvent.location = exerciseClassObject.classLocation
          classEvent.startDate = ScheduleViewModel.getSiteClassStartTimeDate(startDate)
          classEvent.endDate = ScheduleViewModel.getSiteClassStartTimeDate(endDate)
          classEvent.calendar = calendarStore.defaultCalendarForNewEvents
          
          do {
            // Code to saveEvent by EKEventStore method of EKEvent instance.
            try calendarStore.saveEvent(classEvent, span: .ThisEvent, commit: true)
            let savedEventId = classEvent.eventIdentifier // Save event id to access this particular event later
            
            // Code to saved class event savedEventId into user default on classEventKey for future use.
            let classEventKey = String(format: "Event%@", exerciseClassObject.classid! as String)
            NSUserDefaults.standardUserDefaults().setValue(savedEventId, forKey: classEventKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // Code to upate UI in the Main thread after EventKit operation.
            dispatch_async(dispatch_get_main_queue()) {
              
              // Code to notify tableViewMyMvpScheduleClasses to call UITableView datasource and delegate methods.
              self.tableViewDashboardList.reloadData()
            }
          }
          catch {
            // Display error to user
          }
        }
        
      }
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



/*
 * Extension of MVPDashboardViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in LoginViewController.
 */
// MARK:  Extension of MVPDashboardViewController by UITableView DataSource & Delegates method.
extension MVPDashboardViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 40.0
  }
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    /*
     * Code to return number of rows for the Site Class based on device type to display in proper size.
     */
    if DeviceType.IS_IPHONE_5 {
      if arrayOfExerciseSiteClass.count > 2{
        return 2
      }
      else{
        return arrayOfExerciseSiteClass.count
      }
    }
    else if DeviceType.IS_IPHONE_6 {
      if arrayOfExerciseSiteClass.count > 5{
        return 5
      }
      else{
        return arrayOfExerciseSiteClass.count
      }
    }
    else if DeviceType.IS_IPHONE_6P {
      if arrayOfExerciseSiteClass.count > 7{
        return 7
      }
      else{
        return arrayOfExerciseSiteClass.count
      }
    }
    else{
      return arrayOfExerciseSiteClass.count
    }
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPScheduleClassByDateTableViewCell = (tableView.dequeueReusableCellWithIdentifier(SCHEDULECLASSBYDATETABLEVIEWCELL) as? MyMVPScheduleClassByDateTableViewCell!)!
    
    let exerciseClassObject: ExerciseClass = arrayOfExerciseSiteClass[indexPath.row]
    cell.labelClassName.text = exerciseClassObject.className
    cell.labelClassDate.text = "  \( ScheduleViewModel.getSiteClassFormattedDateString(exerciseClassObject.classStartTime!) as String)"
    cell.labelClassStartTime.text = ScheduleViewModel.getTimeStringFromDateString(exerciseClassObject.classStartTime!)
    
    cell.buttonCalender.tag = indexPath.row
    cell.buttonCalender.addTarget(self, action: #selector(MVPDashboardViewController.addToCalenderBtnClicked(_:)), forControlEvents: .TouchUpInside)
    cell.buttonUnLoggedCalender.tag = indexPath.row
    cell.buttonUnLoggedCalender.addTarget(self, action: #selector(MVPDashboardViewController.addToCalenderBtnClicked(_:)), forControlEvents: .TouchUpInside)
    
    if ExerciseClassViewModel.checkClassEventScheduleFromEventKit(exerciseClassObject){
      cell.imageViewCalendarIcon.image = UIImage(named: "calenderactive.png")
      cell.imageViewUnLoggedCalendarIcon.image = UIImage(named: "calenderactive.png")
    }
    else{
      cell.imageViewCalendarIcon.image = UIImage(named: "calenderinactive.png")
      cell.imageViewUnLoggedCalendarIcon.image = UIImage(named: "calenderinactive.png")
    }
    
    // Code for Site Class favourite.
    cell.buttonFavourite.tag = indexPath.row
    cell.buttonFavourite.addTarget(self, action: #selector(MVPDashboardViewController.markSiteClassUserFavouriteBtnClicked(_:)), forControlEvents: .TouchUpInside)
    if exerciseClassObject.userFavourite == true{
      cell.imageViewFavouriteIcon.image = UIImage(named: "sitefavourite")
    }
    else{
      cell.imageViewFavouriteIcon.image = UIImage(named: "siteunfavourite")
    }
    
    // When user logged-out hide favorite star view.
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == false{
      cell.viewLoggedUserStarCalendarView.hidden = true
      cell.viewUnLoggedUserCalendarView.hidden = false
    }
    else{
      cell.viewUnLoggedUserCalendarView.hidden = true
      cell.viewLoggedUserStarCalendarView.hidden = false
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Code to call notify method of UItableView to reload table view cell data.
    tableViewDashboardList.reloadData()
    let exerciseClassObject: ExerciseClass = arrayOfExerciseSiteClass[indexPath.row]
    
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPSiteClassDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPSITECLASSDETAILVIEWCONTROLLER) as! MVPMyMVPSiteClassDetailViewController
    mvpMyMVPSiteClassDetailViewController.siteClass = exerciseClassObject
    self.navigationController?.pushViewController(mvpMyMVPSiteClassDetailViewController, animated: true)
  }
  
}


/*
 * Extension of MVPDashboardViewController to add SimpleBarChart prototcol SimpleBarChartDataSource and SimpleBarChartDelegate.
 * Override the protocol method to add BarChartGraph in MVPDashboardViewController.
 */
// MARK:  Extension of MVPDashboardViewController by SimpleBarChart DataSource & Delegates method.
extension MVPDashboardViewController: SimpleBarChartDataSource, SimpleBarChartDelegate{
  
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


// MARK:  Extension of MVPDashboardViewController by DrawerTableViewDelegate method.
extension MVPDashboardViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.LogOut{
      self.handleOuterViewWithDrawerTapGesture()
      
      // Code to call updateDashboardScreenForUpdatedUnLoggedUserStatus method for un logged user updated status.
      self.updateDashboardScreenForUpdatedUnLoggedUserStatus()
    }
    else{
      self.popDrawerView()
    }
  }
}


// MARK:  Extension of MVPDashboardViewController by UITableView DataSource & Delegates method.
extension MVPDashboardViewController: CLLocationManagerDelegate{
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("didUpdateLocations called")
    let location = locations.last
    
    dispatch_async(dispatch_get_main_queue()) {
      // Code to save current location co-ordinates and mark notification to the tableViewMyMvpSiteClub by reloadData method.
      var userCordinate = [String: String]()
      let lat = location!.coordinate.latitude
      let long = location!.coordinate.longitude
      userCordinate["lat"] = "\(lat)"
      userCordinate["lang"] = "\(long)"
      
      NSUserDefaults.standardUserDefaults().setValue(userCordinate, forKey: "currentlocation")
      NSUserDefaults.standardUserDefaults().synchronize()
      
      // Code to validate for Site Club array count for Default Site club.
      if self.arrayOfSiteClubObject.count > 0{
        
        let changeLocationStatusFlag = UserViewModel.getChangeLocationStatus() as Bool
        if changeLocationStatusFlag == false{
          self.setNearestSiteClubAsDefaultSiteClub()
        }
      }
      
    }
  }
}


extension MVPDashboardViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    print("MVPDashboardViewController announcementDelegate")
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    print("MVPDashboardViewController badgeCountDelegate")
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}

