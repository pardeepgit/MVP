//
//  AppDelegate.swift
//  MVPSports
//
//  Created by Chetu India on 08/08/16.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  // MARK: UIApplication instance overriden methods for the applications state.
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    // Code to initiate DB manager singleton class instance to create database.
    DBManager.sharedInstance.createDatabase()
    
    // Crashlytics api registration.
    Fabric.with([Crashlytics.self])
    
    
    // Calling flurry api in a Main queue.
    dispatch_async(dispatch_get_main_queue(), {
      // Code to call FlurryManager singleton class method to initilize flurry session with api key.
      FlurryManager.sharedInstance.initializeFlurryWithCredentials()
    })
    
    
    /*
     * Call this method from the [UIApplicationDelegate application:didFinishLaunchingWithOptions:] method
     of the AppDelegate for your app.
     * It should be invoked for the proper use of the Facebook SDK.
     */
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Code to register mobile device for user notification setting to ask from user by prompt dialogue.
    registerForPushNotifications(application)
    
    //
    handleAppTerminateStateNotification(launchOptions)
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Code to set default api flag for local cache.
    UtilManager.sharedInstance.setDefaultApiFlagForLocalCacheFunctionality()
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    let loginManager: FBSDKLoginManager = FBSDKLoginManager()
    loginManager.logOut()
  }
  
  
  
  // MARK: APNS configuration and registrations methods.
  func registerForPushNotifications(application: UIApplication) {
    let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .None {
      application.registerForRemoteNotifications()
    }
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var tokenString = ""
    for i in 0..<deviceToken.length {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    // Code to save device token for save when user get logged-in
    NotificationAnnouncementViewModel.saveDeviceTokenForSaveToUserDefaultBy(tokenString)
    
    
    if UtilManager.sharedInstance.validateLoggedUserStatus() == true{
      let tokenForSave = NotificationAnnouncementViewModel.getDeviceTokenForSaveFromUserDefault()
      if tokenForSave.characters.count > 0{
        
        // Code to call a ASynchronous call by GCD global queue method.
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue){() -> Void in
          // Code to call class type method of NotificationAnnouncementViewModel class to save device token on to MVP server by Api services.
          NotificationAnnouncementViewModel.saveUniqueDeviceTokenToMvpServerFor(tokenForSave)
        }

      }
    }
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print("Failed to register:", error)
  }
  
  func handleAppTerminateStateNotification(notificationsOptions: [NSObject: AnyObject]?) {
    // Handle notification
    if (notificationsOptions != nil) {
      
      // For remote Notification
      if let remoteNotification = notificationsOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] {
        print(remoteNotification)
        
        // Code to set user tapped notify status to true.
        NotificationAnnouncementViewModel.setNotifyTappedStatusToUserDefaultBy(true)
      }
    }
    
    // Code to re-verify to compare saved badge count and app icon badge count
    let appIconBadgeCount = UIApplication.sharedApplication().applicationIconBadgeNumber
    let locallySavedBadgeCount = NotificationAnnouncementViewModel.getNotifyBadgeCountFromUserDefaultBy()
    if locallySavedBadgeCount != appIconBadgeCount{
      NotificationAnnouncementViewModel.setNotifyBadgeCountToUserDefaultBy(appIconBadgeCount)
    }
  }
  
  
  
  // MARK: APNS remote notification didReceive delegate methods.
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    
    var validNotifyFlag = false
    var badgeCount = 0
    if let notificationInfoDict = userInfo["aps"] as? [NSString: AnyObject]{
      if let badge = notificationInfoDict["badge"] as? Int{
        
        validNotifyFlag = true
        badgeCount = badge
      }
    }
    
    if validNotifyFlag == true{
      // Code to save current badge count to user default.
      NotificationAnnouncementViewModel.setNotifyBadgeCountToUserDefaultBy(badgeCount)
      
      // Code to set received badge count to the app icon.
      UIApplication.sharedApplication().applicationIconBadgeNumber  = badgeCount

      // Code to prepare an object for the notification centre to post with notification to get in observer of notification.
      var notificationObject = [String: String]()

      if application.applicationState == .Inactive {
        // State: Called, When user tapped on notification top alert view at the time of application is in Background mode.
        notificationObject["identifier"] = "NavigateToAnnouncementScreen"
        
        // Code to post notification from NSNotificationCenter instance for the alert bell count of notification.
        RemoteNotificationObserverManager.sharedInstance.remoteNotificationHandlerBy(notificationObject)
      }
      else if application.applicationState == .Background{
        // State: Called, When application is in Background mode and no action taken place from user on notification..
        notificationObject["identifier"] = "UpdateAlertNotificationBadgeCount"

        // Code to post notification from NSNotificationCenter instance for the alert bell count of notification.
        RemoteNotificationObserverManager.sharedInstance.remoteNotificationHandlerBy(notificationObject)
      }
      else if application.applicationState == .Active{
        // State: Called, When application is in Forground mode.
        notificationObject["identifier"] = "UpdateAlertNotificationBadgeCount"

        // Code to post notification from NSNotificationCenter instance for the alert bell count of notification.
        RemoteNotificationObserverManager.sharedInstance.remoteNotificationHandlerBy(notificationObject)
      }
    }
  }
  
  
  
  // MARK: openURL, it is used to control flow once user successfully logged in through Facebook and returning back to UI.
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool{
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
}
