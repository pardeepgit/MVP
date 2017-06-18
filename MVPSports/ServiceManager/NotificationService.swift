//
//  NotificationService.swift
//  MVPSports
//
//  Created by Chetu India on 06/09/16.
//

import Foundation


// NotificationServiceCompletion declare callback for NotificationService class method with parameter.
typealias NotificationServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


class NotificationService {

  // MARK:  getMyMvpRewardBy method.
  class func getNotificationClubBy(inputFields: [ String: String], completion: NotificationServiceCompletion) {
    let siteClubsRequest = NetworkManager.requestHeaderForApiByUrl(getClubNamesServiceURL)
    
    // Code to execute web api siteClubsRequest header to fetch list of all Site Club.
    NetworkManager.requestApi(siteClubsRequest, completion: { (status, siteClubResponseData) -> () in
      
      if status == ApiResponseStatusEnum.Success{
        // Code to get array of Site Club from api response after parsing.
        let arrayOfSiteClubsObject = NotificationClubsViewModel.parseSiteClubsResponseData(siteClubResponseData as! NSData)

        // Code to create NSMutableURLRequest object for header of GetClubToNotify.
        let request = NetworkManager.requestHeaderForApiByUrl(getClubToNotifyServiceURL)
        do {
          let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
          request.HTTPBody = jsonData
        }
        catch _ as NSError {
        }

        NetworkManager.requestApi(request, completion: { (notifyClubStatus, notifySiteClubData) -> () in
          if notifyClubStatus == ApiResponseStatusEnum.Success{
            // Code to get array of Notify Site Club from api response after parsing.
            let arrayOfNotifySiteClubsObject = NotificationClubsViewModel.parseNotifySiteClubsResponseData(notifySiteClubData as! NSData)

            // Code to merger SiteClub and Notify Siste Club response.
            let arrayOfSiteClubToNotify = NotificationClubsViewModel.getCommonNotifySiteClubFrom(arrayOfSiteClubsObject, with: arrayOfNotifySiteClubsObject)
            
            completion(status, arrayOfSiteClubToNotify)
          }
          else{
            completion(status, arrayOfSiteClubsObject)
          }
        })
      }
      else{
        let arrayOfSiteClubsToNotify = [NotificationClub]()
        completion(status, arrayOfSiteClubsToNotify)
      }
      
    })
    
  }
  
  
  // MARK:  writeNotificationClubActivationStatus method.
  class func writeNotificationClubActivationStatus(inputFields: [[String: AnyObject]], completion: NotificationServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of SetClubToNotify.
    let request = NetworkManager.requestHeaderForApiByUrl(setClubToNotifyServiceURL)
    
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
        completion(status, responseData)
      }
      else{
        completion(status, responseData)
      }
    })
  }
  
  
  // MARK:  GetConnectedAppsBy method.
  class func getConnectedAppsBy(inputFields: [ String: String], completion: NotificationServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of GetConnectedAppsStatus.
    let request = NetworkManager.requestHeaderForApiByUrl(getConnectedAppsServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, appData) -> () in
      if status == ApiResponseStatusEnum.Success{
//         let responseJsonString = NSString(data: appData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//         print("Response json is :\n\(responseJsonString)")
        let arrayOfConnectedApp = NotificationClubsViewModel.parseConnectedAppsJsonResponseData(appData as! NSData)
        completion(status, arrayOfConnectedApp)
      }
      else{
        let arrayOfConnectedApp = [ConnectedApp]()
        completion(status, arrayOfConnectedApp)
      }
    })
  }
  
  
  // MARK:  GetConnectedAppsBy method.
  class func saveDeviceSettingBy(inputFields: [ String: String], completion: NotificationServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of SaveDeviceSetting.
    let request = NetworkManager.requestHeaderForApiByUrl(saveDeviceSettingServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, appData) -> () in
      if status == ApiResponseStatusEnum.Success{
        completion(status, appData)
      }
      else{
        completion(status, appData)
      }
    })
  }
  
}