//
//  RewardViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 18/08/16.
//

import Foundation
import UIKit


/*
 * RewardTypesOptionEnum entity of type enumeration for the Reward types either Active, Used or All.
 */
enum RewardTypesOptionEnum {
  case Active
  case Used
  case All
}


/*
 * LoadUrlType entity of type enumeration for the load url types.
 */
enum LoadUrlType {
  case Reward
  case FullWebSite
  case FitFreshBlog
}


/*
 * RewardViewModel class with class method declaration and defination implementaion to handle functionality of Rewards model class.
 */
class RewardViewModel {
  
  
  /*
   * parseRewardJsonResponse method parse the response json dictionary into Reward model class field.
   */
  // MARK:  parseRewardJsonResponse method.
  class func parseRewardJsonResponse(rewardsJsonData: NSData) -> [Reward] {
    var rewardResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try rewardResponseDict = (NSJSONSerialization.JSONObjectWithData(rewardsJsonData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfRewardObject = [Reward]()
    if rewardResponseDict.count > 0{
      if let arrayOfRewardJsonObject = rewardResponseDict[RESPONSE] as? [[String: AnyObject]]{
        if arrayOfRewardJsonObject.count > 0 {
          
          // Code iterate over to json object array to parse json object into Reward model class.
          for index in 0 ..< arrayOfRewardJsonObject.count {
            let rewardObjectData = arrayOfRewardJsonObject[index]
            let reward = RewardViewModel.createRewardObjectForResponseValue(rewardObjectData )
            arrayOfRewardObject.append(reward)
          }
          
        }
      }
    }
    return arrayOfRewardObject
  }
  
  
  /*
   * createRewardObjectForResponseValue method parse the response json dictionary into Reward model class field.
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createRewardObjectForResponseValue method.
  class func createRewardObjectForResponseValue(rewardResponseValue: [String: AnyObject]) -> Reward {
    
    // Code to get value from json object to populate into Reward model class object.
    let rewardObject = Reward()
    
    // Code to validate value existence for memid key field else set a defalut value to the field.
    if let memid = rewardResponseValue["memid"] as? String {
      rewardObject.memid = memid
    }
    else {
      rewardObject.memid = ""
    }
    
    // Code to validate value existence for Rewardid key field else set a defalut value to the field.
    if let rewardId = rewardResponseValue["Rewardid"] as? String {
      rewardObject.rewardId = rewardId
    }
    else {
      rewardObject.rewardId = ""
    }
    
    // Code to validate value existence for Name key field else set a defalut value to the field.
    if let name = rewardResponseValue["Name"] as? String {
      rewardObject.name = name
    }
    else {
      rewardObject.name = ""
    }
    
    // Code to validate value existence for Desc key field else set a defalut value to the field.
    if let desc = rewardResponseValue["Desc"] as? String {
      rewardObject.desc = desc
    }
    else {
      rewardObject.desc = ""
    }
    
    // Code to validate value existence for status key field else set a defalut value to the field.
    if let status = rewardResponseValue["status"] as? String {
      rewardObject.status = status
    }
    else {
      rewardObject.status = ""
    }
    
    // Code to validate value existence for emailto key field else set a defalut value to the field.
    if let emailto = rewardResponseValue["emailto"] as? Bool {
      rewardObject.emailto = emailto
    }
    else {
      rewardObject.emailto = false
    }
    
    // Code to validate value existence for RequestedDate key field else set a defalut value to the field.
    if let requestedDate = rewardResponseValue["RequestedDate"] as? String {
      rewardObject.requestedDate = requestedDate
    }
    else {
      rewardObject.requestedDate = ""
    }
    
    // Code to validate value existence for ExpirationDate key field else set a defalut value to the field.
    if let expirationDate = rewardResponseValue["ExpirationDate"] as? String {
      rewardObject.expirationDate = expirationDate
    }
    else {
      rewardObject.expirationDate = ""
    }
    
    // Code to validate value existence for FriendsEmail key field else set a defalut value to the field.
    if let friendsEmail = rewardResponseValue["FriendsEmail"] as? String {
      rewardObject.friendsEmail = friendsEmail
    }
    else {
      rewardObject.friendsEmail = ""
    }
    
    // Code to validate value existence for CopyMeOnEmail key field else set a defalut value to the field.
    if let copyMeOnEmail = rewardResponseValue["CopyMeOnEmail"] as? Bool {
      rewardObject.copyMeOnEmail = copyMeOnEmail
    }
    else {
      rewardObject.copyMeOnEmail = false
    }
    
    // Code to validate value existence for PdfUrl key field else set a defalut value to the field.
    if let pdfUrl = rewardResponseValue["PdfUrl"] as? String {
      rewardObject.pdfUrl = pdfUrl
    }
    else {
      rewardObject.pdfUrl = ""
    }
    
    return rewardObject
  }
  
  
  /*
   * validateRewardIdPdfFileExist method validate for reward pdf from local document directory folder..
   * method will return boolean value. Return true if file exist else return false.
   */
  // MARK:  validateRewardIdPdfFileExist method.
  class func validateRewardIdPdfFileExist(rewardId: String) -> Bool{
    let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
                                                                                   inDomain: .UserDomainMask,
                                                                                   appropriateForURL: nil,
                                                                                   create: true)
    let rewardPdfFileUrl = documentDirectoryURL.URLByAppendingPathComponent("\(rewardId).pdf")
    
    var error : NSError?
    let fileExists = rewardPdfFileUrl.checkResourceIsReachableAndReturnError(&error)
    
    if !fileExists{
      //print(error)
    }
    return fileExists
  }
  
  /*
   * validateRewardSendStatus method to validate reward send status.
   */
  // MARK:  validateRewardSendStatus method.
  class func validateRewardSendStatus(reward: Reward) -> Bool{
    var flag = false
    if reward.friendsEmail?.characters.count > 0{
      flag = true
    }
    else{
      flag = false
    }
    return flag
  }
  

  /*
   * validateRewardForGuestPassTypeBy method to validate reward 'Guest Pass' type of reward to return Bool flag value true or false.
   * Based on this validate Bool value we show/hide the view pdf UIButton for the reward.
   */
  // MARK:  validateRewardForGuestPassTypeBy method.
  class func validateRewardForGuestPassTypeBy(reward: Reward) -> Bool{
    let compareGuestPassStaticString = "guest pass"
    var rewardNameString = reward.name! as String
    rewardNameString = rewardNameString.lowercaseString

    var flag = false
    if rewardNameString.containsString(compareGuestPassStaticString){
      flag = true
    }
    else{
      flag = false
    }
    return flag
  }

  
  
  /*
   * filterArrayOfRewardsWithType methos to filter the arrayd of rewards based on the type of filter option.
   */
  // MARK:  filterArrayOfRewardsWithType method.
  class func filterArrayOfRewardsWithType(type: RewardTypesOptionEnum, And arrayOfRewards: [Reward]) -> [Reward] {
    var filteredRewardsArray = [Reward]()
    
    for index in 0..<arrayOfRewards.count{
      let reward = arrayOfRewards[index] as Reward
      let rewardStatus = reward.status! as String
      print(rewardStatus)
      
      switch type {
      case RewardTypesOptionEnum.Active:
        if rewardStatus == "valid"{
          filteredRewardsArray.append(arrayOfRewards[index])
        }
        break

      case RewardTypesOptionEnum.Used:
        if rewardStatus != "valid"{
          filteredRewardsArray.append(arrayOfRewards[index])
        }
        break

      case RewardTypesOptionEnum.All:
        break
      }
    }
    
    return filteredRewardsArray
  }
  
  
  /*
   * getRewardUsedToDateStringFrom method MM/dd/yyyy.
   */
  // MARK:  getRewardUsedToDateStringFrom method.
  class func getRewardUsedToDateStringFrom(expiredDate: String) -> String{
    var rewardUsedToDateString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = REWARDEXPIREDDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(expiredDate)
    
    dateFormatter.dateFormat = REWARDUSEDTODATEFORMATTER
    rewardUsedToDateString = dateFormatter.stringFromDate(dateObj!) as String
    
    return rewardUsedToDateString
  }
  
}
