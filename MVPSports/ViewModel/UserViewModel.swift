//
//  UserViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 18/08/16.
//

import Foundation


/*
 * UserViewModel class with class method declaration and defination implementaion to handle functionality of User model class.
 *
 */
class UserViewModel {
  
  // MARK:  parseClientTokenFormJsonResponse method.
  class func parseClientTokenFormJsonResponse(clientTokenResponseData: NSData) -> String {
    var clientToken = ""
    var clientTokenResponseDict = [String:AnyObject]()
    
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try clientTokenResponseDict = (NSJSONSerialization.JSONObjectWithData(clientTokenResponseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var clientTokenJsonStringArray = [AnyObject]()
    if let arrayClientTokenJsonString = clientTokenResponseDict[RESPONSE] as? [AnyObject] {
      clientTokenJsonStringArray = arrayClientTokenJsonString
    }
    
    if clientTokenJsonStringArray.count > 0{
      let clientTokenString = clientTokenJsonStringArray[0] as! String
      let clientTokenRange = clientTokenString.rangeOfString("clienttoken:",
                                                             options: NSStringCompareOptions.LiteralSearch,
                                                             range: clientTokenString.startIndex..<clientTokenString.endIndex,
                                                             locale: nil)
      clientToken = clientTokenString [clientTokenRange!.endIndex..<clientTokenString.endIndex]
    }
    
    return clientToken
  }

  
  
  
  /*
   * parseLoggedUserJsonResponseDataToSaveInLocalDefault method to parse loggedUserData into [String:AnyObject] to get user information.
   * Save loggedUserData parse info into the NSUserDault of of User model class object.
   */
  class func parseLoggedUserJsonResponseDataToSaveInLocalDefault(loggedUserData: NSData, with userParam: [String: String]) {
    var userInfoDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try userInfoDict = (NSJSONSerialization.JSONObjectWithData(loggedUserData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
      userInfoDict = [String:AnyObject]()
    }
    
    if userInfoDict.count > 0{
      if let userResponseValueArray = userInfoDict[RESPONSE] as? [[String: AnyObject]] {
        if userResponseValueArray.count > 0{
          let userResponseValue = userResponseValueArray[0]
          
          var userDict = UserViewModel.createUserDictionaryResponseValue(userResponseValue) as [String: String]
          userDict["username"] = userParam["username"]
          userDict["LogInPwd"] = userParam["LogInPwd"]
          UserViewModel.saveUserDictInUserDefault(userDict)
        }
      }
    }
  }

  
  
  
  /*
   * parseSendPasswordLinkedMemberJsonResponseData method parse the response json NSData into linked member dictionary.
   *
   */
  // MARK:  parseSendPasswordLinkedMemberJsonResponseData method.
  class func parseSendPasswordLinkedMemberJsonResponseData(linkedMemberJsonData: NSData) -> [[String:AnyObject]] {
    var linkedMemberArray = [[String : AnyObject]]()

    var linkedMemberResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try linkedMemberResponseDict = (NSJSONSerialization.JSONObjectWithData(linkedMemberJsonData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    if linkedMemberResponseDict.count > 0{
      if let arrayOfLinkedMemberJsonObject = linkedMemberResponseDict[RESPONSE] as? [[String : AnyObject]]{
        linkedMemberArray = arrayOfLinkedMemberJsonObject
      }
    }
    
    return linkedMemberArray;
  }
  
  
  /*
   * Method to validate logged user MemberShip and Default site Club location are same or not.
   */
  // MARK:  validateForLoggecdUserMembershipAndDefaultSiteAreSame method.
  class func validateForLoggecdUserMembershipAndDefaultSiteAreSame() -> Bool {
    var validationFlag = true
    var memberShipSiteId = ""
    var defaultSiteId = ""
    
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    if let siteid = loggedUserDict["Siteid"]{
      memberShipSiteId = siteid
    }
    if let defaultsite = loggedUserDict["defaultsite"]{
      defaultSiteId = defaultsite
    }

    if memberShipSiteId == defaultSiteId{ // When membership and default Site Club both are same.
      validationFlag = true
    }
    else{ // When membership and default Site Club both are different.
      validationFlag = false
    }
    
    return validationFlag
  }
  
  
  /*
   * Method to update default Site Club name and id from mebership Site Club.
   */
  // MARK:  updateDefaultSiteClubIdAndNameFrom method.
  class func updateDefaultSiteClubIdAndNameFrom(siteClubArray: [SiteClub]) {
    var defaultSiteName = ""
    var defaultSiteId = ""
    
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    if let defaultsite = loggedUserDict["defaultsite"]{
      defaultSiteId = defaultsite
    }
    
    if defaultSiteId.characters.count > 0{
      for index in 0..<siteClubArray.count{
        let siteClub = siteClubArray[index]
        if let siteId = siteClub.clubid{
          if siteId == defaultSiteId{
            if let siteName = siteClub.clubName{
              defaultSiteName = siteName
              break
            }
          }
        }
      }
     
      // Code to update SiteId and SiteName for default.
      if defaultSiteName.characters.count > 0{
        UserViewModel.updateSiteIdAndNameBy(defaultSiteId, siteName: defaultSiteName)
      }
      
    }
  }
  
  class func updateSiteIdAndNameBy(siteId: String, siteName: String) {
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    loggedUserDict["Siteid"] = siteId
    loggedUserDict["siteName"] = siteName

    // Code to update local userDefault for logged user information with changed default siteId and SiteName.
    UserViewModel.saveUserDictInUserDefault(loggedUserDict)
  }
  
  
  /*
   * createUserDictionaryResponseValue method parse the json response dictionary into User dictionary [String: String].
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createUserDictionaryResponseValue method.
  class func createUserDictionaryResponseValue(userResponseValue: [String: AnyObject]) -> [String: String] {
    // Code to get value from json object to populate into dictionary value.
    var userDict = [String: String]()
    
    // Code to validate value existence for MemberId key field else set a defalut value to the field.
    if let memberId = userResponseValue["MemberId"] as? Int {
      userDict["memberId"] = "\(memberId)"
    }
    else {
      userDict["memberId"] = ""
    }

    // Code to validate value existence for Siteid key field else set a defalut value to the field.
    if let memberId = userResponseValue["Siteid"] as? Int {
      userDict["Siteid"] = "\(memberId)"
    }
    else {
      userDict["Siteid"] = ""
    }

    // Code to validate value existence for defaultsite key field else set a defalut value to the field.
    if let defaultsite = userResponseValue["defaultsite"] as? Int {
      userDict["defaultsite"] = "\(defaultsite)"
    }
    else {
      userDict["defaultsite"] = ""
    }
    
    // Code to validate value existence for FirstName key field else set a defalut value to the field.
    if let firstName = userResponseValue["FirstName"] as? String {
      userDict["firstName"] = firstName
    }
    else {
      userDict["firstName"] = ""
    }
    
    // Code to validate value existence for Email key field else set a defalut value to the field.
    if let email = userResponseValue["Email"] as? String {
      userDict["email"] = email
    }
    else {
      userDict["email"] = ""
    }
    
    // Code to validate value existence for token key field else set a defalut value to the field.
    if let token = userResponseValue["token"] as? String {
      userDict["token"] = token
      // Code to save logged user token as client token for the first time.
      UserViewModel.setClientToken(token)
    }
    else {
      userDict["token"] = ""
      // Code to save logged user default token as client token for the first time.
      UserViewModel.setClientToken("")
    }
    
    // Code to validate value existence for MemberNumber key field else set a defalut value to the field.
    if let memberNumber = userResponseValue["MemberNumber"] as? String {
      userDict["memberNumber"] = memberNumber
    }
    else {
      userDict["memberNumber"] = ""
    }
    
    // Code to validate value existence for MemberShipDesc key field else set a defalut value to the field.
    if let memberShipDesc = userResponseValue["MemberShipDesc"] as? String {
      userDict["memberShipDesc"] = memberShipDesc
    }
    else {
      userDict["memberShipDesc"] = ""
    }
    
    // Code to validate value existence for SiteName key field else set a defalut value to the field.
    if let img = userResponseValue["img"] as? String {
      userDict["img"] = img
    }
    else {
      userDict["img"] = ""
    }
    
    // Code to validate value existence for SiteName key field else set a defalut value to the field.
    if let siteName = userResponseValue["SiteName"] as? String {
      userDict["siteName"] = siteName
    }
    else {
      userDict["siteName"] = ""
    }

    
    // Code to validate value existence for JoinDate key field else set a defalut value to the field.
    if let joinDate = userResponseValue["JoinDate"] as? String {
      userDict["joinDate"] = joinDate
    }
    else {
      userDict["joinDate"] = ""
    }
    
    return userDict
  }
  
  
  /*
   * createUserObjectForResponseValue method parse the response json dictionary into User model class field.
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createUserObjectForResponseValue method.
  class func createUserObjectForResponseValue(userResponseValue: [String: AnyObject]) -> User {
    
    // Code to get value from json object to populate into User model class object.
    let userObject = User()
    
    // Code to validate value existence for MemberId key field else set a defalut value to the field.
    if let memberId = userResponseValue["MemberId"] as? String {
      userObject.memberId = memberId
    }
    else {
      userObject.memberId = ""
    }
    
    // Code to validate value existence for FirstName key field else set a defalut value to the field.
    if let firstName = userResponseValue["FirstName"] as? String {
      userObject.firstName = firstName
    }
    else {
      userObject.firstName = ""
    }

    // Code to validate value existence for Email key field else set a defalut value to the field.
    if let email = userResponseValue["Email"] as? String {
      userObject.email = email
    }
    else {
      userObject.email = ""
    }

    // Code to validate value existence for token key field else set a defalut value to the field.
    if let token = userResponseValue["token"] as? String {
      userObject.token = token
    }
    else {
      userObject.token = ""
    }

    // Code to validate value existence for MemberNumber key field else set a defalut value to the field.
    if let memberNumber = userResponseValue["MemberNumber"] as? String {
      userObject.memberNumber = memberNumber
    }
    else {
      userObject.memberNumber = ""
    }

    // Code to validate value existence for SiteName key field else set a defalut value to the field.
    if let siteName = userResponseValue["SiteName"] as? String {
      userObject.siteName = siteName
    }
    else {
      userObject.siteName = ""
    }

    // Code to validate value existence for JoinDate key field else set a defalut value to the field.
    if let joinDate = userResponseValue["JoinDate"] as? String {
      userObject.joinDate = joinDate
    }
    else {
      userObject.joinDate = ""
    }
    
    return userObject
  }
  
  
  /*
   * Code to save User in local NSUserDeafult object of default .plist file.
   * Save User in parameter for key User.
   */
  class func saveUserInUserDefault(user: User){
    let userData = NSKeyedArchiver.archivedDataWithRootObject(user) as NSData
    NSUserDefaults.standardUserDefaults().setValue(userData, forKey: "User")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  
  /*
   * Code to save UserDict information in local NSUserDeafult object of default .plist file.
   * Save User in parameter for key LoggedUser.
   */
  class func saveUserDictInUserDefault(userDict: [String: String]){
    NSUserDefaults.standardUserDefaults().setValue(userDict, forKey: "LoggedUser")
    NSUserDefaults.standardUserDefaults().synchronize()
  }

  
  /*
   * Code to save UnLogged UserDict information in local NSUserDeafult object of default .plist file.
   * Save User in parameter for key LoggedUser.
   */
  class func saveUnLoggedUserDictInUserDefault(userDict: [String: String]){
    NSUserDefaults.standardUserDefaults().setValue(userDict, forKey: "UnLoggedUser")
    NSUserDefaults.standardUserDefaults().synchronize()
  }

  
  /*
   * Code to save request token in local NSUserDeafult object of default .plist file.
   * Save parameter value for key requestToken
   */
  class func setRefreshToken(requestToken: String){
    NSUserDefaults.standardUserDefaults().setValue(requestToken, forKey: "refreshToken")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  
  /*
   * Code to save client token in local NSUserDeafult object of default .plist file.
   * Save parameter value for key clientToken
   */
  class func setClientToken(clientToken: String){
    NSUserDefaults.standardUserDefaults().setValue(clientToken, forKey: "clientToken")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  
  /*
   * Code to save User Status in local NSUserDeafult object of default .plist file.
   * Save boolean parameter value for key userStatus
   */
  class func setUserStatusInApplication(status: Bool){
    NSUserDefaults.standardUserDefaults().setValue(status, forKey: "userStatus")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  /*
   * Code to save Copnnected App Status in local NSUserDeafult object of default .plist file.
   * Save boolean parameter value for key connectedAppStatus
   */
  class func setConnectedAppsStatusInApplication(status: Bool){
    NSUserDefaults.standardUserDefaults().setValue(status, forKey: "connectedAppStatus")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  /*
   * Code to save Copnnected App Credentials in local NSUserDeafult object of default .plist file.
   * Save Key-Value parameter value dictionary for key connectedAppStatus
   */
  class func setConnectedAppCredentialsInApplication(credentials: [String: AnyObject]){
    NSUserDefaults.standardUserDefaults().setValue(credentials, forKey: "connectedAppCredentials")
    NSUserDefaults.standardUserDefaults().synchronize()
  }


  /*
   * Code to save Change Location Status in local NSUserDeafult object of default .plist file.
   * Save boolean parameter value for key ChangeLocationStatus
   */
  class func setChangeLocationStatusInApplication(status: Bool){
    NSUserDefaults.standardUserDefaults().setValue(status, forKey: "ChangeLocationStatus")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  
  /*
   * Code to get UserDict from local NSUserDeafult object of default .plist file.
   * Get User object for key LoggedUser.
   */
  class func getUserDictFromUserDefaut() -> [String: String]{
    if let userDict = NSUserDefaults.standardUserDefaults().valueForKey("LoggedUser") as? [String: String]{
      return userDict
    }
    else{
      return [String: String]()
    }
  }
  
  
  /*
   * Code to get UnLogged UserDict from local NSUserDeafult object of default .plist file.
   * Get User object for key LoggedUser.
   */
  class func getUnLoggedUserDictFromUserDefaut() -> [String: String]{
    if let userDict = NSUserDefaults.standardUserDefaults().valueForKey("UnLoggedUser") as? [String: String]{
      return userDict
    }
    else{
      return [String: String]()
    }
  }

  
  
  /*
   * Code to get User from local NSUserDeafult object of default .plist file.
   * Get User object for key User.
   */
  class func getUserFromUserDefaut() -> User{
    if let userData = NSUserDefaults.standardUserDefaults().valueForKey("User") as? NSData{
      let user = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as! User
      return user
    }
    else{
      return User()
    }
  }
  
  
  /*
   * Code to get request token from local NSUserDeafult object of default .plist file.
   * Get parameter value for key requestToken
   */
  class func getRefreshToken() -> String{
    if let refreshToken = NSUserDefaults.standardUserDefaults().valueForKey("refreshToken") as? String{
      return refreshToken
    }
    else{
      return ""
    }
  }
  
  
  /*
   * Code to get client token from local NSUserDeafult object of default .plist file.
   * Get parameter value for key clientToken
   */
  class func getClientToken() -> String{
    if let clientToken = NSUserDefaults.standardUserDefaults().valueForKey("clientToken") as? String{
      return clientToken
    }
    else{
      return ""
    }
  }
  
  
  /*
   * Code to get user status from local NSUserDeafult object of default .plist file.
   * Get parameter boolean value for key userStatus.
   */
  class func getUserStatus() -> Bool{
    if let userStatus = NSUserDefaults.standardUserDefaults().valueForKey("userStatus") as? Bool{
      return userStatus
    }
    else{
      return false
    }
  }
  
  /*
   * Code to get Connected Apps status from local NSUserDeafult object of default .plist file.
   * Get parameter boolean value for key connectedAppStatus.
   */
  class func getConnectedAppsStatus() -> Bool{
    if let userStatus = NSUserDefaults.standardUserDefaults().valueForKey("connectedAppStatus") as? Bool{
      return userStatus
    }
    else{
      return false
    }
  }

  
  /*
   * Code to get Connected Apps Credentials from local NSUserDeafult object of default .plist file.
   * Get parameter Key-Value pair value dictionary for key connectedAppCredentials.
   */
  class func getConnectedAppCredentials() -> [String: AnyObject]{
    if let appCredentials = NSUserDefaults.standardUserDefaults().valueForKey("connectedAppCredentials") as? [String: AnyObject]{
      return appCredentials
    }
    else{
      return  [String: AnyObject]()
    }
  }

  
  /*
   * Code to get Change Location status from local NSUserDeafult object of default .plist file.
   * Get parameter boolean value for key ChangeLocationStatus.
   */
  class func getChangeLocationStatus() -> Bool{
    if let userStatus = NSUserDefaults.standardUserDefaults().valueForKey("ChangeLocationStatus") as? Bool{
      return userStatus
    }
    else{
      return false
    }
  }
  
}