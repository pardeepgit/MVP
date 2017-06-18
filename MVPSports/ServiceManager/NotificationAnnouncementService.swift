//
//  NotificationAnnouncementService.swift
//  MVPSports
//
//  Created by Chetu India on 20/01/17.
//

import Foundation

// SetMemberMobileTokenServiceCompletion declare callback closure for SetMemberMobileToken class method with parameter.
typealias SetMemberMobileTokenServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()
typealias SetMemberZeroNotificationCountServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()
typealias AnnouncementNotificationServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()
typealias DeleteAnnouncementNotificationServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


class NotificationAnnouncementService {
  
  
  // MARK:  saveMobileDeviceTokenBy method.
  class func saveMobileDeviceTokenBy(inputFields: [ String: String], completion: SetMemberMobileTokenServiceCompletion) {
    
    // Code to create NSMutableURLRequest object for header of SetMemberMobileToken.
    let request = NetworkManager.requestHeaderForApiByUrl(setMemberMobileTokenServiceURL)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to mark site class check in.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
//      let sendCommentResponseJsonString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//      print("Response json is :\n\(sendCommentResponseJsonString)")

      // Code to call completion block.
      completion(apiStatus, "")
    })
  }

  
  // MARK:  saveZeroNotificationCount method.
  class func saveZeroNotificationCount(inputFields: [ String: String], completion: SetMemberZeroNotificationCountServiceCompletion) {
    
    // Code to create NSMutableURLRequest object for header of setZeroNotificationCountServiceURL.
    let request = NetworkManager.requestHeaderForApiByUrl(setZeroNotificationCountServiceURL)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to mark site class check in.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
      
      // Code to call completion block.
      completion(apiStatus, "")
    })
  }

  
  // MARK:  getMyAnnouncementNotificationsBy method.
  class func getMyAnnouncementNotificationsBy(inputFields: [ String: String], completion: AnnouncementNotificationServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of GetClubNotification.
    let request = NetworkManager.requestHeaderForApiByUrl(announcementNotificationServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        let arrayOfAnnouncementNotificationsObject = NotificationAnnouncementViewModel.parseGetClubNotificationsJsonResponse(responseData as! NSData)
        completion(status, arrayOfAnnouncementNotificationsObject)
      }
      else{
        let arrayOfAnnouncementNotificationsObject = [[String: AnyObject]]()
        completion(status, arrayOfAnnouncementNotificationsObject)
      }
    })
    
  }
  
  
  // MARK:  deleteNotificationAnnouncementBy method.
  class func deleteNotificationAnnouncementBy(inputFields: [ String: String], completion: DeleteAnnouncementNotificationServiceCompletion) {
    
    // Code to create NSMutableURLRequest object for header of DeleteIndivualNotification.
    let request = NetworkManager.requestHeaderForApiByUrl(deleteNotificationServiceURL)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to mark site class check in.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
      // Code to call completion block.
      completion(apiStatus, responseData)
    })
  }
  
}