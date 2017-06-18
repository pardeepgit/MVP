//
//  NotificationClubsViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 06/09/16.
//

import Foundation
import UIKit


/*
 * NotificationClubsViewModel class with class method declaration and defination implementaion to handle functionality of NotificationClub model class.
 *
 */
class NotificationClubsViewModel {

  /*
   * parseSiteClubsResponseData method to parse Site Club api response into Notification Clubs.
   */
  // MARK:  parseSiteClubsResponseData method.
  class func parseSiteClubsResponseData(siteClubData: NSData) -> [NotificationClub] {

    var siteClubsResponseDict = [String:AnyObject]()
    do {
      try siteClubsResponseDict = (NSJSONSerialization.JSONObjectWithData(siteClubData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfNotificationClubs = [NotificationClub]()
    var arrayOfSiteClubsJsonObject = [[String: AnyObject]]()
    
    if let arrayOfSiteClubsJson = siteClubsResponseDict[RESPONSE] as? [[String: AnyObject]]{
      arrayOfSiteClubsJsonObject = arrayOfSiteClubsJson
    }

    if arrayOfSiteClubsJsonObject.count > 0 {
      // Code iterate over to json object array to parse json object into Reward model class.
      
      for index in 0 ..< arrayOfSiteClubsJsonObject.count {
        let siteClubObjectData = arrayOfSiteClubsJsonObject[index]
        let notificationClub = NotificationClubsViewModel.createNotificationClubForSiteClubObject(siteClubObjectData)
        
        arrayOfNotificationClubs.append(notificationClub)
      }
    }
    
    return arrayOfNotificationClubs
  }
  
  /*
   * parseNotifySiteClubsResponseData method to parse Notified Site Club api response into Notification Clubs.
   */
  // MARK:  parseNotifySiteClubsResponseData method.
  class func parseNotifySiteClubsResponseData(notifySiteClubData: NSData) -> [NotificationClub] {
    
    var notifySiteClubsResponseDict = [String:AnyObject]()
    do {
      try notifySiteClubsResponseDict = (NSJSONSerialization.JSONObjectWithData(notifySiteClubData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfNotificationClubs = [NotificationClub]()
    var arrayOfNotifySiteClubsJsonObject = [[String: AnyObject]]()
    
    if let arrayOfNotifySiteClubsJson = notifySiteClubsResponseDict[RESPONSE] as? [[String: AnyObject]]{
      arrayOfNotifySiteClubsJsonObject = arrayOfNotifySiteClubsJson
    }
    
    if arrayOfNotifySiteClubsJsonObject.count > 0 {
      // Code iterate over to json object array to parse json object into Reward model class.
      
      for index in 0 ..< arrayOfNotifySiteClubsJsonObject.count {
        
        let notifySiteClubObjectData = arrayOfNotifySiteClubsJsonObject[index]
        let notificationClub = NotificationClubsViewModel.createNotificationClubObjectForResponseValue(notifySiteClubObjectData)
        arrayOfNotificationClubs.append(notificationClub)
      }
    }
    
    return arrayOfNotificationClubs
  }
  
  // MARK:  getCommonNotifySiteClubFrom method.
  class func getCommonNotifySiteClubFrom(siteClubArray: [NotificationClub], with notifySiteClubArray: [NotificationClub]) -> [NotificationClub]{
    
    var arrayOfSiteClubForNotify = [NotificationClub]()
    for index in 0 ..< siteClubArray.count {
      let siteClub: NotificationClub = siteClubArray[index]
      
      for index in 0 ..< notifySiteClubArray.count {
        let notifySiteClub: NotificationClub = notifySiteClubArray[index]
        if siteClub.clubid == notifySiteClub.clubid{
          siteClub.notificationDate = notifySiteClub.notificationDate
          siteClub.isDefaultClub = notifySiteClub.isDefaultClub
          break
        }
      }
      arrayOfSiteClubForNotify.append(siteClub)
    }
    
    
    for index in 0 ..< notifySiteClubArray.count {
      let notifySiteClub: NotificationClub = notifySiteClubArray[index]
      var isClubExist = false
      for index in 0 ..< siteClubArray.count {
        let siteClub: NotificationClub = siteClubArray[index]
        if notifySiteClub.clubid == siteClub.clubid{
          isClubExist = true
          break
        }
      }
      
      if isClubExist == false{
        arrayOfSiteClubForNotify.append(notifySiteClub)
      }
    }
    return arrayOfSiteClubForNotify
  }
  

  
  
  
  /*
   * parseConnectedAppsJsonResponseData method parse the response json dictionary into ConnectedApp model class array.
   */
  // MARK:  parseConnectedAppsJsonResponseData method.
  class func parseConnectedAppsJsonResponseData(connectedAppResponseData: NSData) -> [ConnectedApp] {
    var connectedAppResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try connectedAppResponseDict = (NSJSONSerialization.JSONObjectWithData(connectedAppResponseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfConnectedAppsObject = [ConnectedApp]()
    
    if connectedAppResponseDict.count > 0{
      if let arrayOfConnectedAppJsonObject = connectedAppResponseDict[RESPONSE] as? [[String: AnyObject]]{
        if arrayOfConnectedAppJsonObject.count > 0 {
          
          // Code iterate over to json object array to parse json object into Reward model class.
          for index in 0 ..< arrayOfConnectedAppJsonObject.count {
            let connectedAppObjectData = arrayOfConnectedAppJsonObject[index]
            let connectedApp = NotificationClubsViewModel.createConnectedAppObjectForResponseValue(connectedAppObjectData)
            
            arrayOfConnectedAppsObject.append(connectedApp)
          }
        }
      }
    }
    
    return arrayOfConnectedAppsObject
  }


  
  /*
   * createConnectedAppObjectForResponseValue method parse the response json dictionary into ConnectedApp model class field.
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createConnectedAppObjectForResponseValue method.
  class func createConnectedAppObjectForResponseValue(connectedAppJsonResponseValue: [String: AnyObject]) -> ConnectedApp {
    // Code to get value from json object to populate into ConnectedApp model class object.
    let connectedAppObject = ConnectedApp()
    
    // Code to validate value existence for memid key field else set a defalut value to the field.
    if let memid = connectedAppJsonResponseValue["memid"] as? Int {
      connectedAppObject.memid = memid
    }
    else {
      connectedAppObject.memid = 0
    }
    
    // Code to validate value existence for appName key field else set a defalut value to the field.
    if let appName = connectedAppJsonResponseValue["appName"] as? String {
      connectedAppObject.appName = appName
    }
    else {
      connectedAppObject.appName = ""
    }
    
    // Code to validate value existence for appid key field else set a defalut value to the field.
    if let appid = connectedAppJsonResponseValue["appid"] as? Int {
      connectedAppObject.appid = appid
    }
    else {
      connectedAppObject.appid = 0
    }
    
    // Code to validate value existence for status key field else set a defalut value to the field.
    if let status = connectedAppJsonResponseValue["status"] as? Bool {
      connectedAppObject.status = status
    }
    else {
      connectedAppObject.status = false
    }

    // Code to validate value existence for status key field else set a defalut value to the field.
    if let tokenAuthenticity = connectedAppJsonResponseValue["TokenAuthenticity"] as? Int {
      connectedAppObject.tokenAuthenticity = tokenAuthenticity
    }
    else {
      connectedAppObject.tokenAuthenticity = 0
    }
    
    // Code to validate value existence for userid key field else set a defalut value to the field.
    if let userid = connectedAppJsonResponseValue["userid"] as? String {
      connectedAppObject.userid = userid
    }
    else {
      connectedAppObject.userid = ""
    }

    // Code to validate value existence for MemAccessToken key field else set a defalut value to the field.
    if let MemAccessToken = connectedAppJsonResponseValue["MemAccessToken"] as? String {
      connectedAppObject.memAccessToken = MemAccessToken
    }
    else {
      connectedAppObject.memAccessToken = ""
    }

    // Code to validate value existence for MemRefreshToken key field else set a defalut value to the field.
    if let MemRefreshToken = connectedAppJsonResponseValue["MemRefreshToken"] as? String {
      connectedAppObject.memRefreshToken = MemRefreshToken
    }
    else {
      connectedAppObject.memRefreshToken = ""
    }

    return connectedAppObject
  }
  

  
  
  /*
   * createNotificationClubForSiteClubObject method parse the Site Club info into NotificationClub model class field.
   */
  // MARK:  createNotificationClubObjectForResponseValue method.
  class func createNotificationClubForSiteClubObject(siteClubObject: [String: AnyObject]) -> NotificationClub {
    // Code to get value from json object to populate into NotificationClub model class object.
    let notificationClubObject = NotificationClub()
    
    // Code to validate value existence for clubid key field else set a defalut value to the field.
    if let clubid = siteClubObject["clubid"] as? String {
      notificationClubObject.clubid = clubid
    }
    else {
      notificationClubObject.clubid = ""
    }
    
    // Code to validate value existence for ClubName key field else set a defalut value to the field.
    if let clubName = siteClubObject["ClubName"] as? String {
      notificationClubObject.clubName = clubName
    }
    else {
      notificationClubObject.clubName = ""
    }
    
    return notificationClubObject
  }
  
  
  
  /*
   * createNotificationClubObjectForResponseValue method parse the response json dictionary into NotificationClub model class field.
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createNotificationClubObjectForResponseValue method.
  class func createNotificationClubObjectForResponseValue(notificationClubResponseValue: [String: AnyObject]) -> NotificationClub {
    // Code to get value from json object to populate into NotificationClub model class object.
    let notificationClubObject = NotificationClub()
    
    // Code to validate value existence for memid key field else set a defalut value to the field.
    if let memid = notificationClubResponseValue["memid"] as? String {
      notificationClubObject.memid = memid
    }
    else {
      notificationClubObject.memid = ""
    }
    
    // Code to validate value existence for clubid key field else set a defalut value to the field.
    if let clubid = notificationClubResponseValue["clubid"] as? String {
      notificationClubObject.clubid = clubid
    }
    else {
      notificationClubObject.clubid = ""
    }

    // Code to validate value existence for ClubName key field else set a defalut value to the field.
    if let clubName = notificationClubResponseValue["ClubName"] as? String {
      notificationClubObject.clubName = clubName
    }
    else {
      notificationClubObject.clubName = ""
    }

    // Code to validate value existence for NotificationDate key field else set a defalut value to the field.
    if let notificationDate = notificationClubResponseValue["NotificationDate"] as? String {
      notificationClubObject.notificationDate = notificationDate
    }
    else {
      notificationClubObject.notificationDate = ""
    }

    // Code to validate value existence for NotificationDate key field else set a defalut value to the field.
    if let isDefaultClub = notificationClubResponseValue["IsDefaultClub"] as? Bool {
      notificationClubObject.isDefaultClub = isDefaultClub
    }
    else {
      notificationClubObject.isDefaultClub = false
    }

    return notificationClubObject
  }
  
  
  // MARK:  createInputArrayOfNotificationDictionaryOfNotificationClubArrayObjects method.
  class func createInputArrayOfNotificationDictionaryOfNotificationClubArrayObjects(arrayOfNotificationClubs: [NotificationClub]) ->  [[String: AnyObject]] {
    var arrayOfNotificationClubDictionary = [[String: AnyObject]]()

    // Code iterate over to json object array to parse json object into Reward model class.
    for index in 0 ..< arrayOfNotificationClubs.count {
      
      let notificationClubObject = arrayOfNotificationClubs[index] as NotificationClub
      let notificationClubDictionary = NotificationClubsViewModel.createNotificationClubObjectDictionaryData(notificationClubObject)
      arrayOfNotificationClubDictionary.append(notificationClubDictionary)
    }
    
    return arrayOfNotificationClubDictionary
  }
  
  
  // MARK:  createNotificationClubObjectDictionaryData method.
  class func createNotificationClubObjectDictionaryData(notificationClub: NotificationClub) -> [String: AnyObject]{
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    
    var notificationClubDictionary = [String: AnyObject]()
    notificationClubDictionary["memid"] = memberId
    notificationClubDictionary["clubid"] = notificationClub.clubid
    notificationClubDictionary["ClubName"] = notificationClub.clubName
    notificationClubDictionary["NotificationDate"] = notificationClub.notificationDate
    
    if notificationClub.isDefaultClub == true{
      notificationClubDictionary["IsDefaultClub"] = 1
    }
    else{
      notificationClubDictionary["IsDefaultClub"] = 0
    }

    return notificationClubDictionary
  }
  
}