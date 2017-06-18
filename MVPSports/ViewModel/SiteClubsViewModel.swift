//
//  SiteClubsViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 03/10/16.
//

import Foundation
import UIKit


/*
 * SiteClubsViewModel class with class method declaration and defination implementaion to handle functionality of SiteClub model class.
 *
 */
class SiteClubsViewModel {
  
  /*
   * parseSiteClubJsonResponseData method parse the response json NSData into SiteClub model class field.
   * Class method to parse Site Clubs with logged user default site club to mark SiteClass model class isUserDafault field boolean true.
   */
  // MARK:  parseSiteClubJsonResponseData method.
  class func parseSiteClubJsonResponseData(siteClubsResponseData: NSData, with userDefaultSiteClubId: String) -> [SiteClub] {
    var siteClubsResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try siteClubsResponseDict = (NSJSONSerialization.JSONObjectWithData(siteClubsResponseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfSiteClubsObject = [SiteClub]()
    var arrayOfSiteClubsJsonObject = [[String: AnyObject]]()
    if siteClubsResponseDict.count > 0{
      if let siteClubObjectArray = siteClubsResponseDict[RESPONSE] as? [[String: AnyObject]]{
        arrayOfSiteClubsJsonObject = siteClubObjectArray
      }
    }
    
    if arrayOfSiteClubsJsonObject.count > 0 {
      // Code iterate over to json object array to parse json object into SiteClub model class.
      for index in 0 ..< arrayOfSiteClubsJsonObject.count {
        let siteClubObjectData = arrayOfSiteClubsJsonObject[index]
        let siteClub = SiteClubsViewModel.createSiteClubObjectForResponseValue(siteClubObjectData)
        
        if userDefaultSiteClubId == siteClub.clubid! as String{
          siteClub.isUserDafault = true
        }
        arrayOfSiteClubsObject.append(siteClub)
      }
    }
    
    return arrayOfSiteClubsObject
  }

  
  /*
   * createSiteClubObjectForResponseValue method parse the response json dictionary into SiteClub model class field.
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createSiteClubObjectForResponseValue method.
  class func createSiteClubObjectForResponseValue(siteClubResponseValue: [String: AnyObject]) -> SiteClub {
    // Code to get value from json object to populate into SiteClub model class object.
    let siteClub = SiteClub()
    
    // Code to validate value existence for clubid key field else set a defalut value to the field.
    if let clubid = siteClubResponseValue["clubid"] as? String {
      siteClub.clubid = clubid
    }
    else {
      siteClub.clubid = ""
    }
    
    // Code to validate value existence for ClubName key field else set a defalut value to the field.
    if let clubName = siteClubResponseValue["ClubName"] as? String {
      siteClub.clubName = clubName
    }
    else {
      siteClub.clubName = ""
    }
    
    // Code to validate value existence for address key field else set a defalut value to the field.
    if let address = siteClubResponseValue["address"] as? String {
      siteClub.address = address
    }
    else {
      siteClub.address = ""
    }
    
    // Code to validate value existence for phone key field else set a defalut value to the field.
    if let phone = siteClubResponseValue["phone"] as? String {
      siteClub.phone = phone
    }
    else {
      siteClub.phone = ""
    }
    
    // Code to validate value existence for email key field else set a defalut value to the field.
    if let email = siteClubResponseValue["email"] as? String {
      siteClub.email = email
    }
    else {
      siteClub.email = ""
    }
    
    // Code to validate value existence for lat key field else set a defalut value to the field.
    if let lat = siteClubResponseValue["lat"] as? String {
      siteClub.lat = lat
    }
    else {
      siteClub.lat = ""
    }
    
    // Code to validate value existence for long key field else set a defalut value to the field.
    if let lang = siteClubResponseValue["LONG"] as? String {
      siteClub.lang = lang
    }
    else {
      siteClub.lang = ""
    }

    // Code to validate value existence for facebook key field else set a defalut value to the field.
    if let facebook = siteClubResponseValue["facebook"] as? String {
      siteClub.facebookPageUrl = facebook
    }
    else {
      siteClub.facebookPageUrl = ""
    }

    // Code to validate value existence for instagram key field else set a defalut value to the field.
    if let instagram = siteClubResponseValue["instagram"] as? String {
      siteClub.instagramPageUrl = instagram
    }
    else {
      siteClub.instagramPageUrl = ""
    }

    // Code to validate value existence for twitter key field else set a defalut value to the field.
    if let twitter = siteClubResponseValue["twitter"] as? String {
      siteClub.twitterPageUrl = twitter
    }
    else {
      siteClub.twitterPageUrl = ""
    }

    // Code to validate value existence for youtube key field else set a defalut value to the field.
    if let youtube = siteClubResponseValue["youtube"] as? String {
      siteClub.youtubePageUrl = youtube
    }
    else {
      siteClub.youtubePageUrl = ""
    }

    // Code to validate value existence for website key field else set a defalut value to the field.
    if let website = siteClubResponseValue["website"] as? String {
      siteClub.fullWebSiteUrl = website
    }
    else {
      siteClub.fullWebSiteUrl = ""
    }
    
    // Code to validate value existence for operations key field else set a defalut value to the field.
    if let operations = siteClubResponseValue["operations"] as? String {
      siteClub.operations = operations
    }
    else {
      siteClub.operations = ""
    }
    
    // Code to validate value existence for operations2 key field else set a defalut value to the field.
    if let operations2 = siteClubResponseValue["operations2"] as? String {
      siteClub.operations2 = operations2
    }
    else {
      siteClub.operations2 = ""
    }
    
    // Code to validate value existence for operations3 key field else set a defalut value to the field.
    if let operations3 = siteClubResponseValue["operations3"] as? String {
      siteClub.operations3 = operations3
    }
    else {
      siteClub.operations3 = ""
    }
    
    // Code to validate value existence for operations4 key field else set a defalut value to the field.
    if let operations4 = siteClubResponseValue["operations4"] as? String {
      siteClub.operations4 = operations4
    }
    else {
      siteClub.operations4 = ""
    }
    
    // Code to validate value existence for operations5 key field else set a defalut value to the field.
    if let operations5 = siteClubResponseValue["operations5"] as? String {
      siteClub.operations5 = operations5
    }
    else {
      siteClub.operations5 = ""
    }
    
    // Code to validate value existence for operations6 key field else set a defalut value to the field.
    if let operations6 = siteClubResponseValue["operations6"] as? String {
      siteClub.operations6 = operations6
    }
    else {
      siteClub.operations6 = ""
    }
    
    // Code to validate value existence for operations7 key field else set a defalut value to the field.
    if let operations7 = siteClubResponseValue["operations7"] as? String {
      siteClub.operations7 = operations7
    }
    else {
      siteClub.operations7 = ""
    }
    
    // Code to validate value existence for operations8 key field else set a defalut value to the field.
    if let operations8 = siteClubResponseValue["operations8"] as? String {
      siteClub.operations8 = operations8
    }
    else {
      siteClub.operations8 = ""
    }

    siteClub.isUserDafault = false
    
    return siteClub
  }
  
  
  /*
   * parseCommentCardSelectOptionResponseData method parse the response json NSData into Comment Card Select Option dictionary object.
   */
  // MARK:  parseCommentCardSelectOptionResponseData method.
  class func parseCommentCardSelectOptionResponseData(responseData: NSData) -> [[String: AnyObject]] {
    var commentCardOptionResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try commentCardOptionResponseDict = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfCommentCardOptionObject = [[String: AnyObject]]()
    if commentCardOptionResponseDict.count > 0{
      if let commentCardObjectArray = commentCardOptionResponseDict[RESPONSE] as? [[String: AnyObject]]{
        arrayOfCommentCardOptionObject = commentCardObjectArray
      }
    }
    
    return arrayOfCommentCardOptionObject
  }

  
  /*
   * parseSiteClubTrainerInstructorInfoResponseData method to parse api response NSData into array of Site Class trainer Instructor info.
   */
  // MARK:  parseSiteClubTrainerInstructorInfoResponseData method.
  class func parseSiteClubTrainerInstructorInfoResponseData(responseData: NSData) -> [[String: AnyObject]] {
    var instructorArrayResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try instructorArrayResponseDict = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfInstructorDetail = [[String: AnyObject]]()
    if instructorArrayResponseDict.count > 0{
      if let instructorObjectArray = instructorArrayResponseDict[RESPONSE] as? [[String: AnyObject]]{
        arrayOfInstructorDetail = instructorObjectArray
      }
    }

    return arrayOfInstructorDetail
  }
  
  
  /*
   * getSiteClubLocationTruncatedLabelStringFrom method truncate the location string based on label width and font size of label.
   */
  // MARK:  getSiteClubLocationTruncatedLabelStringFrom method.
  class func getSiteClubLocationTruncatedLabelStringFrom(location: String, font: UIFont, labelWidth: CGFloat) -> String {
    var truncatedString = ""
    let locationString: NSString = location as NSString
    let size = locationString.sizeWithAttributes([NSFontAttributeName: font])
    let stringWidth = size.width
    
    if stringWidth > labelWidth{
      let largerWidth = stringWidth - labelWidth
      let stringWidthInInt: Int = Int(stringWidth)
      let largerWidthInInt: Int = Int(largerWidth)
      
      let propotionIncrease = (largerWidthInInt * 100) / stringWidthInInt

      let stringLength = locationString.length
      var stringPerpotionalLength = (stringLength * propotionIncrease) / 100
      stringPerpotionalLength = stringPerpotionalLength + 2

      let string: String = locationString as String
      truncatedString = string[string.startIndex...string.endIndex.advancedBy(-stringPerpotionalLength)]
    }
    else{
      truncatedString = locationString as String
    }

    return truncatedString
  }
  
  

  
  /*
   * getSiteClubOperationScheduleBy method to prepare string for the Site Club operation.
   */
  // MARK:  getSiteClubOperationScheduleBy method.
  class func getSiteClubOperationScheduleBy(siteClub: SiteClub) -> String{
    var operationSchedule = ""
    
    if let operation1 = siteClub.operations{
      if operation1.characters.count > 0{
        operationSchedule = operation1
      }
    }
    
    if let operation2 = siteClub.operations2{
      if operation2.characters.count > 0{
        operationSchedule = "\(operationSchedule)\n\(operation2)"
      }
    }

    if let operation3 = siteClub.operations3{
      if operation3.characters.count > 0{
        operationSchedule = "\(operationSchedule)\n\(operation3)"
      }
    }

    if let operation4 = siteClub.operations4{
      if operation4.characters.count > 0{
        operationSchedule = "\(operationSchedule)\n\(operation4)"
      }
    }

    if let operation5 = siteClub.operations5{
      if operation5.characters.count > 0{
        operationSchedule = "\(operationSchedule)\n\(operation5)"
      }
    }

    if let operation6 = siteClub.operations6{
      if operation6.characters.count > 0{
        operationSchedule = "\(operationSchedule)\n\(operation6)"
      }
    }

    if let operation7 = siteClub.operations7{
      if operation7.characters.count > 0{
        operationSchedule = "\(operationSchedule)\n\(operation7)"
      }
    }

    if let operation8 = siteClub.operations8{
      if operation8.characters.count > 0{
        operationSchedule = "\(operationSchedule)\n\(operation8)"
      }
    }
    
    return operationSchedule
  }
  
}