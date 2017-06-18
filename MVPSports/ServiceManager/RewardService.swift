//
//  RewardService.swift
//  MVPSports
//
//  Created by Chetu India on 18/08/16.
//

import Foundation


// RewardServiceCompletion declare callback for RewardService class method with parameter.
typealias RewardServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()
typealias RewardPdfFileDownloadCompletion = (ApiResponseStatusEnum, AnyObject) -> ()
typealias HeatlhPointLevelServiceCompletion = (ApiResponseStatusEnum, [[String : AnyObject]]) -> ()
typealias MemberHeatlhPointServiceCompletion = (ApiResponseStatusEnum, Int) -> ()
typealias UserOptInStatusServiceCompletion = (ApiResponseStatusEnum, UserOptInStatusEnum) -> ()
typealias UserPunchCardServiceCompletion = (ApiResponseStatusEnum, (String, String)) -> ()


/*
 * SiteClubApiTypesEnum is an enumeration of Site Club Api request.
 */
enum UserRewardApiTypesEnum {
  case GetReward
  case SendReward
  case UserPunchCard
  case HealthPointLevel
  case MemberHealthPoint
}


/*
 * RewardService class with class method declaration and defination implementaion to handle functionality of GetRewards api endpoint.
 */
class RewardService {
  
  
  // MARK:  getMyMvpRewardBy method.
  class func getMyMvpRewardBy(inputFields: [ String: String], completion: RewardServiceCompletion) {
    let request = RewardService.prepareRewardApiRequestObjectBy(inputFields, forApiType: UserRewardApiTypesEnum.GetReward)
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
//      let rewardsJsonString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//      print("Response json is :\n\(rewardsJsonString)")

      if status == ApiResponseStatusEnum.Success{
        let arrayOfRewardsObject = RewardViewModel.parseRewardJsonResponse(responseData as! NSData)
        completion(status, arrayOfRewardsObject)
      }
      else{
        let arrayOfRewardObject = [Reward]()
        completion(status, arrayOfRewardObject)
      }
    })
  }
  
  
  // MARK:  sendRewardToFriendEmailServiceBy method.
  class func sendRewardToFriendEmailServiceBy(inputFields: [ String: String], completion: RewardServiceCompletion) {
    let request = RewardService.prepareRewardApiRequestObjectBy(inputFields, forApiType: UserRewardApiTypesEnum.SendReward)
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        completion(status, "")
      }
      else{
        completion(status, "")
      }
    })
  }

  
  // MARK:  downloadRewardPdfFileFromUrl method.
  class func downloadRewardPdfFileFromUrl(URL: NSURL, completion: RewardPdfFileDownloadCompletion) {
    // Code to create request object for the GET method of download PDF from url.
    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = "GET"
    
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      if error == nil{
        completion(ApiResponseStatusEnum.Success, data!)
      }
      else{
        let data = NSData()
        completion(ApiResponseStatusEnum.Failure, data)
      }
    })
    
    task.resume()
  }
  
  
  // MARK:  getUserOptInStatusBy method.
  class func getUserOptInStatusBy(inputFields: [ String: String], completion: UserOptInStatusServiceCompletion) {

    // Request format in url encoded format for the request.
    let keyArray = Array(inputFields.keys)
    var postString = ""
    
    for index in 0 ..< keyArray.count{
      let key = keyArray[index] as String
      let value = inputFields[key]! as String
      
      if index == keyArray.count-1{
        postString = "\(postString)\(key)=\(value)"
      }
      else{
        postString = "\(postString)\(key)=\(value)&"
      }
    }
    
    let postData: NSData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
    let postLength: String = "\(postData.length)"
    
    // Code to create NSMutableURLRequest object for header of SiteClasses.
    let request = NetworkManager.requestHeaderForApiByUrl(getUserOptInStatusServiceURL)
    request.setValue(postLength, forHTTPHeaderField: "Content-Length")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = postData
    
    // Code to hit web api request header to get user OptIn Status.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      
      if status == ApiResponseStatusEnum.Success{
        let optInStatusType = BarChartViewModel.parseOptInStatusResponse(responseData as! NSData)
        completion(status, optInStatusType)
      }
      else{
        let optInStatusType = UserOptInStatusEnum.DefaultUpChart
        completion(status, optInStatusType)
      }
    })
  }
  
  
  // MARK:  getUserPunchCardBy method.
  class func getUserPunchCardBy(inputFields: [ String: String], completion: UserPunchCardServiceCompletion) {
    let request = RewardService.prepareRewardApiRequestObjectBy(inputFields, forApiType: UserRewardApiTypesEnum.UserPunchCard)
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in

      if status == ApiResponseStatusEnum.Success{
        let punchCardTupple = BarChartViewModel.parseUserPunchCardResponse(responseData as! NSData)
        completion(status, punchCardTupple)
      }
      else{
        completion(status, ("0", "0"))
      }
    })
  }
  
  
  // MARK:  getHealthPointLevelsBy method.
  class func getHealthPointLevelsBy(inputFields: [ String: String], completion: HeatlhPointLevelServiceCompletion) {
    let request = RewardService.prepareRewardApiRequestObjectBy(inputFields, forApiType: UserRewardApiTypesEnum.HealthPointLevel)
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        let arrayOfHealthPointLevelObject = BarChartViewModel.parseHealthPointLevelResponse(responseData as! NSData)
        completion(status, arrayOfHealthPointLevelObject)
      }
      else{
        let arrayOfHealthPointLevelObject = [[String : AnyObject]]()
        completion(status, arrayOfHealthPointLevelObject)
      }
    })
  }
  
  
  // MARK:  getMemberHealthPointsBy method.
  class func getMemberHealthPointsBy(inputFields: [ String: String], completion: MemberHeatlhPointServiceCompletion) {
    let request = RewardService.prepareRewardApiRequestObjectBy(inputFields, forApiType: UserRewardApiTypesEnum.MemberHealthPoint)
    
    // Code to hit web api request header to fetch member health points.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        let memberEarnedPointLevel = BarChartViewModel.parseMemberHealthPointResponseForEarnedPoint(responseData as! NSData)
        completion(status, memberEarnedPointLevel)
      }
      else{
        completion(status, 0)
      }
    })
  }
  
  
  // MARK:  prepareRewardApiRequestObjectBy method.
  class func prepareRewardApiRequestObjectBy(inputFields: [ String: String], forApiType type: UserRewardApiTypesEnum) -> NSMutableURLRequest {
    var apiUrl = ""
    switch type {
    case UserRewardApiTypesEnum.GetReward:
      apiUrl = rewardServiceURL
      
    case UserRewardApiTypesEnum.SendReward:
      apiUrl = sendShowRewardToFriendEmailServiceURL
      
    case UserRewardApiTypesEnum.UserPunchCard:
      apiUrl = getUserPunchCardServiceURL
      
    case UserRewardApiTypesEnum.HealthPointLevel:
      apiUrl = getHealthPointLevelsServiceURL

    case UserRewardApiTypesEnum.MemberHealthPoint:
      apiUrl = getMemberHealthPointServiceURL
    }
    
    // Code to create NSMutableURLRequest object for header of Auth user Api request.
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