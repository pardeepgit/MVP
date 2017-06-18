//
//  SiteClubService.swift
//  MVPSports
//
//  Created by Chetu India on 30/09/16.
//

import Foundation


// SiteClubServiceCompletion declare callback for SiteClubService class method with parameter.
typealias SiteClubServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


/*
 * SiteClubApiTypesEnum is an enumeration of Site Club Api request.
 */
enum SiteClubApiTypesEnum {
  case GetDefaultSiteClub
  case SetDefaultSiteClub
  case GetSiteClub
  case GetSiteClubInstructor
  case GetCommentCardOption
}


class SiteClubService {
  
  // MARK:  getDefaultSiteClubsBy method.
  class func getDefaultSiteClubsBy(inputFields: [ String: String], completion: SiteClubServiceCompletion) {
    let request = SiteClubService.prepareApiRequestObjectForSiteClubBy(inputFields, forApiType: SiteClubApiTypesEnum.GetDefaultSiteClub)
    
    // Code to hit web api request header to fetch site clubs.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseClubData) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{
        // Code when api response get success and parse the response data send in a callback method.
        let arrayOfSiteClubsObject = SiteClubsViewModel.parseSiteClubJsonResponseData(responseClubData as! NSData, with: "")
        completion(apiStatus, arrayOfSiteClubsObject)
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        let arrayOfSiteClubsObject = [SiteClub]()
        completion(apiStatus, arrayOfSiteClubsObject)
      }
      else{ // For Network error
        let arrayOfSiteClubsObject = [SiteClub]()
        completion(apiStatus, arrayOfSiteClubsObject)
      }
    })
  }
  
  
  // MARK:  getSiteClubsBy method.
  class func getSiteClubsBy(inputFields: [ String: String], completion: SiteClubServiceCompletion) {
    let request = SiteClubService.prepareApiRequestObjectForSiteClubBy(inputFields, forApiType: SiteClubApiTypesEnum.GetSiteClub)
    
    // Code to hit web api request header to fetch site clubs.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseClubData) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{
        // let siteClubsJsonString = NSString(data: responseClubData as! NSData, encoding: NSUTF8StringEncoding)  as! String
        // print("Response json is :\n\(siteClubsJsonString)")
        
        var siteId = ""
        let loggedUserStatus = UtilManager.sharedInstance.validateLoggedUserStatus()
        if loggedUserStatus ==  true{
          var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
          if let siteid = loggedUserDict["Siteid"]{
            siteId = siteid as String
          }
        }
        else{
          var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
          if let siteid = unLoggedUserDict["siteId"]{
            siteId = siteid as String
          }
        }
        
        let arrayOfSiteClubsObject = SiteClubsViewModel.parseSiteClubJsonResponseData(responseClubData as! NSData, with: siteId)
        completion(apiStatus, arrayOfSiteClubsObject)
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        let arrayOfSiteClubsObject = [SiteClub]()
        completion(apiStatus, arrayOfSiteClubsObject)
      }
      else{ // For Network error
        let arrayOfSiteClubsObject = [SiteClub]()
        completion(apiStatus, arrayOfSiteClubsObject)
      }
    })
  }
  

  // MARK:  setDefaultSiteClubsBy method.
  class func setDefaultSiteClubsBy(inputFields: [ String: String], completion: SiteClubServiceCompletion) {
    let request = SiteClubService.prepareApiRequestObjectForSiteClubBy(inputFields, forApiType: SiteClubApiTypesEnum.SetDefaultSiteClub)
    
    // Code to hit web api request header to fetch site clubs.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{
        completion(apiStatus, "")
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        completion(apiStatus, "")
      }
      else{ // For Network error
        completion(apiStatus, "")
      }
    })
  }
  

  // MARK:  getSiteClubInstructorBy method.
  class func getSiteClubInstructorBy(inputFields: [ String: String], completion: SiteClubServiceCompletion) {
    let request = SiteClubService.prepareApiRequestObjectForSiteClubBy(inputFields, forApiType: SiteClubApiTypesEnum.GetSiteClubInstructor)
    
    // Code to hit web api request header to fetch Classes/GetTrainerInfo.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{
        completion(apiStatus, responseData)
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        completion(apiStatus, responseData)
      }
      else{ // For Network error
        completion(apiStatus, responseData)
      }
    })
  }
  
  
  // MARK:  getCommentCardSelectOptionBy method.
  class func getCommentCardSelectOptionBy(inputFields: [ String: String], completion: SiteClubServiceCompletion) {
    let request = SiteClubService.prepareApiRequestObjectForSiteClubBy(inputFields, forApiType: SiteClubApiTypesEnum.GetCommentCardOption)
    
    // Code to hit web api request header to fetch site clubs.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{
        // Code when api response get success and parse the response data send in a callback method.
        let arrayOfCommentCardOptionObject = SiteClubsViewModel.parseCommentCardSelectOptionResponseData(responseData as! NSData)
        completion(apiStatus, arrayOfCommentCardOptionObject)
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        let arrayOfCommentCardOptionObject = [[String: AnyObject]]()
        completion(apiStatus, arrayOfCommentCardOptionObject)
      }
      else{ // For Network error
        let arrayOfCommentCardOptionObject = [[String: AnyObject]]()
        completion(apiStatus, arrayOfCommentCardOptionObject)
      }
    })
  }
  
  
  // MARK:  prepareApiRequestObjectForSiteClubBy method.
  class func prepareApiRequestObjectForSiteClubBy(inputFields: [ String: String], forApiType type: SiteClubApiTypesEnum) -> NSMutableURLRequest {
    var apiUrl = ""
    switch type {
    case SiteClubApiTypesEnum.GetDefaultSiteClub:
      apiUrl = getSiteClubServiceURL
      
    case SiteClubApiTypesEnum.SetDefaultSiteClub:
      apiUrl = setDefaultSiteClubServiceURL

    case SiteClubApiTypesEnum.GetSiteClub:
      apiUrl = getSiteClubServiceURL

    case SiteClubApiTypesEnum.GetSiteClubInstructor:
      apiUrl = getSiteClubTrainerInfoServiceURL

    case SiteClubApiTypesEnum.GetCommentCardOption:
      apiUrl = getCommentCardSelectOptionServiceURL
    }
    
    // Code to create NSMutableURLRequest object for header of Site Club Api request.
    let request = NetworkManager.requestHeaderForApiByUrl(apiUrl)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }

    return request
  }

  
}