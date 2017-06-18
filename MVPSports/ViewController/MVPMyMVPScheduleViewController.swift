
//
//  MVPMyMVPScheduleViewController.swift
//  MVPSports
//
//  Created by Chetu India on 22/08/16.
//

import UIKit
import PKHUD
import EventKit
import SDWebImage


class MVPMyMVPScheduleViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewMyMvpScheduleClasses: UITableView!
  @IBOutlet weak var labelNoSiteClassAvailableLabel: UILabel!
  @IBOutlet weak var labelSiteName: UILabel!
  @IBOutlet weak var buttonByDate: UIButton!
  @IBOutlet weak var buttonByInstructor: UIButton!
  @IBOutlet weak var buttonByClass: UIButton!
  @IBOutlet weak var buttonMySchedule: UIButton!
  @IBOutlet weak var labelBadgeCount: UILabel!

  @IBOutlet weak var viewSearchSiteClassView: UIView!
  @IBOutlet weak var viewSearchHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var searchBarSiteClasses: UISearchBar!
  @IBOutlet weak var viewLoginView: UIView!
  @IBOutlet weak var buttonLogin: UIButton!
  
  // MARK:  instance variables, constant decalaration and define with some values.
  var dimView = UIView()
  var tableview = DrawerTableView()
  
  var myMvpScheduleClassArrayByDate = [ExerciseClass]()
  var myMvpScheduleClassArrayByInstructor = [ExerciseClass]()
  var myMvpScheduleClassArrayByClass = [ExerciseClass]()
  var myMvpScheduleClassArrayByMySchedule = [ExerciseClass]()

  var myMvpScheduleClassArray = [ExerciseClass]()
  var arrayOfScheduleClassSectionObject = [String]()
  var dictionaryOfScheduleArrayForSectionObject = [String: [ExerciseClass]]()
  
  var selectedClassSection = 0
  var typeOfSiteClass = SiteClassesTypeEnum.ByDate
  
  var userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
  var tableViewListCurrentStatusDict = [String: AnyObject]()
  
  var siteId = ""
  var siteName = ""
  var memberId = ""
  
  var apiLoaderFlag = false
  var unFavoriteMyScheduleClass = false
  var siteClassFilterScheduleFlag = true

  
  /*
   * receiveScheduleNotificationObserverBy method .
   */
  // MARK:  receiveScheduleNotificationObserverBy method.
  func receiveScheduleNotificationObserverBy(notification: NSNotification) {
    var currentViewApiObserverFlag = false
    
    if notification.name == "ScheduleSiteClassesByDate"{
      if let respDict = notification.object as? [String: AnyObject]{
        print(respDict)
      }
      
      if typeOfSiteClass == SiteClassesTypeEnum.ByDate{
        currentViewApiObserverFlag = true
      }
    }
    else if notification.name == "ScheduleSiteClassesByInstructor"{
      if let respDict = notification.object as? [String: AnyObject]{
        print(respDict)
      }
      
      if typeOfSiteClass == SiteClassesTypeEnum.ByInstructor{
        currentViewApiObserverFlag = true
      }
    }
    else if notification.name == "ScheduleSiteClassesByActivityClasses"{
      if let respDict = notification.object as? [String: AnyObject]{
        print(respDict)
      }
      
      if typeOfSiteClass == SiteClassesTypeEnum.ByActivityClass{
        currentViewApiObserverFlag = true
      }
    }
    else if notification.name == "ScheduleSiteClassesByMySchedule"{
      if let respDict = notification.object as? [String: AnyObject]{
        print(respDict)
      }
      
      if typeOfSiteClass == SiteClassesTypeEnum.MySchedule{
        currentViewApiObserverFlag = true
      }
    }
    
    if currentViewApiObserverFlag == true{
      dispatch_async(dispatch_get_main_queue()) {
        if self.apiLoaderFlag == true{
          self.apiLoaderFlag = false
          
          // Code to hide progress hud.
          HUD.hide(animated: true)
          self.updateScheduleScreenForNotificationObserverObjectBy((notification.object as? [String: AnyObject])!)
        }
        else{
          // HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))
          
          // Code to call fetchUserCheckInScheduleExerciseClasses method after certain one second delay.
          let triggerTime = (Int64(NSEC_PER_SEC) * 1)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            
            self.siteClassFilterScheduleFlag = false
            self.updateScheduleScreenForNotificationObserverObjectBy((notification.object as? [String: AnyObject])!)
          })
        }
      }
      
    }
  }
  
  // MARK:  updateScheduleScreenForNotificationObserverObjectBy method.
  func updateScheduleScreenForNotificationObserverObjectBy(object: [String: AnyObject]) {
    dispatch_async(dispatch_get_main_queue()) {
      
      // Code to fetch Site Classes from local cache sqlite database.
      ExerciseClassViewModel.fetchSiteClassesFromLocalCacheByType(self.typeOfSiteClass, completion: { (exerciseSiteClassArrayFromLocal) -> () in

        self.myMvpScheduleClassArray = self.prepareTableViewSiteClassArrayFrom(self.typeOfSiteClass, siteClassesArrayFromLocal: exerciseSiteClassArrayFromLocal)
        
        // Method call to update my schedule list view.
        self.preparedScreenDesign()
      })
    
    }
  }


  
  
  
  
  // MARK:  setDefaultViewForTheScreen method.
  func setDefaultViewForTheScreen() {
    labelNoSiteClassAvailableLabel.text = NSLocalizedString(NOCLASSESAVAILABLEMSG, comment: "")

    // Code to set default Site Class selection to ByDate.
    typeOfSiteClass = SiteClassesTypeEnum.ByDate
    
    // Code to hide loginView
    viewLoginView.hidden = true
    buttonLogin.layer.cornerRadius = VALUEFIFTEENCORNERRADIUS
    searchBarSiteClasses.delegate = self
    
    // Method call to initiate List View section and cell position.
    self.setDefaultListOfTableViewStatus()
  }

  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Code to call method to load default view for the screen.
    self.setDefaultViewForTheScreen()
    
    // UI in Main thread.
    dispatch_async(dispatch_get_main_queue()) {
      // Call method to set UI of screen.
      self.prepareSiteClassesTypeButtonDesignFor(self.typeOfSiteClass)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
    RemoteNotificationObserverManager.sharedInstance.delegate = self

    // Code to register observer on NSNotificationCenter singleton instance of application for SiteClass and UserOptInStatus.
    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MVPMyMVPScheduleViewController.receiveScheduleNotificationObserverBy(_:)) , name: "ScheduleSiteClassesByDate", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MVPMyMVPScheduleViewController.receiveScheduleNotificationObserverBy(_:)) , name: "ScheduleSiteClassesByInstructor", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MVPMyMVPScheduleViewController.receiveScheduleNotificationObserverBy(_:)) , name: "ScheduleSiteClassesByActivityClasses", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MVPMyMVPScheduleViewController.receiveScheduleNotificationObserverBy(_:)) , name: "ScheduleSiteClassesByMySchedule", object: nil)
    
    userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    
    // Code to call method to fetch user default Site Club data information.
    self.getUserDefaultSiteClubData()
    
    if self.validateViewForDesign() == true{
      // Code to fetch Site Classes from local cache sqlite database.
      ExerciseClassViewModel.fetchSiteClassesFromLocalCacheByType(typeOfSiteClass, completion: { (exerciseSiteClassArrayFromLocal) -> () in
        
        self.myMvpScheduleClassArray = self.prepareTableViewSiteClassArrayFrom(self.typeOfSiteClass, siteClassesArrayFromLocal: exerciseSiteClassArrayFromLocal)

        // Method call to update my schedule list view.
        self.preparedScreenDesign()
        
        // Code to call method executeApiServiceMethodForMyMvpSchedule to initiate api service for My MVP Schedule screen.
        self.executeApiServiceMethodForMyMvpSchedule()
      })

    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    // Code to remove added register observer from .
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "ScheduleSiteClassesByDate", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "ScheduleSiteClassesByInstructor", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "ScheduleSiteClassesByActivityClasses", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "ScheduleSiteClassesByMySchedule", object: nil)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  
  
  // MARK:  prepareTableViewSiteClassArrayFrom method.
  func prepareTableViewSiteClassArrayFrom(type: SiteClassesTypeEnum, siteClassesArrayFromLocal: [ExerciseClass]) -> [ExerciseClass] {
    var siteClassesForTableView = [ExerciseClass]()
    
    if type == SiteClassesTypeEnum.ByDate{
      if siteClassesArrayFromLocal.count > 0{
        myMvpScheduleClassArrayByDate.removeAll()
        myMvpScheduleClassArrayByDate = siteClassesArrayFromLocal
        siteClassesForTableView = myMvpScheduleClassArrayByDate
      }
      else{
        siteClassesForTableView = myMvpScheduleClassArrayByDate
      }
    }
    else if type == SiteClassesTypeEnum.ByInstructor{
      if siteClassesArrayFromLocal.count > 0{
        myMvpScheduleClassArrayByInstructor.removeAll()
        myMvpScheduleClassArrayByInstructor = siteClassesArrayFromLocal
        siteClassesForTableView = myMvpScheduleClassArrayByInstructor
      }
      else{
        siteClassesForTableView = myMvpScheduleClassArrayByInstructor
      }
    }
    else if type == SiteClassesTypeEnum.ByActivityClass{
      if siteClassesArrayFromLocal.count > 0{
        myMvpScheduleClassArrayByClass.removeAll()
        myMvpScheduleClassArrayByClass = siteClassesArrayFromLocal
        siteClassesForTableView = myMvpScheduleClassArrayByClass
      }
      else{
        siteClassesForTableView = myMvpScheduleClassArrayByClass
      }
    }
    else if type == SiteClassesTypeEnum.MySchedule{
      if siteClassesArrayFromLocal.count > 0{
        unFavoriteMyScheduleClass = false
        myMvpScheduleClassArrayByMySchedule.removeAll()
        myMvpScheduleClassArrayByMySchedule = siteClassesArrayFromLocal
        siteClassesForTableView = myMvpScheduleClassArrayByMySchedule
      }
      else{
        if unFavoriteMyScheduleClass == true{
          unFavoriteMyScheduleClass = false
          myMvpScheduleClassArrayByMySchedule = siteClassesArrayFromLocal
          siteClassesForTableView = myMvpScheduleClassArrayByMySchedule
        }
        else{
          siteClassesForTableView = myMvpScheduleClassArrayByMySchedule
        }
      }
    }
    
    return siteClassesForTableView
  }
  
  
  
  // MARK:  setDefaultListOfTableViewStatus method.
  func setDefaultListOfTableViewStatus() {
    var defaultCurrentSection = [String: Int]()
    defaultCurrentSection["topSection"] = 0
    defaultCurrentSection["selectedSection"] = 0

    var defaultCloseSection = [String: Int]()
    defaultCloseSection["topSection"] = 0
    defaultCloseSection["selectedSection"] = -1
    
    tableViewListCurrentStatusDict["byDate"] = defaultCurrentSection
    tableViewListCurrentStatusDict["byInstructor"] = defaultCloseSection
    tableViewListCurrentStatusDict["bySiteClass"] = defaultCloseSection
    tableViewListCurrentStatusDict["byUserFavorite"] = defaultCurrentSection
  }
  
  func setTableViewTopSection(topSection: Int, forType type: SiteClassesTypeEnum) {
    var currentSection = [String: Int]()
    currentSection["topSection"] = topSection
    currentSection["selectedSection"] = selectedClassSection

    switch type {
    case SiteClassesTypeEnum.ByDate:
      tableViewListCurrentStatusDict["byDate"] = currentSection
      
    case SiteClassesTypeEnum.ByInstructor:
      tableViewListCurrentStatusDict["byInstructor"] = currentSection
      
    case SiteClassesTypeEnum.ByActivityClass:
      tableViewListCurrentStatusDict["bySiteClass"] = currentSection
      
    case SiteClassesTypeEnum.MySchedule:
      tableViewListCurrentStatusDict["byUserFavorite"] = currentSection
    }
  }
  
  func getSelectedSectionIndexFor(type: SiteClassesTypeEnum) -> Int {
    var selectedSection = 0
    var currentTableViewSectionStatus = [String: Int]()
    
    switch type {
    case SiteClassesTypeEnum.ByDate:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["byDate"] as! [String: Int]
      
    case SiteClassesTypeEnum.ByInstructor:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["byInstructor"] as! [String: Int]
      
    case SiteClassesTypeEnum.ByActivityClass:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["bySiteClass"] as! [String: Int]
      
    case SiteClassesTypeEnum.MySchedule:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["byUserFavorite"] as! [String: Int]
    }
    
    selectedSection = currentTableViewSectionStatus["selectedSection"]!
    return selectedSection
  }

  func getTopSectionIndexFor(type: SiteClassesTypeEnum) -> Int {
    var topSection = 0
    var currentTableViewSectionStatus = [String: Int]()
    
    switch type {
    case SiteClassesTypeEnum.ByDate:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["byDate"] as! [String: Int]
      
    case SiteClassesTypeEnum.ByInstructor:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["byInstructor"] as! [String: Int]
      
    case SiteClassesTypeEnum.ByActivityClass:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["bySiteClass"] as! [String: Int]
      
    case SiteClassesTypeEnum.MySchedule:
      currentTableViewSectionStatus = tableViewListCurrentStatusDict["byUserFavorite"] as! [String: Int]
    }
    
    topSection = currentTableViewSectionStatus["topSection"]!
    return topSection
  }

  
  
  /*
   * validateViewForDesign method to validate screen for the loader design or not.
   */
  // MARK:  validateViewForDesign method.
  func validateViewForDesign() -> Bool {
    var flag = true
    if typeOfSiteClass == SiteClassesTypeEnum.MySchedule{
      if userLoginFlag == false{
        flag = false
      }
    }
    return flag
  }
  
  
  
  
  

  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    
    // Code to call method to update UI for my schedule Site Classes list.
    self.prepareScheduleClassObjectsForTableViewWithSearctString("")
  }
  
  // MARK:  prepareSiteClassesTypeButtonDesignFor method.
  func  prepareSiteClassesTypeButtonDesignFor(siteClassType: SiteClassesTypeEnum) {
    buttonByDate.backgroundColor = UnSelectSiteClassTypeBackgroundColor
    buttonByDate.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    
    buttonByInstructor.backgroundColor = UnSelectSiteClassTypeBackgroundColor
    buttonByInstructor.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    
    buttonByClass.backgroundColor = UnSelectSiteClassTypeBackgroundColor
    buttonByClass.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    
    buttonMySchedule.backgroundColor = UnSelectSiteClassTypeBackgroundColor
    buttonMySchedule.setTitleColor(LIGHTGRAYCOLOR, forState: UIControlState.Normal)
    
    switch siteClassType {
    case SiteClassesTypeEnum.ByDate:
      self.prepareSearchViewFor(false)
      
      buttonByDate.backgroundColor = WHITECOLOR
      buttonByDate.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)
      
    case SiteClassesTypeEnum.ByInstructor:
      self.prepareSearchViewFor(true)

      buttonByInstructor.backgroundColor = WHITECOLOR
      buttonByInstructor.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)
      
    case SiteClassesTypeEnum.ByActivityClass:
      self.prepareSearchViewFor(true)

      buttonByClass.backgroundColor = WHITECOLOR
      buttonByClass.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)
      
    case SiteClassesTypeEnum.MySchedule:
      self.prepareSearchViewFor(false)

      buttonMySchedule.backgroundColor = WHITECOLOR
      buttonMySchedule.setTitleColor(BLACKCOLOR, forState: UIControlState.Normal)
    }
  }
  
  // MARK:  prepareSearchViewFor method.
  func prepareSearchViewFor(showFlag: Bool)  {
    if showFlag == true{
      viewSearchSiteClassView.hidden = false
      viewSearchHeightConstraint.constant = 45.0
    }
    else{
      viewSearchSiteClassView.hidden = true
      viewSearchHeightConstraint.constant = 0.0
    }
  }
  
  // MARK:  getUserDefaultSiteClubData method.
  func getUserDefaultSiteClubData(){
    if userLoginFlag == true{ // When user is logged in
      var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
      if let siteid = loggedUserDict["Siteid"]{
        siteId = siteid as String
      }
      if let memberid = loggedUserDict["memberId"]{
        memberId = memberid as String
      }
      if let sitename = loggedUserDict["siteName"]{
        siteName = sitename
      }
    }
    else{ // When user is not logged in
      var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
      if let siteid = unLoggedUserDict["siteId"]{
        siteId = siteid as String
      }
      if let sitename = unLoggedUserDict["siteName"]{
        siteName = sitename as String
      }
    }
    
    // UI in Main thread.
    dispatch_async(dispatch_get_main_queue()) {
      // Code to set text to site name label.
      self.labelSiteName.text = self.siteName
    }
  }
  
  // MARK;  prepareScheduleClassObjectsForTableViewWithSearctString method.
  func prepareScheduleClassObjectsForTableViewWithSearctString(searchString: String) {
    arrayOfScheduleClassSectionObject = [String]()
    arrayOfScheduleClassSectionObject = ExerciseClassViewModel.createUniqueArraySectionStringOfScheduleClassFromListOf(myMvpScheduleClassArray, By: typeOfSiteClass, with: searchString)
    
    dictionaryOfScheduleArrayForSectionObject = [String: [ExerciseClass]]()
    for sectionObject in arrayOfScheduleClassSectionObject {
      let arrayOfExerciseClass: [ExerciseClass] = ExerciseClassViewModel.createArrayOfExerciseClassForSectionFromListOf(myMvpScheduleClassArray, sectionString: sectionObject, classType: typeOfSiteClass)
      
      if arrayOfExerciseClass.count > 0{
        dictionaryOfScheduleArrayForSectionObject[sectionObject] = arrayOfExerciseClass
      }
      else{
        dictionaryOfScheduleArrayForSectionObject[sectionObject] = [ExerciseClass]()
      }
    }
    
    if arrayOfScheduleClassSectionObject.count > 0{
      if siteClassFilterScheduleFlag == true{
        selectedClassSection = self.getSelectedSectionIndexFor(typeOfSiteClass)
        
        // Code to notify UItableView instance to reload data.
        tableViewMyMvpScheduleClasses.reloadData()

        let topSection = self.getTopSectionIndexFor(typeOfSiteClass)
        if arrayOfScheduleClassSectionObject.count > topSection{
          let indexPath = NSIndexPath(forRow: 0, inSection: topSection)
          tableViewMyMvpScheduleClasses.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.None, animated: false)
        }
      }
      else{
        // Code to notify UItableView instance to reload data.
        tableViewMyMvpScheduleClasses.reloadData()
      }

      self.showOrHideSiteClassesTableViewLabelStatusBy(false)
    }
    else{
      // Code to notify UItableView instance to reload data.
      tableViewMyMvpScheduleClasses.reloadData()

      self.showOrHideSiteClassesTableViewLabelStatusBy(true)
    }
  }
  
  func showOrHideSiteClassesTableViewLabelStatusBy(showFlag: Bool) {
    if showFlag == true{
      labelNoSiteClassAvailableLabel.hidden = false
      labelNoSiteClassAvailableLabel.frame = CGRectMake(labelNoSiteClassAvailableLabel.frame.origin.x, labelNoSiteClassAvailableLabel.frame.origin.y, labelNoSiteClassAvailableLabel.frame.size.width, 50)
    }
    else{
      labelNoSiteClassAvailableLabel.hidden = true
      labelNoSiteClassAvailableLabel.frame = CGRectMake(labelNoSiteClassAvailableLabel.frame.origin.x, labelNoSiteClassAvailableLabel.frame.origin.y, labelNoSiteClassAvailableLabel.frame.size.width, 0)
    }
  }
  
  
  
  
  
  // MARK:  executeApiServiceMethodForMyMvpSchedule method.
  func executeApiServiceMethodForMyMvpSchedule() {
    if myMvpScheduleClassArray.count > 0{ // In Background process.
      if Reachability.isConnectedToNetwork() == true && ScheduleSiteClassViewModel.validateMvpScheduleApiStatusForExecution(typeOfSiteClass) == true {
        
        // Code to execute an Asynchronous call of api endpoint services.
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () -> Void in // Deafult priority background process queue.
          self.executeApiEndpointServicesForMyMvpModule()
        }
      }
    }
    else{
      // Code to check device is connected to internet connection or not.
      if Reachability.isConnectedToNetwork() == true {
        
        if ScheduleSiteClassViewModel.validateMvpScheduleApiStatusForExecution(typeOfSiteClass) == true{
          apiLoaderFlag = true
          
          // Code to show progress loader with Loading... message in the progress loader.
          HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
          
          let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
          dispatch_async(queue) { () -> Void in // Deafult priority background process queue.
            self.executeApiEndpointServicesForMyMvpModule()
          }
        }
      }
      else{
        self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
      }
    }
  }
  
  // MARK:  executeApiEndpointServicesForMyMvpModule method.
  func executeApiEndpointServicesForMyMvpModule() {
    // Code to set Api execution status for the Site Class type.
    ScheduleSiteClassViewModel.setMvpScheduleApiStatusFor(typeOfSiteClass, andStatus: false)
    
    // Code to initiate input param dictionary to fetch Site Class for user Default Site Club.
    var inputField = [String: String]()
    inputField = self.prepareApiRequestBodyForSiteClass()
    
    ScheduleSiteClassViewModel.getSiteClassesOfSiteClubFromApiServerBy(inputField, forSiteClass: typeOfSiteClass)
  }
  
  // MARK:  prepareApiRequestBodyForSiteClass method to prepare api request body parameter.
  func prepareApiRequestBodyForSiteClass() -> [String: String] {
    var inputParam = [String: String]()
    
    switch typeOfSiteClass {
    case SiteClassesTypeEnum.ByDate:
      inputParam["siteid"] = siteId
      
    case SiteClassesTypeEnum.ByInstructor:
      inputParam["Site.SiteId"] = siteId
      inputParam["byClass"] = "false"
      
    case SiteClassesTypeEnum.ByActivityClass:
      inputParam["Site.SiteId"] = siteId
      inputParam["byClass"] = "true"
      
    case SiteClassesTypeEnum.MySchedule:
      inputParam["MemberId"] = memberId
    }
    
    return inputParam
  }

  
  
  
  
  
  
  
  
  
  // MARK:  myScheduleButtonTapped method.
  @IBAction func myScheduleButtonTapped(sender: UIButton){
    // Code to set previous Site Class list by type.
    if arrayOfScheduleClassSectionObject.count > 0{
      if let indexPath = self.tableViewMyMvpScheduleClasses.indexPathsForVisibleRows?[0]{
        
        let sectionNumber = indexPath.section
        self.setTableViewTopSection(sectionNumber, forType: typeOfSiteClass)
      }
    }

    // Code to set view for MySchedule Site Class enumeration.
    typeOfSiteClass = SiteClassesTypeEnum.MySchedule
    self.prepareSiteClassesTypeButtonDesignFor(SiteClassesTypeEnum.MySchedule)
    
    // Code when un logged user dissabled Instructor, Class and My Schdule button for api dependecies.
    if userLoginFlag == false{
      // Code to un-hide loginView
      viewLoginView.hidden = false
    }
    else{
      self.executeSiteClassFilterMethod()
    }
  }
  
  // MARK:  loginViewBtnClicked method.
  @IBAction func loginViewBtnClicked(sender:UIButton!) {
    NavigationViewManager.instance.navigateToLoginViewControllerFrom(self)
  }
  
  /*
   * Method to prepare list of siteClasses based on the type of filteration. Either its Date, Instructor or Class type.
   */
  // MARK:  siteClassByTypeButtonTapped method.
  @IBAction func siteClassByTypeButtonTapped(sender: UIButton){
    // Code to hide loginView.
    viewLoginView.hidden = true
    
    siteClassFilterScheduleFlag = true
    
    if arrayOfScheduleClassSectionObject.count > 0{
      // Code to set previous Site Class list by type.
      if let indexPath = self.tableViewMyMvpScheduleClasses.indexPathsForVisibleRows?[0]{
        let sectionNumber = indexPath.section
        self.setTableViewTopSection(sectionNumber, forType: typeOfSiteClass)
      }      
    }
    
    let tagIndex = sender.tag
    switch tagIndex {
    case 101: // By Date
      typeOfSiteClass = SiteClassesTypeEnum.ByDate
      self.prepareSiteClassesTypeButtonDesignFor(typeOfSiteClass)
      break
      
    case 201: // By Instructor
      typeOfSiteClass = SiteClassesTypeEnum.ByInstructor
      self.prepareSiteClassesTypeButtonDesignFor(typeOfSiteClass)
      break
      
    case 301: // By Activity Class.
      typeOfSiteClass = SiteClassesTypeEnum.ByActivityClass
      self.prepareSiteClassesTypeButtonDesignFor(typeOfSiteClass)
      break
      
    default:
      break
    }
    
    self.executeSiteClassFilterMethod()
  }
  
  // MARK:  executeSiteClassFilterMethod method.
  func executeSiteClassFilterMethod() {
    // Code to set UITableView scrolling contentOffset of current position.
    self.tableViewMyMvpScheduleClasses.setContentOffset(self.tableViewMyMvpScheduleClasses.contentOffset, animated: false)
    
    // Code to fetch Site Classes from local cache sqlite database.
    ExerciseClassViewModel.fetchSiteClassesFromLocalCacheByType(typeOfSiteClass, completion: { (exerciseSiteClassArrayFromLocal) -> () in
      
      self.myMvpScheduleClassArray = self.prepareTableViewSiteClassArrayFrom(self.typeOfSiteClass, siteClassesArrayFromLocal: exerciseSiteClassArrayFromLocal)
      
      // Method call to update my schedule list view.
      self.preparedScreenDesign()
      
      // Code to call method executeApiServiceMethodForMyMvpSchedule to initiate api service for My MVP Schedule screen.
      self.executeApiServiceMethodForMyMvpSchedule()
    })
    
  }
  
 
  
  
  
  
  // MARK:  drawerButtonTapped method.
  @IBAction func drawerButtonTapped(sender: UIButton){
    dimView.frame = self.view.frame
    dimView.backgroundColor = BLACKCOLOR
    dimView.alpha = 0.0
    self.view.addSubview(dimView)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(MVPMyMVPScheduleViewController.handleOuterViewWithDrawerTapGesture))
    dimView.addGestureRecognizer(tap)
    
    let yPoint = CGFloat(80)
    let xPoint = self.view.frame.size.width/2
    tableview = DrawerTableView(frame: CGRectMake(self.view.frame.size.width, yPoint, self.view.frame.size.width/2, self.view.frame.size.height-yPoint), style: .Plain)
    tableview.parentViewController = self
    tableview.drawerDelegate = self
    self.view.addSubview(tableview)
    
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.tableview.frame = CGRectMake(xPoint, yPoint, self.tableview.frame.size.width, self.tableview.frame.size.height)
      self.dimView.alpha = 0.6
      
      }, completion: { finished in
        // Code to
    })
  }
  
  // MARK:  handleOuterViewWithDrawerTapGesture method.
  func handleOuterViewWithDrawerTapGesture() {
    let yPoint = CGFloat(80)
    let xPoint = self.view.frame.size.width
    // Code to change xPoint frame of tableview.
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      self.tableview.frame = CGRectMake(xPoint, yPoint, self.tableview.frame.size.width, self.tableview.frame.size.height)
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

  // MARK:  instructorDetailBtnClicked method.
  func siteClassDetailBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let sectionKey = arrayOfScheduleClassSectionObject[tagIndex] as String
    let exerciseClassArray = dictionaryOfScheduleArrayForSectionObject[sectionKey]
    let exerciseClass = exerciseClassArray![0] as ExerciseClass

    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPSiteClassDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPSITECLASSDETAILVIEWCONTROLLER) as! MVPMyMVPSiteClassDetailViewController
    mvpMyMVPSiteClassDetailViewController.siteClass = exerciseClass
    self.navigationController?.pushViewController(mvpMyMVPSiteClassDetailViewController, animated: true)
  }
  
  // MARK:  instructorDetailBtnClicked method.
  func instructorDetailBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    let sectionKey = arrayOfScheduleClassSectionObject[tagIndex] as String
    let exerciseClassArray = dictionaryOfScheduleArrayForSectionObject[sectionKey]
    let exerciseClass = exerciseClassArray![0] as ExerciseClass
    let instructorName = exerciseClass.classInstructor! as String
    let instructorId = exerciseClass.classInstructorId! as String

    if instructorId.characters.count != 0{
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let mvpMyMVPInstructorDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPINSTRUCTORDETAILVIEWCONTROLLER) as! MVPMyMVPInstructorDetailViewController
      mvpMyMVPInstructorDetailViewController.selectedInstructorName = instructorName
      mvpMyMVPInstructorDetailViewController.selectedInstructorId = instructorId
      self.navigationController?.pushViewController(mvpMyMVPInstructorDetailViewController, animated: true)
    }
    else{
      let message = "\(instructorName) \(NSLocalizedString(NOINSTRUCTORINFORMATION, comment: ""))"
      self.showAlerrtDialogueWithTitle(NSLocalizedString(ALERTTITLE, comment: ""), AndErrorMsg: message)
    }
  }
  
  // MARK:  showSiteClassSectionBtnClicked method.
  func showSiteClassSectionBtnClicked(sender:UIButton!) {
    let tagIndex = sender.tag
    if selectedClassSection == tagIndex{
      selectedClassSection = -1
      tableViewMyMvpScheduleClasses.reloadData()
    }
    else{
      selectedClassSection = tagIndex
      tableViewMyMvpScheduleClasses.reloadData()
      
      let indexPath = NSIndexPath(forRow: 0, inSection: selectedClassSection)
      tableViewMyMvpScheduleClasses.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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
  
  // MARK:  Memory management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  

  
  
  /*
   * addToCalenderBtnClicked method to add class event into the device calendar and update the UI in the main thread.
   * If class event is already added into the device calendar by validate class event identifier from user deafult to event kit then remove the event and update the UI in main thread.
   */
  // MARK:  addToCalenderBtnClicked method.
  func addToCalenderBtnClicked(sender:UIButton!) {
    let calenderIndexTag = sender.tag
    let exerciseClassObjectArray: [ExerciseClass] = dictionaryOfScheduleArrayForSectionObject[arrayOfScheduleClassSectionObject[selectedClassSection] as String]!
    let exerciseClassObject: ExerciseClass = exerciseClassObjectArray[calenderIndexTag]
    
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
              self.tableViewMyMvpScheduleClasses.reloadData()
            }
          }
          catch {
            // Display error to user
          }
          
        }
      }
      
    }
  }
  
  // MARK:  markSiteClassUserFavouriteBtnClicked method.
  func markSiteClassUserFavouriteBtnClicked(sender:UIButton!) {
    let favouriteIndexTag = sender.tag
    let exerciseClassObjectArray: [ExerciseClass] = self.dictionaryOfScheduleArrayForSectionObject[self.arrayOfScheduleClassSectionObject[self.selectedClassSection] as String]!

    let exerciseClassObject: ExerciseClass = exerciseClassObjectArray[favouriteIndexTag]
    let favouriteFlag = exerciseClassObject.userFavourite! as Bool
    
    // Code to validate site class is laready marked favourite or not.
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(UPDATINGMSG, comment: "")))
    
    // Code to call api method after certain delay.
    let triggerTime = (Int64(NSEC_PER_SEC) * 1)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
      self.executeSiteClassFavouriteOrUnFavouriteApiByFavourite(favouriteFlag, and: exerciseClassObject)
    })
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
        
        if apiFlag == true{
          // Code to update favorite and un favorite functionality into local database.
          self.executeFavoriteUnFavoriteApiStatusUpdatesInLocalCacheBy(favFlag, forExerciseClass: exerciseClass)
        }
        else{
          // Code to hide loader with animated.
          HUD.hide(animated: true)

          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
  }
  
  func executeFavoriteUnFavoriteApiStatusUpdatesInLocalCacheBy(favFlag: Bool, forExerciseClass siteClass: ExerciseClass) {
    if favFlag ==  true{ // to Mark unFavorite local
      siteClass.userFavourite = false
      
      if self.typeOfSiteClass == SiteClassesTypeEnum.MySchedule {
        apiLoaderFlag = true
        unFavoriteMyScheduleClass = true
        self.executeApiEndpointServicesForMyMvpModule()
      }
      else{
        
        // Code to hide loader with animated.
        HUD.hide(animated: true)
        
        // Code to update favorite field for the Site Class from local cache database table for the UnFavorite functionality.
        ScheduleSiteClassViewModel.updateSiteClassFavouriteFlagForSiteClass(siteClass, forSiteClassType: self.typeOfSiteClass, withFavoriteStatus: false)
        
        // Code to notify table view for reload data.
        self.tableViewMyMvpScheduleClasses.reloadData()
      }
    }
    else{ // to Mark Favorite locally
      // Code to hide loader with animated.
      HUD.hide(animated: true)
      
      siteClass.userFavourite = true
      
      // Code to update favorite field for the Site Class from local cache database table.
      ScheduleSiteClassViewModel.updateSiteClassFavouriteFlagForSiteClass(siteClass, forSiteClassType: self.typeOfSiteClass, withFavoriteStatus: true)
      
      // Code to notify table view for reload data.
      self.tableViewMyMvpScheduleClasses.reloadData()
    }
  }
  
  // MARK:  hideKeyboard methods.
  func hideKeyboard() {
    // Something after a delay.
    searchBarSiteClasses.resignFirstResponder()
    view.endEditing(true)
  }
  
}



// MARK:  Extension of MVPMyMVPScheduleViewController by UITableView DataSource & Delegates methods.
extension MVPMyMVPScheduleViewController: UITableViewDataSource, UITableViewDelegate{
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return arrayOfScheduleClassSectionObject.count
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if typeOfSiteClass == SiteClassesTypeEnum.ByInstructor{
      if section == selectedClassSection{
        return 70.0
      }
      else{
        return 90.0
      }
    }
    else{
      if section == selectedClassSection{
        return 30.0
      }
      else{
        return 45.0
      }
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let viewForTableViewCellSection = UIView()
    viewForTableViewCellSection.backgroundColor = WHITECOLOR
    
    if typeOfSiteClass == SiteClassesTypeEnum.ByInstructor{
      let subViewForTableViewCellSection = UIView()
      subViewForTableViewCellSection.frame = CGRectMake(0, 1, tableViewMyMvpScheduleClasses.frame.size.width, 69)
      subViewForTableViewCellSection.backgroundColor = selectSiteClassSectionTitleBackgroundColor
      
      let imageViewInstructorProfile = UIImageView()
      imageViewInstructorProfile.frame = CGRectMake(10, 10, 50, 50)
      imageViewInstructorProfile.image = UIImage(named: "profile")
      imageViewInstructorProfile.layer.cornerRadius = VALUEFIVECORNERRADIUS
      imageViewInstructorProfile.layer.masksToBounds = true
      
      // Code to set Site Class Instructor Image.
      var instructorImagePath = ""
      let sectionKey = arrayOfScheduleClassSectionObject[section] as String
      let exerciseClassArray = dictionaryOfScheduleArrayForSectionObject[sectionKey]
      if exerciseClassArray?.count > 0{
        let exerciseClass = exerciseClassArray![0] as ExerciseClass
        
        instructorImagePath = exerciseClass.classInstructorImage! as String
        if instructorImagePath.characters.count > 0{
          
          let profileImageUrl: NSURL = NSURL(string: instructorImagePath)!
          imageViewInstructorProfile.sd_setImageWithURL(profileImageUrl, placeholderImage: UIImage(named: "profile"))
        }
      }
      
      let instructorDetailButton = UIButton()
      instructorDetailButton.frame = CGRectMake(0, 0, tableViewMyMvpScheduleClasses.frame.size.width-70, 70)
      instructorDetailButton.backgroundColor = CLEARCOLOR
      instructorDetailButton.tag = section
      instructorDetailButton.addTarget(self, action: #selector(MVPMyMVPScheduleViewController.instructorDetailBtnClicked(_:)), forControlEvents: .TouchUpInside)
      
      let labelOfSectionAccountTitle = UILabel()
      labelOfSectionAccountTitle.frame = CGRectMake(75, 1, tableViewMyMvpScheduleClasses.frame.size.width-80, 69)
      labelOfSectionAccountTitle.backgroundColor = CLEARCOLOR
      labelOfSectionAccountTitle.textColor = WHITECOLOR
      labelOfSectionAccountTitle.textAlignment = NSTextAlignment.Left
      labelOfSectionAccountTitle.text = ""
      labelOfSectionAccountTitle.font = UIFont.boldSystemFontOfSize(17)
      let instructorString = arrayOfScheduleClassSectionObject[section] as String
      labelOfSectionAccountTitle.text = instructorString.uppercaseString
      
      let sectionImageView = UIImageView()
      if section == selectedClassSection{
        sectionImageView.frame = CGRectMake(tableViewMyMvpScheduleClasses.frame.size.width-50, 30, 16, 10)
        sectionImageView.image = UIImage(named: "down-white")
      }
      else{
        sectionImageView.frame = CGRectMake(tableViewMyMvpScheduleClasses.frame.size.width-46, 27, 10, 16)
        sectionImageView.image = UIImage(named: "right-white")
      }
      
      
      let drawerButton = UIButton()
      drawerButton.frame = CGRectMake(tableViewMyMvpScheduleClasses.frame.size.width-70, 1, 70, 70)
      drawerButton.backgroundColor = CLEARCOLOR
      drawerButton.tag = section
      drawerButton.addTarget(self, action: #selector(MVPMyMVPScheduleViewController.showSiteClassSectionBtnClicked(_:)), forControlEvents: .TouchUpInside)
      
      viewForTableViewCellSection.addSubview(subViewForTableViewCellSection)
      viewForTableViewCellSection.addSubview(imageViewInstructorProfile)
      viewForTableViewCellSection.addSubview(instructorDetailButton)
      viewForTableViewCellSection.addSubview(labelOfSectionAccountTitle)
      viewForTableViewCellSection.addSubview(sectionImageView)
      viewForTableViewCellSection.addSubview(drawerButton)
    }
    else{
      let labelOfSectionAccountTitle = UILabel()
      labelOfSectionAccountTitle.frame = CGRectMake(0, 1, tableViewMyMvpScheduleClasses.frame.size.width, 29)
      labelOfSectionAccountTitle.backgroundColor = selectSiteClassSectionTitleBackgroundColor
      labelOfSectionAccountTitle.textColor = WHITECOLOR
      labelOfSectionAccountTitle.textAlignment = NSTextAlignment.Left
      labelOfSectionAccountTitle.text = ""
      labelOfSectionAccountTitle.font = UIFont.boldSystemFontOfSize(17)
      
      var formattedHeaderLableTitleString = ""
      let headerLableTitleString = arrayOfScheduleClassSectionObject[section] as String
      
      switch typeOfSiteClass {
      case SiteClassesTypeEnum.ByDate:
        formattedHeaderLableTitleString = "   \(ScheduleViewModel.convertFormatOfDateString(headerLableTitleString))"
        
      case SiteClassesTypeEnum.ByInstructor:
        formattedHeaderLableTitleString = "   \(headerLableTitleString)"
        
      case SiteClassesTypeEnum.ByActivityClass:
        formattedHeaderLableTitleString = "   \(headerLableTitleString)"
        
      case SiteClassesTypeEnum.MySchedule:
        formattedHeaderLableTitleString = "   \(ScheduleViewModel.convertFormatOfDateString(headerLableTitleString))"
      }
      
      labelOfSectionAccountTitle.text = formattedHeaderLableTitleString.uppercaseString
      
      let sectionImageView = UIImageView()
      if section == selectedClassSection{
        sectionImageView.frame = CGRectMake(tableViewMyMvpScheduleClasses.frame.size.width-50, 10, 16, 10)
        sectionImageView.image = UIImage(named: "down-white")
      }
      else{
        sectionImageView.frame = CGRectMake(tableViewMyMvpScheduleClasses.frame.size.width-46, 7, 10, 16)
        sectionImageView.image = UIImage(named: "right-white")
      }
      
      if typeOfSiteClass == SiteClassesTypeEnum.ByActivityClass{
        let classDetailButton = UIButton()
        classDetailButton.frame = CGRectMake(0, 0, tableViewMyMvpScheduleClasses.frame.size.width-70, 29)
        classDetailButton.backgroundColor = CLEARCOLOR
        classDetailButton.tag = section
        classDetailButton.addTarget(self, action: #selector(MVPMyMVPScheduleViewController.siteClassDetailBtnClicked(_:)), forControlEvents: .TouchUpInside)
        
        viewForTableViewCellSection.addSubview(classDetailButton)
      }
      
      let drawerButton = UIButton()
      drawerButton.frame = CGRectMake(tableViewMyMvpScheduleClasses.frame.size.width-70, 1, 70, 29)
      drawerButton.backgroundColor = CLEARCOLOR
      drawerButton.tag = section
      drawerButton.addTarget(self, action: #selector(MVPMyMVPScheduleViewController.showSiteClassSectionBtnClicked(_:)), forControlEvents: .TouchUpInside)
      
      viewForTableViewCellSection.addSubview(labelOfSectionAccountTitle)
      viewForTableViewCellSection.addSubview(sectionImageView)
      viewForTableViewCellSection.addSubview(drawerButton)
    }
    
    return viewForTableViewCellSection
  }
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return dictionaryOfScheduleArrayForSectionObject[arrayOfScheduleClassSectionObject[section] as String]!.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == selectedClassSection{
      return 40.0
    }
    else{
      return 0.0
    }
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPScheduleClassByDateTableViewCell = (tableView.dequeueReusableCellWithIdentifier(SCHEDULECLASSBYDATETABLEVIEWCELL) as? MyMVPScheduleClassByDateTableViewCell!)!
    
    let exerciseClassObjectArray: [ExerciseClass] = dictionaryOfScheduleArrayForSectionObject[arrayOfScheduleClassSectionObject[indexPath.section] as String]!
    let exerciseClassObject: ExerciseClass = exerciseClassObjectArray[indexPath.row]
    
    // Code to set Site Class label value for the type of sort order
    if typeOfSiteClass == SiteClassesTypeEnum.ByInstructor{ // By Instructor
      cell.labelClassDate.text = "  \(ScheduleViewModel.getSiteClassFormattedDateString(exerciseClassObject.classStartTime!) as String)"
      cell.labelClassName.text = exerciseClassObject.className
    }
    else if typeOfSiteClass == SiteClassesTypeEnum.ByActivityClass{ // By Site Class
      cell.labelClassDate.text = "  \(ScheduleViewModel.getSiteClassFormattedDateString(exerciseClassObject.classStartTime!) as String)"
      cell.labelClassName.text = exerciseClassObject.classInstructor
    }
    else{ // By Date and My Schedule
      cell.labelClassDate.text = "  \(exerciseClassObject.className! as String)"
      cell.labelClassName.text = exerciseClassObject.classInstructor
    }
    cell.labelClassStartTime.text = ScheduleViewModel.getTimeStringFromDateString(exerciseClassObject.classStartTime!)
    
    
    // Code to Site Class Calendar
    cell.buttonCalender.tag = indexPath.row
    cell.buttonCalender.addTarget(self, action: #selector(MVPMyMVPScheduleViewController.addToCalenderBtnClicked(_:)), forControlEvents: .TouchUpInside)
    cell.buttonUnLoggedCalender.tag = indexPath.row
    cell.buttonUnLoggedCalender.addTarget(self, action: #selector(MVPMyMVPScheduleViewController.addToCalenderBtnClicked(_:)), forControlEvents: .TouchUpInside)
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
    cell.buttonFavourite.addTarget(self, action: #selector(MVPMyMVPScheduleViewController.markSiteClassUserFavouriteBtnClicked(_:)), forControlEvents: .TouchUpInside)
    if exerciseClassObject.userFavourite == true{
      cell.imageViewFavouriteIcon.image = UIImage(named: "sitefavourite")
    }
    else{
      cell.imageViewFavouriteIcon.image = UIImage(named: "siteunfavourite")
    }
    
    // When user logged-out hide favorite star view.
    if userLoginFlag == false{
      cell.viewLoggedUserStarCalendarView.hidden = true
    }
    else{
      cell.viewUnLoggedUserCalendarView.hidden = true
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewMyMvpScheduleClasses.reloadData()
    
    let exerciseClassObjectArray: [ExerciseClass] = dictionaryOfScheduleArrayForSectionObject[arrayOfScheduleClassSectionObject[indexPath.section] as String]!
    let exerciseClassObject: ExerciseClass = exerciseClassObjectArray[indexPath.row]
    
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPSiteClassDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPSITECLASSDETAILVIEWCONTROLLER) as! MVPMyMVPSiteClassDetailViewController
    mvpMyMVPSiteClassDetailViewController.siteClass = exerciseClassObject
    self.navigationController?.pushViewController(mvpMyMVPSiteClassDetailViewController, animated: true)
  }
  
}


// MARK:  Extension of MVPMyMVPScheduleViewController by DrawerTableViewDelegate methods.
extension MVPMyMVPScheduleViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.Schedules{
      self.handleOuterViewWithDrawerTapGesture()
    }
    else{
      self.popDrawerView()
    }
  }
  
}


// MARK:  Extension of MVPMyMVPScheduleViewController by UISearchBarDelegate methods.
extension MVPMyMVPScheduleViewController: UISearchBarDelegate{
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    self.prepareScheduleClassObjectsForTableViewWithSearctString(searchText)
    if searchText == "" {
      _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(MVPMyMVPScheduleViewController.hideKeyboard), userInfo: nil, repeats: false)
    }
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBarSiteClasses.resignFirstResponder()
    
    let searchString = searchBar.text! as String
    self.prepareScheduleClassObjectsForTableViewWithSearctString(searchString)
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBarSiteClasses.resignFirstResponder()
  }
  
}


// MARK:  Extension of MVPMyMVPScheduleViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPScheduleViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}

