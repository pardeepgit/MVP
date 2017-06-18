//
//  DrawerTableView.swift
//  CommonTableView
//
//  Created by Chetu India on 23/09/16.
//

import UIKit



/*
 * AccountInfoTypeEnumeration is an enumeration of raw type is string.
 * Enumeration infer the type of Account Info sub module by the cases of enum.
 */
enum DrawerMenuOptionEnumeration: String {
  case LogIn = "Log In"
  case Schedules = "Schedules"
  case MyHealthPoints = "My Health Points"
  case MyAccount = "My Account"
  case Announcements = "Announcements"
  case ConnectedApps = "Connected Apps"
  case TrackWorkout = "Track Workout"
  case GiveFeedback = "Give Feedback"
  case ContactHours = "Contact & Hours"
  case FullWebsite = "Full Website"
  case FitFreshBlog = "Fit & Fresh Blog"
  case ChangeLocation = "Change Location"
  case LogOut = "Log Out"
}


/*
 * DrawerTableViewDelegate protocol declaration with tow required method declaration.
 */
protocol  DrawerTableViewDelegate {
  func drawerViewTapGestureDelegate()
  func drawerViewSelectMenuOptionDelegateWith(drawerMenuOption: DrawerMenuOptionEnumeration)
}


/*
 * DrawerTableView subclass of UITableView declaration with overrided method with class instance method declaration.
 */
class DrawerTableView: UITableView {
  
  // MARK:  instance variables, constant decalaration and define with infer type with default values.
  var arrayOfDrawerMenuOption = [String]()
  var drawerDelegate: DrawerTableViewDelegate?
  weak var parentViewController: UIViewController?

  var userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()

  
  /*
   * default paramerized overrided contsructor method to initiate the drawer frame view.
   */
  // MARK: -  parametrized overrided constructor method.
  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    
    self.frame = frame
    self.delegate = self
    self.dataSource = self
    self.translatesAutoresizingMaskIntoConstraints = true
    
    if DeviceType.IS_IPHONE_4_OR_LESS {
      self.scrollEnabled = true
    }
    else{
      self.scrollEnabled = false
    }
    
    self.backgroundColor = BLACKCOLOR
    self.separatorStyle = .None
    
    self.registerClass(DrawerTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
   
    let tap = UITapGestureRecognizer(target: self, action: #selector(DrawerTableView.handleDrawerTapGesture))
    self.addGestureRecognizer(tap)

    self.prepareDrawerMenuArray()
  }
  
  /*
   * default overrided constructor method.
   */
  // MARK: -  default overrided constructor method.
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  
  /*
   * prepareDrawerMenuArray method to prepare array of drawer menu option.
   */
  // MARK: -  prepareDrawerMenuArray method.
  func prepareDrawerMenuArray() {
    
    arrayOfDrawerMenuOption.append("Log In")
    arrayOfDrawerMenuOption.append("Schedules")
    arrayOfDrawerMenuOption.append("My Health Points")
    arrayOfDrawerMenuOption.append("My Account")
    arrayOfDrawerMenuOption.append("Announcements")
    arrayOfDrawerMenuOption.append("Connected Apps")
    arrayOfDrawerMenuOption.append("Track Workout")
    arrayOfDrawerMenuOption.append("Give Feedback")
    arrayOfDrawerMenuOption.append("Contact & Hours")
    arrayOfDrawerMenuOption.append("Full Website")
    arrayOfDrawerMenuOption.append("Fit & Fresh Blog")
    arrayOfDrawerMenuOption.append("Change Location")
    arrayOfDrawerMenuOption.append("Log Out")

    if userLoginFlag == true{ // When User Logged In
      // Code to remove Log In string from array.
      arrayOfDrawerMenuOption.removeAtIndex(0)
    }
    else{ // When User is not Logged in
      // Code to remove Log Out string from array.
      arrayOfDrawerMenuOption.removeAtIndex(12)
    }
    
    self.reloadData()
  }
  

  
  
  /*
   * Method to handle Tap Gesture recognizer of drawer menu.
   * Code to validate for drawer menu option selection.
   */
  // MARK:  handleDrawerTapGesture method.
  func handleDrawerTapGesture(recognizer: UIGestureRecognizer) {
    if recognizer.state == UIGestureRecognizerState.Ended {
      let tappedLocation = recognizer.locationInView(self)
      if let tappedIndexPath = self.indexPathForRowAtPoint(tappedLocation) {
        if self.cellForRowAtIndexPath(tappedIndexPath) != nil {
          let type = arrayOfDrawerMenuOption[tappedIndexPath.row] as String
          self.drawerViewDelegateForIndex(type)
        }
      }
      else{
        drawerDelegate!.drawerViewTapGestureDelegate()
      }
    }
  }

  
  
  /*
   * drawerViewDelegateForIndex method to call delegate protocol method drawerViewSelectMenuOptionDelegateWith for selected menu from drawer view.
   *
   */
  // MARK:  drawerViewDelegateForIndex method.
  func drawerViewDelegateForIndex(type: String) {
    switch type {
    case DrawerMenuOptionEnumeration.LogIn.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.LogIn)
      NavigationViewManager.instance.navigateToLoginViewControllerFrom(parentViewController!)
      break
      
    case DrawerMenuOptionEnumeration.Schedules.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.Schedules)
      NavigationViewManager.instance.navigateToScheduleViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.MyHealthPoints.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.MyHealthPoints)
      NavigationViewManager.instance.navigateToMyRewardsViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.MyAccount.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.MyAccount)
      NavigationViewManager.instance.navigateToMyAccountViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.Announcements.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.Announcements)
      NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.ConnectedApps.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.ConnectedApps)
      NavigationViewManager.instance.navigateToConnectedAppsViewControllerFrom(parentViewController!)
      break
      
    case DrawerMenuOptionEnumeration.TrackWorkout.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.TrackWorkout)
      NavigationViewManager.instance.navigateToTrackWorkoutViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.GiveFeedback.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.GiveFeedback)
      NavigationViewManager.instance.navigateToGiveFeedbackViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.ContactHours.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.ContactHours)
      NavigationViewManager.instance.navigateToContactHourViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.FullWebsite.rawValue:
      drawerDelegate!.drawerViewTapGestureDelegate()
      NavigationViewManager.instance.navigateToFullWebSitePage(parentViewController!)
      break
      
    case DrawerMenuOptionEnumeration.FitFreshBlog.rawValue:
      drawerDelegate!.drawerViewTapGestureDelegate()
      NavigationViewManager.instance.navigateToFitAndFresgBlogPage(parentViewController!)
      break
      
    case DrawerMenuOptionEnumeration.ChangeLocation.rawValue:
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.ChangeLocation)
      NavigationViewManager.instance.navigateToChangeLocationViewControllerFrom(parentViewController!)
      break

    case DrawerMenuOptionEnumeration.LogOut.rawValue:
      NavigationViewManager.instance.navigateToLogoutViewControllerFrom(parentViewController!)
      drawerDelegate?.drawerViewSelectMenuOptionDelegateWith(DrawerMenuOptionEnumeration.LogOut)
      break
      
    default:
      drawerDelegate!.drawerViewTapGestureDelegate()
    }
  }

}




/*
 * Extension of DrawerTableView to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in DrawerTableView.
 */
// MARK:  Extension of DrawerTableView by UITableView DataSource & Delegates method.
extension DrawerTableView: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return arrayOfDrawerMenuOption.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 40.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(CELL, forIndexPath: indexPath) as! DrawerTableViewCell
    
    cell.setLabelFrame(CGRectMake(30, 0, self.frame.size.width-30, 40))
    cell.setBottomLinelViewFrame(CGRectMake(5, 39, self.frame.size.width-10, 1))
    cell.labelMenuOption.text = arrayOfDrawerMenuOption[indexPath.row] as String
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.reloadData()
    
    let type = arrayOfDrawerMenuOption[indexPath.row] as String
    self.drawerViewDelegateForIndex(type)
  }
  
}
