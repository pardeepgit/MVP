//
//  NavigationViewManager.swift
//  MVPSports
//
//  Created by Chetu India on 19/11/16.
//

import UIKit

class NavigationViewManager: NSObject {
  
  // Code for Singleton instance for the class.
  static let instance = NavigationViewManager()
  
  // Default constructor with limit access specifier private from with in this file.
  private override init() {
    super.init()
  }
  
  
  
  
  /*
   * navigateToLoginViewControllerFrom method to navigate to LoginViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToLoginViewControllerFrom method.
  func navigateToLoginViewControllerFrom(viewController: UIViewController) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpLoginViewController = storyBoard.instantiateViewControllerWithIdentifier(LOGINVIEWCONTROLLER) as! MVPLoginViewController
    let navigationController = viewController.navigationController! as UINavigationController
    navigationController.pushViewController(mvpLoginViewController, animated: true)
  }
  
  
  /*
   * navigateToScheduleViewControllerFrom method to navigate to Schedule ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToScheduleViewControllerFrom method.
  func navigateToScheduleViewControllerFrom(viewController: UIViewController) {
    if !viewController.isKindOfClass(MVPMyMVPScheduleViewController){
      let navigationController = viewController.navigationController! as UINavigationController
      
      let arrayOfVisibleController = navigationController.viewControllers as NSArray
      for index in 0..<arrayOfVisibleController.count {
        let visibleController = arrayOfVisibleController[index] as! UIViewController
        if visibleController.isKindOfClass(MVPMyMVPScheduleViewController){
          navigationController.popToViewController(visibleController, animated: true)
          return
        }
      }
      
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let mvpMyMVPScheduleViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPSCHEDULEVIEWCONTROLLER) as! MVPMyMVPScheduleViewController
      navigationController.pushViewController(mvpMyMVPScheduleViewController, animated: true)
    }
  }

  /*
   * navigateToMyRewardsViewControllerFrom method to navigate Logged user to My Rewards ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToMyRewardsViewControllerFrom method.
  func navigateToMyRewardsViewControllerFrom(viewController: UIViewController) {
    let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // when User is Logged In
      if !viewController.isKindOfClass(MVPMyMVPViewController){
        let navigationController = viewController.navigationController! as UINavigationController
        
        let arrayOfVisibleController = navigationController.viewControllers as NSArray
        for index in 0..<arrayOfVisibleController.count {
          let visibleController = arrayOfVisibleController[index] as! UIViewController
          if visibleController.isKindOfClass(MVPMyMVPViewController){
            navigationController.popToViewController(visibleController, animated: true)
            return
          }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
        let mvpMyMVPAccountInfoViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPVIEWCONTROLLER) as! MVPMyMVPViewController
        navigationController.pushViewController(mvpMyMVPAccountInfoViewController, animated: true)
      }
    }
    else{ // When User is Logged Out
      self.navigateToLoginViewControllerFrom(viewController)
    }
  }

  
  
  /*
   * navigateToMyAccountViewControllerFrom method to navigate to Logged user My Account ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToMyAccountViewControllerFrom method.
  func navigateToMyAccountViewControllerFrom(viewController: UIViewController) {
    let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // when User is Logged In
      if !viewController.isKindOfClass(MVPMyMVPAccountInfoViewController){
        let navigationController = viewController.navigationController! as UINavigationController
        
        let arrayOfVisibleController = navigationController.viewControllers as NSArray
        for index in 0..<arrayOfVisibleController.count {
          let visibleController = arrayOfVisibleController[index] as! UIViewController
          if visibleController.isKindOfClass(MVPMyMVPAccountInfoViewController){
            navigationController.popToViewController(visibleController, animated: true)
            return
          }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
        let mvpMyMVPAccountInfoViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPACCOUNTINFOVIEWCONTROLLER) as! MVPMyMVPAccountInfoViewController
        navigationController.pushViewController(mvpMyMVPAccountInfoViewController, animated: true)
      }
    }
    else{ // When User is Logged Out
      self.navigateToLoginViewControllerFrom(viewController)
    }
  }
  
  
  /*
   * navigateToCheckInViewControllerFrom method to navigate to CheckIn ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToCheckInViewControllerFrom method.
  func navigateToCheckInViewControllerFrom(viewController: UIViewController) {
    let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // when User is Logged In
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let mvpMyMVPCheckInViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCHECKINVIEWCONTROLLER) as! MVPMyMVPCheckInViewController
      
      let navigationController = viewController.navigationController! as UINavigationController
      navigationController.pushViewController(mvpMyMVPCheckInViewController, animated: true)
    }
    else{ // When User is Logged Out
      self.navigateToLoginViewControllerFrom(viewController)
    }
  }
  
  /*
   * navigateToAnnouncementsViewControllerFrom method to navigate to My Annoucements ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToAnnouncementsViewControllerFrom method.
  func navigateToAnnouncementsViewControllerFrom(viewController: UIViewController) {
    let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // when User is Logged In
      if !viewController.isKindOfClass(MVPMyMVPAnnouncementViewController){
        let navigationController = viewController.navigationController! as UINavigationController
        
        let arrayOfVisibleController = navigationController.viewControllers as NSArray
        for index in 0..<arrayOfVisibleController.count {
          let visibleController = arrayOfVisibleController[index] as! UIViewController
          if visibleController.isKindOfClass(MVPMyMVPAnnouncementViewController){
            navigationController.popToViewController(visibleController, animated: true)
            return
          }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
        let mvpMyMVPConnectedAppsViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPANNOUNCEMENTVIEWCONTROLLER) as! MVPMyMVPAnnouncementViewController
        navigationController.pushViewController(mvpMyMVPConnectedAppsViewController, animated: true)
      }
    }
    else{ // When User is Logged Out
      self.navigateToLoginViewControllerFrom(viewController)
    }
  }
  
  
  /*
   * navigateToConnectedAppsViewControllerFrom method to navigate to Logged User Connected Apps ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToConnectedAppsViewControllerFrom method.
  func navigateToConnectedAppsViewControllerFrom(viewController: UIViewController) {
    let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // when User is Logged In
      if !viewController.isKindOfClass(MVPMyMVPConnectedAppsViewController){
        let navigationController = viewController.navigationController! as UINavigationController
        
        let arrayOfVisibleController = navigationController.viewControllers as NSArray
        for index in 0..<arrayOfVisibleController.count {
          let visibleController = arrayOfVisibleController[index] as! UIViewController
          if visibleController.isKindOfClass(MVPMyMVPConnectedAppsViewController){
            navigationController.popToViewController(visibleController, animated: true)
            return
          }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
        let mvpMyMVPConnectedAppsViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCONNECTEDAPPSVIEWCONTROLLER) as! MVPMyMVPConnectedAppsViewController
        navigationController.pushViewController(mvpMyMVPConnectedAppsViewController, animated: true)
      }
    }
    else{ // When User is Logged Out
      self.navigateToLoginViewControllerFrom(viewController)
    }
  }
  
  
  /*
   * navigateToConnectedAppsViewControllerFrom method to navigate to Logged User Connected Apps ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToConnectedAppsViewControllerFrom method.
  func navigateToNotificationSettingViewControllerFrom(viewController: UIViewController) {
    
    let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // when User is Logged In
      if !viewController.isKindOfClass(MVPMyMVPNotificationsViewController){
        let navigationController = viewController.navigationController! as UINavigationController
        
        let arrayOfVisibleController = navigationController.viewControllers as NSArray
        for index in 0..<arrayOfVisibleController.count {
          let visibleController = arrayOfVisibleController[index] as! UIViewController
          if visibleController.isKindOfClass(MVPMyMVPNotificationsViewController){
            navigationController.popToViewController(visibleController, animated: true)
            return
          }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
        let mvpMyMVPNotificationsViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPNOTIFICATIONSVIEWCONTROLLER) as! MVPMyMVPNotificationsViewController
        navigationController.pushViewController(mvpMyMVPNotificationsViewController, animated: true)
      }
    }
    else{ // When User is Logged Out
      self.navigateToLoginViewControllerFrom(viewController)
    }
  }

  
  
  /*
   * navigateToTrackWorkoutViewControllerFrom method to navigate to Logged User Track Workout ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToTrackWorkoutViewControllerFrom method.
  func navigateToTrackWorkoutViewControllerFrom(viewController: UIViewController) {
    let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
    if userLoginFlag == true{ // when User is Logged In
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let mvpMyMVPWorkoutViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPWORKOUTVIEWCONTROLLER) as! MVPMyMVPWorkoutViewController
      
      let navigationController = viewController.navigationController! as UINavigationController
      navigationController.pushViewController(mvpMyMVPWorkoutViewController, animated: true)
    }
    else{ // When User is Logged Out
      self.navigateToLoginViewControllerFrom(viewController)
    }
  }
  
  
  /*
   * navigateToGiveFeedbackViewControllerFrom method to navigate to Give Feedback ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToGiveFeedbackViewControllerFrom method.
  func navigateToGiveFeedbackViewControllerFrom(viewController: UIViewController) {
    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPCommentCardViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCOMMENTCARDVIEWCONTROLLER) as! MVPMyMVPCommentCardViewController
    
    let navigationController = viewController.navigationController! as UINavigationController
    navigationController.pushViewController(mvpMyMVPCommentCardViewController, animated: true)
  }
  
  
  /*
   * navigateToContactHourViewControllerFrom method to navigate to Contact Us ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToContactHourViewControllerFrom method.
  func navigateToContactHourViewControllerFrom(viewController: UIViewController) {
    if !viewController.isKindOfClass(MVPMyMVPSiteClubDetailViewController){
      let navigationController = viewController.navigationController! as UINavigationController
      
      let arrayOfVisibleController = navigationController.viewControllers as NSArray
      for index in 0..<arrayOfVisibleController.count {
        let visibleController = arrayOfVisibleController[index] as! UIViewController
        if visibleController.isKindOfClass(MVPMyMVPSiteClubDetailViewController){
          navigationController.popToViewController(visibleController, animated: true)
          return
        }
      }
      
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let mvpMyMVPSiteClubDetailViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPSITECLUBDETAILVIEWCONTROLLER) as! MVPMyMVPSiteClubDetailViewController
      navigationController.pushViewController(mvpMyMVPSiteClubDetailViewController, animated: true)
    }
  }
  
  
  /*
   * navigateToChangeLocationViewControllerFrom method to navigate to Change Location ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToChangeLocationViewControllerFrom method.
  func navigateToChangeLocationViewControllerFrom(viewController: UIViewController) {
    if !viewController.isKindOfClass(MVPMyMVPChangeLocationViewController){
      let navigationController = viewController.navigationController! as UINavigationController
      
      let arrayOfVisibleController = navigationController.viewControllers as NSArray
      for index in 0..<arrayOfVisibleController.count {
        let visibleController = arrayOfVisibleController[index] as! UIViewController
        if visibleController.isKindOfClass(MVPMyMVPChangeLocationViewController){
          navigationController.popToViewController(visibleController, animated: true)
          return
        }
      }
      
      let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
      let mvpMyMVPChangeLocationViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPCHANGELOCATIONVIEWCONTROLLER) as! MVPMyMVPChangeLocationViewController
      navigationController.pushViewController(mvpMyMVPChangeLocationViewController, animated: true)
    }
  }
  
  
  /*
   * navigateToLogoutViewControllerFrom method to LogOut user from application ViewController from parametrized UIViewController instance.
   */
  // MARK:  navigateToLogoutViewControllerFrom method.
  func navigateToLogoutViewControllerFrom(viewController: UIViewController) {
    // Code to set the blank refresh_token value and user dict in user default to logout user status.
    UserViewModel.setRefreshToken("")
    UserViewModel.setClientToken("")
    UserViewModel.saveUserDictInUserDefault([String: String]())
    UserViewModel.saveUnLoggedUserDictInUserDefault([String: String]())
    
    UserViewModel.setChangeLocationStatusInApplication(false)
    
    /*
     * Code to update the user status flag boolean value to true.
     * Bcoz over here user status get changed from UnLogeed user to Logged user.
     */
    UserViewModel.setUserStatusInApplication(true)
    
    // Code to delete from records from SiteClassByDate table for un logged user default Site Class.
    let deleteQueryString = "\(deleteFromSiteClassByDateQuery)\("\n")\(deleteFromSiteClassByInstructorQuery)\("\n")\(deleteFromSiteClassByClassesQuery)\("\n")\(deleteFromSiteClassByUserFavouriteQuery)"
    DBManager.sharedInstance.executeDeleteQueryBy(deleteQueryString)
    
    if !viewController.isKindOfClass(MVPDashboardViewController){
      let navigationController = viewController.navigationController! as UINavigationController
      navigationController.popToRootViewControllerAnimated(false)
    }    
  }

  
  /*
   * navigateToLogoutViewControllerFrom method to navigate user to the navigateToFullWebSitePage of the screen.
   */
  // MARK:  navigateToFullWebSitePage method.
  func navigateToFullWebSitePage(viewController: UIViewController) {
    let navigationController = viewController.navigationController! as UINavigationController

    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPRewardPdfViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPREWARDPDFVIEWCONTROLLER) as! MVPMyMVPRewardPdfViewController
    mvpMyMVPRewardPdfViewController.urlLoadType = LoadUrlType.FullWebSite
    navigationController.pushViewController(mvpMyMVPRewardPdfViewController, animated: true)
  }

  /*
   * navigateToLogoutViewControllerFrom method to navigate user to the navigateToFitAndFresgBlogPage of the screen.
   */
  // MARK:  navigateToFitAndFresgBlogPage method.
  func navigateToFitAndFresgBlogPage(viewController: UIViewController) {
    let navigationController = viewController.navigationController! as UINavigationController

    let storyBoard : UIStoryboard = UIStoryboard(name: MAIN, bundle:nil)
    let mvpMyMVPRewardPdfViewController = storyBoard.instantiateViewControllerWithIdentifier(MVPMYMVPREWARDPDFVIEWCONTROLLER) as! MVPMyMVPRewardPdfViewController
    mvpMyMVPRewardPdfViewController.pdfUrl = FitFreshBlogPageURL
    mvpMyMVPRewardPdfViewController.urlLoadType = LoadUrlType.FitFreshBlog
    navigationController.pushViewController(mvpMyMVPRewardPdfViewController, animated: true)
  }

  
  /*
   * navigateToLogoutViewControllerFrom method to navigate user to the Root ViewController of the screen.
   */
  // MARK:  navigateToLogoutViewControllerFrom method.
  func navigateToRootViewControllerFrom(viewController: UIViewController) {
    
    let navigationController = viewController.navigationController! as UINavigationController
    navigationController.popToRootViewControllerAnimated(false)
  }
  
  
}
