//
//  MVPMyMVPChangeLocationViewController.swift
//  MVPSports
//
//  Created by Chetu India on 26/09/16.
//

import UIKit
import MapKit
import CoreLocation
import PKHUD



class MVPMyMVPChangeLocationViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var tableViewMyMvpSiteClub: UITableView!
  @IBOutlet weak var labelNoSiteClubAvailableLabel: UILabel!
  @IBOutlet weak var mapViewSiteClub: MKMapView!
  @IBOutlet weak var labelBadgeCount: UILabel!

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var dimView = UIView()
  var tableview = DrawerTableView()
  var arrayOfSiteClubObject = [SiteClub]()
  var locationManager: CLLocationManager!
  
  var userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
  var changedLocationFlag = false
  
  
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    labelNoSiteClubAvailableLabel.text = NSLocalizedString(NOCLUBSAVAILABLEMSG, comment: "")
    self.hideOrShowChangeLocalTableViewStatusLabelBy(false)

    // Call method to set UI of screen.
    self.preparedScreenDesign()

    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      /*
       * Code to validate arrayOfSiteClubObject have SiteClub or not. If not in that case hit web api endpoint of GetSiteClubNames to fetch all SiteClub for Change Location.
       */
      if arrayOfSiteClubObject.count == 0{
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
        self.fetchSiteClubs()
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
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    if (CLLocationManager.locationServicesEnabled()){
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestWhenInUseAuthorization()
      locationManager.startUpdatingLocation()
    }
    
    // Code to set pin annotation on UIWebView for the Site Club location latitude and longitude.
    self.setSiteClubPinAnnotationOnMapView()
    
    // Codeto update UI screen pop from root when user changed location.
    if changedLocationFlag == true{
      let triggerTime = (Int64(NSEC_PER_MSEC) * 2000)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in

        // Code to delete from records from SiteClassByDate table for un logged user default Site Class.
        let deleteQueryString = "\(deleteFromSiteClassByDateQuery)\("\n")\(deleteFromSiteClassByInstructorQuery)\("\n")\(deleteFromSiteClassByClassesQuery)\("\n")\(deleteFromSiteClassByUserFavouriteQuery)"
        DBManager.sharedInstance.executeDeleteQueryBy(deleteQueryString)
        
        // Code navigae to the Root ViewController.
        self.navigationController?.popToRootViewControllerAnimated(true)
      })
    }
    
  }
  
  
  /*
   * Method to set Site Club drop pin point annotation on UIMapView based on Site Club latitude and langitude value.
   */
  // MARK:  setSiteClubPinAnnotationOnMapView method.
  func setSiteClubPinAnnotationOnMapView() {
    for index in 0 ..< self.arrayOfSiteClubObject.count {
      let siteClub = self.arrayOfSiteClubObject[index] as SiteClub
      let lat = siteClub.lat! as String
      let lang = siteClub.lang! as String
      let clubName = siteClub.clubName! as String
      
      if lat.characters.count != 0 && lang.characters.count != 0{
        let latitude = Double(lat)
        let longitude = Double(lang)
        
        let Coordinates = CLLocationCoordinate2D(latitude: latitude! as CLLocationDegrees, longitude: longitude! as CLLocationDegrees)
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(1.0 , 1.0)
        let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(Coordinates, theSpan)
        // Code to set map view region for default site club of user
        if siteClub.isUserDafault == true{
          self.mapViewSiteClub.setRegion(theRegion, animated: true)
        }
        
        // Code to add PointAnnotation on mapViewSiteClub mapView of current location.
        let anotation = MKPointAnnotation()
        anotation.coordinate = Coordinates
        anotation.title = clubName
        
        mapViewSiteClub.addAnnotation(anotation)
        // Code to set selection annotation of user default site club
        if siteClub.isUserDafault == true{
          mapViewSiteClub.selectAnnotation(anotation, animated: false)
        }
        
      }
    }
  }

  
  // MARK:  fetchSiteClubs method.
  func fetchSiteClubs() {
    // Code to initiate input param dictionary to fetch all Site Clubs of application.
    let inputField = [String: String]()
    
    // Code to execute the getSiteClubsBy api endpoint from SiteClubService class method getSiteClubsBy to fetch all SiteClub of application.
    SiteClubService.getSiteClubsBy(inputField, completion: { (apiStatus, arrayOfSiteClubs) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        
        // Code to sort Site Club list based on default current location.
        if let currentLocationDict = NSUserDefaults.standardUserDefaults().valueForKey("currentlocation") as? [String: String]{
          let siteClubObjectsArray = arrayOfSiteClubs as! [SiteClub]
          
          self.arrayOfSiteClubObject = siteClubObjectsArray.sort {
          
            var firstSiteClubDistt = 0.0
            var secondSiteClubDistt = 0.0
            
            var currentLocationLat = ""
            var currentLocationLang = ""
            if let lat = currentLocationDict["lat"]{
              currentLocationLat = lat
            }
            if let lang = currentLocationDict["lang"]{
              currentLocationLang = lang
            }
            
            let firstSiteClubLat =  $0.lat! as String
            let firstSiteClubLang = $0.lang! as String

            let secondSiteClubLat = $1.lat! as String
            let secondSiteClubLang = $1.lang! as String
            
            if ScheduleViewModel.validateSiteClubCordinates(firstSiteClubLat, and: firstSiteClubLang) && ScheduleViewModel.validateSiteClubCordinates(secondSiteClubLat, and: secondSiteClubLang) && ScheduleViewModel.validateSiteClubCordinates(currentLocationLat, and: currentLocationLang) {
              
              let currentLocationCoord = CLLocationCoordinate2D(latitude: Double(currentLocationLat)!, longitude: Double(currentLocationLang)!)
              let firstSiteClubCoord = CLLocationCoordinate2D(latitude: Double(firstSiteClubLat)!, longitude: Double(firstSiteClubLang)!)
              let secondSiteClubCoord = CLLocationCoordinate2D(latitude: Double(secondSiteClubLat)!, longitude: Double(secondSiteClubLang)!)

              let currentLocationPoint = MKMapPointForCoordinate(currentLocationCoord)
              let firstSiteClubPoint = MKMapPointForCoordinate(firstSiteClubCoord)
              let secondSiteClubPoint = MKMapPointForCoordinate(secondSiteClubCoord)

              firstSiteClubDistt = MKMetersBetweenMapPoints(currentLocationPoint, firstSiteClubPoint) * 0.00062137
              secondSiteClubDistt = MKMetersBetweenMapPoints(currentLocationPoint, secondSiteClubPoint) * 0.00062137
            }
            
            return firstSiteClubDistt < secondSiteClubDistt
          }
        }
        else{
          self.arrayOfSiteClubObject = arrayOfSiteClubs as! [SiteClub]
        }
        
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
      }
      else{ // For Network error.
      }
      
      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        HUD.hide(animated: true)
        
        // Call method to set UI of screen.
        self.preparedScreenDesign()
        
        // Code to hide or show labelNoSiteClubAvailableLabel based on Site Classes array count.
        if self.arrayOfSiteClubObject.count > 0{
          self.hideOrShowChangeLocalTableViewStatusLabelBy(false)
          
          // Code to call UItableView notify method to reload table view data information.
          self.tableViewMyMvpSiteClub.reloadData()
        }
        else{
          self.hideOrShowChangeLocalTableViewStatusLabelBy(true)
        }

      }
    })
  }
  
  func sorterForFileIDASC(this:SiteClub, that:SiteClub) -> Bool {
    return this.clubid > that.clubid
  }
  
  
  
  // MARK:  setUnLoggedUserDefaultSiteClub method.
  func setUnLoggedUserDefaultSiteClub(selectedSiteClub: SiteClub) {
    // Code to set isUserDafault flag of default site club of UnLogged User from selected site club
    for index in 0 ..< self.arrayOfSiteClubObject.count {
      let siteClub = self.arrayOfSiteClubObject[index] as SiteClub
      
      if siteClub.clubid == selectedSiteClub.clubid{
        siteClub.isUserDafault = true
      }
      else{
        siteClub.isUserDafault = false
      }
    }

    // Code to save UnLogged user default site club info in local .plist file.
    var SiteId = ""
    var SiteName = ""
    if let siteid = selectedSiteClub.clubid{
      SiteId = siteid as String
    }
    if let sitename = selectedSiteClub.clubName{
      SiteName = sitename as String
    }
    
    var unLoggedUserDict = [String: String]()
    unLoggedUserDict["siteId"] = SiteId
    unLoggedUserDict["siteName"] = SiteName
    UserViewModel.saveUnLoggedUserDictInUserDefault(unLoggedUserDict)
    
    /*
     * Code to update the user status flag boolean value to true.
     * Bcoz over here user status get changed from UnLogeed user to Logged user.
     */
    UserViewModel.setUserStatusInApplication(true)

    /*
     * Code to update the Change Location flag boolean value to true.
     */
    UserViewModel.setChangeLocationStatusInApplication(true)

    // Code to upate UI in the Main thread.
    dispatch_async(dispatch_get_main_queue()) {
      // Code to hide loader
      HUD.hide(animated: true)
      
      // Mark changed location true.
      self.changedLocationFlag = true
      
      // Call method to set UI of screen.
      self.preparedScreenDesign()
    }
  }
  
  // MARK:  setLoggedUserDefaultSiteClub method.
  func setLoggedUserDefaultSiteClub(siteClub: SiteClub) {
    
    var setDefaultSiteClassInputField = [String: String]()
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
 
    setDefaultSiteClassInputField["memid"] = memberId
    setDefaultSiteClassInputField["siteid"] = siteClub.clubid! as String
    
    /*
     * Code to set user default Site Class by SetDefaultSiteClass api endpoint service.
     * SiteClubService class method setDefaultSiteClubsBy to execute api to set Site Class as default site class of user.
     */
    // Code to execute the setDefaultSiteClubsBy api endpoint from SiteClubService class method setDefaultSiteClubsBy to set selected SiteClass as default SiteClass.
    SiteClubService.setDefaultSiteClubsBy(setDefaultSiteClassInputField, completion: { (apiStatus, response) -> () in
      var apiFlag = false
      var title = ""
      var message = ""
      if apiStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = "\(siteClub.clubName! as String) set as default Site Class"

        // Code to save logged user default site club info in local .plist file.
        var SiteId = ""
        var SiteName = ""
        if let siteid = siteClub.clubid{
          SiteId = siteid as String
        }
        if let sitename = siteClub.clubName{
          SiteName = sitename as String
        }
        
        var userDict = [String: String]()
        userDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
        userDict["Siteid"] = SiteId
        userDict["siteName"] = SiteName
        UserViewModel.saveUserDictInUserDefault(userDict)
        
        /*
         * Code to update the user status flag boolean value to true.
         * Bcoz over here user status get changed from UnLogeed user to Logged user.
         */
        UserViewModel.setUserStatusInApplication(true)

      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(ERROROCCUREDTOSETASDEFAULTSITECLASSMSG, comment: "")
      }
      else{ // For Network error.
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        
        if apiFlag == true{
          // Mark changed location true.
          self.changedLocationFlag = true
          
          self.fetchSiteClubs()
        }
        else{
          // Code to hide progress loader.
          HUD.hide(animated: true)
          // Code to show alert dialogue box.
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
      
    })
  }
  
  // MARK:  setDefaultSiteClubOfSelected method.
  func setDefaultSiteClubOfSelected(siteClub: SiteClub) {
    
    if userLoginFlag == true{ // When user is Logged In
      self.setLoggedUserDefaultSiteClub(siteClub)
    }
    else{ // when user is Logged Out
      self.setUnLoggedUserDefaultSiteClub(siteClub)
    }
  }
  
  // MARK:  setDefaultSiteClubButtonTapped method.
  func setDefaultSiteClubButtonTapped(sender: UIButton){
    let tagIndex =  sender.tag
    let selectedSiteClub = arrayOfSiteClubObject[tagIndex] as SiteClub
    if selectedSiteClub.isUserDafault == false{
      // Code to validate site class is laready marked favourite or not.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))

      // Code to call setDefaultSiteClubOfSelected method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        self.setDefaultSiteClubOfSelected(selectedSiteClub)
      })

    }
    else{
      var title = ""
      var message = ""
      title = NSLocalizedString(ALERTTITLE, comment: "")
      message = NSLocalizedString(ALREADYYOURDEFAULTSITECLUB, comment: "")
      
      self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
    }
  }
  
  // MARK:  hideOrShowChangeLocalTableViewStatusLabelBy method.
  func hideOrShowChangeLocalTableViewStatusLabelBy(showFlag: Bool) {
    
    if showFlag == true{
      self.labelNoSiteClubAvailableLabel.hidden = false
      labelNoSiteClubAvailableLabel.frame = CGRectMake(labelNoSiteClubAvailableLabel.frame.origin.x, labelNoSiteClubAvailableLabel.frame.origin.y, labelNoSiteClubAvailableLabel.frame.size.width, 50)
    }
    else{
      self.labelNoSiteClubAvailableLabel.hidden = true
      labelNoSiteClubAvailableLabel.frame = CGRectMake(labelNoSiteClubAvailableLabel.frame.origin.x, labelNoSiteClubAvailableLabel.frame.origin.y, labelNoSiteClubAvailableLabel.frame.size.width, 0)
    }
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
  
  // MARK:  siteClubDetailButtonTapped method.
  func siteClubDetailButtonTapped(sender: UIButton){
    let tagIndex =  sender.tag
    let selectedSiteClub = arrayOfSiteClubObject[tagIndex] as SiteClub
    
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPSiteClubDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPSITECLUBDETAILVIEWCONTROLLER) as! MVPMyMVPSiteClubDetailViewController
    mvpMyMVPSiteClubDetailViewController.siteClubId = selectedSiteClub.clubid!
    self.navigationController?.pushViewController(mvpMyMVPSiteClubDetailViewController, animated: true)
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
extension MVPMyMVPChangeLocationViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return arrayOfSiteClubObject.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 80.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPSiteClubTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPSITECLUBTABLEVIEWCELL) as? MyMVPSiteClubTableViewCell!)!
    
    let labelWidth = self.view.frame.size.width - 170
    let labelFont = cell.labelLocationTitle.font as UIFont
    
    let siteClub = arrayOfSiteClubObject[indexPath.row]
    let clubName = siteClub.clubName! as String
    let clubNameUpperCaseString = clubName.uppercaseString
    let truncatedName = SiteClubsViewModel.getSiteClubLocationTruncatedLabelStringFrom(clubNameUpperCaseString, font: labelFont, labelWidth: labelWidth)
    cell.labelLocationTitle.text = truncatedName
    
    let clubAddress = siteClub.address! as String
    cell.labelCity.text = clubAddress
    
    if siteClub.isUserDafault == true{
      cell.imageViewUserFavourite.image = UIImage(named: "star-filled")
    }
    else{
      cell.imageViewUserFavourite.image = UIImage(named: "star-outline")
    }
    
    if let currentLocationDict = NSUserDefaults.standardUserDefaults().valueForKey("currentlocation") as? [String: String]{
      var currentLocationLat = ""
      var currentLocationLang = ""
      if let lat = currentLocationDict["lat"]{
        currentLocationLat = lat
      }
      if let lang = currentLocationDict["lang"]{
        currentLocationLang = lang
      }
      
      let siteClubLat = siteClub.lat! as String
      let siteClubLang = siteClub.lang! as String
      
      if ScheduleViewModel.validateSiteClubCordinates(siteClubLat, and: siteClubLang) && ScheduleViewModel.validateSiteClubCordinates(currentLocationLat, and: currentLocationLang) {
        
        let currentLocationCoord = CLLocationCoordinate2D(latitude: Double(currentLocationLat)!, longitude: Double(currentLocationLang)!)
        let siteClubCoord = CLLocationCoordinate2D(latitude: Double(siteClubLat)!, longitude: Double(siteClubLang)!)
        
        let currentLocationPoint = MKMapPointForCoordinate(currentLocationCoord)
        let siteClubPoint = MKMapPointForCoordinate(siteClubCoord)
        let mile = MKMetersBetweenMapPoints(currentLocationPoint, siteClubPoint) * 0.00062137
        let distnaceInMile = String(format: "%.1f Mi", mile)
        cell.labelDistanceInMile.text = distnaceInMile
      }
    }
    else{
      cell.labelDistanceInMile.hidden = true
    }
    
    cell.buttonGoToDetail.tag = indexPath.row
    cell.buttonGoToDetail.addTarget(self, action: #selector(MVPMyMVPChangeLocationViewController.siteClubDetailButtonTapped(_:)), forControlEvents: .TouchUpInside)
    
    cell.buttonSetDefaultSiteClub.tag = indexPath.row
    cell.buttonSetDefaultSiteClub.addTarget(self, action: #selector(MVPMyMVPChangeLocationViewController.setDefaultSiteClubButtonTapped(_:)), forControlEvents: .TouchUpInside)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewMyMvpSiteClub.reloadData()
  }
}


// MARK:  Extension of MVPMyMVPConnectedAppsViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPChangeLocationViewController: CLLocationManagerDelegate{
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
      self.tableViewMyMvpSiteClub.reloadData()
    }
  }
}


// MARK:  Extension of MVPMyMVPChangeLocationViewController by DrawerTableViewDelegate method.
extension MVPMyMVPChangeLocationViewController: DrawerTableViewDelegate{
  
  func drawerViewTapGestureDelegate(){
    self.handleOuterViewWithDrawerTapGesture()
  }
  
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration){
    if drawerMenuOption == DrawerMenuOptionEnumeration.ChangeLocation{
      self.handleOuterViewWithDrawerTapGesture()
    }
    else{
      self.popDrawerView()
    }
  }
}


// MARK:  Extension of MVPMyMVPChangeLocationViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPChangeLocationViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    self.notificationAlertBellBtnClicked(UIButton())
  }
  
  func badgeCountDelegate(){
    // Code to set default view for the APNS notification bell badge count lable.
    NotificationAnnouncementViewModel.updateBadgeCountToUIOf(labelBadgeCount)
  }
}

