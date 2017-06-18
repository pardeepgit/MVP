//
//  NotificationAnnouncementViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 20/01/17.
//

import Foundation
import UIKit


/*
 * NotificationAnnouncementViewModel class implements class method declaration and defination to handle the functionality of APNS and Announcement module of application.
 */
class NotificationAnnouncementViewModel {
  
  
  
  /*
   * parseGetClubNotificationsJsonResponse method parse the response json dictionary into Array of String.
   */
  // MARK:  parseGetClubNotificationsJsonResponse method.
  class func parseGetClubNotificationsJsonResponse(notificationJsonData: NSData) -> [[String: AnyObject]] {
    var notificationsResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try notificationsResponseDict = (NSJSONSerialization.JSONObjectWithData(notificationJsonData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfNotificationsObjects = [[String: AnyObject]]()
    
    if notificationsResponseDict.count > 0{
      if let arrayOfNotificationsJsonObject = notificationsResponseDict[RESPONSE] as? [[String: AnyObject]]{
        if arrayOfNotificationsJsonObject.count > 0 {
          
          // Code iterate over to json object array to parse json object into Workout model class.
          for index in 0 ..< arrayOfNotificationsJsonObject.count {
            let notificationObject = arrayOfNotificationsJsonObject[index]
            
            var notificationObjectDict =  [String: AnyObject]()
            if let notificationDesc = notificationObject["notification"] as? String{
              notificationObjectDict["notification"] = notificationDesc
            }
            else{
              notificationObjectDict["notification"] = ""
            }
            
            if let notificationIndex = notificationObject["NotificationIndex"] as? Int{
              notificationObjectDict["NotificationIndex"] = notificationIndex
            }
            else{
              notificationObjectDict["NotificationIndex"] = 0
            }

            arrayOfNotificationsObjects.append(notificationObjectDict)
          }
          
        }
      }
    }
    
    return arrayOfNotificationsObjects
  }
  
  
  
  // MARK:  updateBadgeCountToUIOf method.
  class func updateBadgeCountToUIOf(badgeLabel: UILabel){
    badgeLabel.layer.cornerRadius = VALUENINECORNERRADIUS
    badgeLabel.layer.masksToBounds = true
    
    let badgeCount = NotificationAnnouncementViewModel.getNotifyBadgeCountFromUserDefaultBy()
    if badgeCount == 0{
      badgeLabel.hidden = true
      badgeLabel.text = "\(badgeCount)"
    }
    else{
      badgeLabel.hidden = false
      badgeLabel.text = "\(badgeCount)"
    }
  }
  
  
  
  /*
   * saveUniqueDeviceTokenToMvpServerFor method to execute api endpoint service to save device token onto mvp server database for the logged user memid.
   */
  // MARK:  saveUniqueDeviceTokenToMvpServerFor method.
  class func saveUniqueDeviceTokenToMvpServerFor(token: String){
    let loggedUserDict = UserViewModel.getUserDictFromUserDefaut()
    let memid = loggedUserDict["memberId"]! as String

    var inputParam = [String: String]()
    inputParam["memid"] = memid
    inputParam["mobiletoken"] = token
    inputParam["type"] = "2"

    NotificationAnnouncementService.saveMobileDeviceTokenBy(inputParam, completion: {(apiStatus, response) ->() in
      
      // Code to save new device token locally for user default.
      if apiStatus == ApiResponseStatusEnum.Success{
        
        // Code to call method to save new device token.
        NotificationAnnouncementViewModel.saveDeviceTokenToUserDefaultBy(token)
      }
    })
  }
  
  // MARK:  validateDeviceTokenFromPreviousTokenValueBy method.
  class func validateDeviceTokenFromPreviousTokenValueBy(token: String) -> Bool{
    var tokenValidationFlag = false
    let oldDeviceToken = NotificationAnnouncementViewModel.getDeviceTokenFromUserDefault()
    
    if oldDeviceToken == token{
      tokenValidationFlag = true
    }
    else{
      tokenValidationFlag = false
    }
    return tokenValidationFlag
  }
  
  

  
  // MARK:  saveDeviceTokenForSaveToUserDefaultBy method.
  class func saveDeviceTokenForSaveToUserDefaultBy(token: String){
    NSUserDefaults.standardUserDefaults().setValue(token, forKey: "DeviceTokenForSave")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  // MARK:  getDeviceTokenForSaveFromUserDefault method.
  class func getDeviceTokenForSaveFromUserDefault() -> String{
    if let deviceToken = NSUserDefaults.standardUserDefaults().valueForKey("DeviceTokenForSave") as? String{
      return deviceToken
    }
    else{
      return ""
    }
  }
  
  // MARK:  saveDeviceTokenToUserDefaultBy method.
  class func saveDeviceTokenToUserDefaultBy(token: String){
    NSUserDefaults.standardUserDefaults().setValue(token, forKey: "DeviceToken")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  // MARK:  getDeviceTokenFromUserDefault method.
  class func getDeviceTokenFromUserDefault() -> String{
    if let deviceToken = NSUserDefaults.standardUserDefaults().valueForKey("DeviceToken") as? String{
      return deviceToken
    }
    else{
      return ""
    }
  }
  
  
  
  // MARK:  setNotifyTappedStatusToUserDefaultBy method.
  class func setNotifyTappedStatusToUserDefaultBy(status: Bool){
    NSUserDefaults.standardUserDefaults().setValue(status, forKey: "AppNotify")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  // MARK:  getNotifyTappedStatusToUserDefaultBy method.
  class func getNotifyTappedStatusFromUserDefaultBy() -> Bool{
    if let status = NSUserDefaults.standardUserDefaults().valueForKey("AppNotify") as? Bool{
      return status
    }
    else{
      return false
    }
  }
  
  
  
  // MARK:  setNotifyBadgeCountToUserDefaultBy method.
  class func setNotifyBadgeCountToUserDefaultBy(badgeCount: Int){
    NSUserDefaults.standardUserDefaults().setValue(badgeCount, forKey: "BadgeCount")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  // MARK:  getNotifyBadgeCountToUserDefaultBy method.
  class func getNotifyBadgeCountFromUserDefaultBy() -> Int{
    if let badgeCount = NSUserDefaults.standardUserDefaults().valueForKey("BadgeCount") as? Int{
      return badgeCount
    }
    else{
      return 0
    }
  }
  
  
}