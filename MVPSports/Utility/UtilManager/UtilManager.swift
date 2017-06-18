//
//  UtilManager.swift
//  MVPSports
//
//  Created by Chetu India on 09/08/16.
//

import UIKit


class UtilManager: NSObject {
  
  
  /*
   * Method to design Singleton design pattern for UtilManager class.
   * Create singleton instance by global and constant variable declaration.
   */
  class var sharedInstance: UtilManager {
    struct Singleton {
      static let instance = UtilManager()
    }
    return Singleton.instance
  }
  

  /*
   * dateStringValidationFor method to validate date string for valid date or not.
   */
  // MARK:  dateStringValidationFor method.
  func dateStringValidationFor(date: String) -> Bool {
    var validationFlag = false
    let dateCharacters = "0123456789-"
    let dateCharacterSet = NSMutableCharacterSet()
    dateCharacterSet.addCharactersInString(dateCharacters)
    
    if !date.isEmpty && date.rangeOfCharacterFromSet(dateCharacterSet) != nil {
      // date string is a valid date
      validationFlag = true
    }
    else {
      // date string contained non-date characters
      validationFlag = false
    }
    return validationFlag
  }
  
  
  /*
   * heightForLabel method to calculate label height for the string by font size and fixed width of label.
   */
  // MARK:  heightForLabel method.
  func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
  }
  
  
  /*
   * widthForLabel method to calculate label width for the string by font size and fixed height of label.
   */
  // MARK:  widthForLabel method.
  func widthForLabel(text:String, font:UIFont, height:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, height))
    label.numberOfLines = 1
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.width
  }

  
  /*
   * validateLoggedUserStatus method to validate user logged into app or not. Based on that return boolean value.
   */
  // MARK:  validateLoggedUserStatus method.
  func validateLoggedUserStatus() -> Bool {
    var flag = false
    // Code to check whether user is logged into application or not.
    if UserViewModel.getClientToken().characters.count == 0{ // When user is logged in
      flag = false
    }
    else{
      flag = true
    }
    return flag
  }
  
  
  /*
   * isValidEmail method to validate parameter email address to return true of false.
   */
  // MARK:  isValidEmail method.
  func isValidEmail(emailStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(emailStr)
  }
  
  
  
  /*
   * Method to compare for dashboard multiple cell option to return boolean value.
   * Method return true if string setisfy for CheckInWorkOut option else return false.
   */
  // MARK:  checkForDashboardMultipleOptionCell method.
  func checkForDashboardMultipleOptionCell(cellString: String) -> Bool {
    var flag = false
    let compareString = "CheckInWorkOut"
    if cellString == compareString {
      flag = true
    }
    return flag
  }
  
  
  
  /*
   * validateApiForSuccessResponse method to validate api response data for the api success.
   * method will return true of false. Is api response get success it will return sucess else it will return false.
   */
  // MARK:  validateApiForSuccessResponse method.
  func validateApiForSuccessResponse(responsedData: NSData) -> Bool {
    var flag = false
    
    var apiResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try apiResponseDict = (NSJSONSerialization.JSONObjectWithData(responsedData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    if let apiResponseStatus =  apiResponseDict[STATUS] as? String{
      if apiResponseStatus.capitalizedString == SUCCESS{
        flag = true
      }
      else{
        flag = false
      }
    }
    
    return flag
  }
  
  
  
  // MARK:  getDayNameFromDayValue method.
  func getDayNameFromDayValue(dayValue: Int) -> String {
    var dayName = ""
    switch dayValue {
    case 1:
      dayName = "Sunday"
      
    case 2:
      dayName = "Monday"
      
    case 3:
      dayName = "Tuesday"
      
    case 4:
      dayName = "Wednesday"
      
    case 5:
      dayName = "Thursday"
      
    case 6:
      dayName = "Friday"
      
    case 7:
      dayName = "Saturday"
      
    default:
      dayName = ""
    }
    
    return dayName
  }
  
  
  // MARK:  getMonthNameFromMonthValue method.
  func getMonthNameFromMonthValue(monthValue: Int) -> String {
    var monthName = ""
    switch monthValue {
    case 1:
      monthName = "January"
      
    case 2:
      monthName = "February"
      
    case 3:
      monthName = "March"
      
    case 4:
      monthName = "April"
      
    case 5:
      monthName = "May"
      
    case 6:
      monthName = "June"
      
    case 7:
      monthName = "July"
      
    case 8:
      monthName = "August"
      
    case 9:
      monthName = "September"
      
    case 10:
      monthName = "October"
      
    case 11:
      monthName = "November"
      
    case 12:
      monthName = "December"
      
    default:
      monthName = ""
    }
    
    return monthName
  }
  
  
  /*
  * Code to parse the response data for failure message.
  */
  // MARK:  parseFailureMessageFromApiResponseData method.
  func parseFailureMessageFromApiResponseData(responseData: NSData) -> String {
    var failureMessage = ""
    var failureResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try failureResponseDict = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }

    if failureResponseDict.count > 0{
      if let message = failureResponseDict["Message"] as? String {
        failureMessage = message
      }
    }
    return failureMessage
  }

  
  // MARK:  setDefaultApiFlagForLocalCacheFunctionality method.
  func setDefaultApiFlagForLocalCacheFunctionality() {
    // Code to update SiteClass api status on Dashboard screen.
    DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.SiteClass, andStatus: true)

    // Code to update OptIn api status on Dashboard screen.
    DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.OptIn, andStatus: true)

    // Code to set Api execution status for the Site Class types.
    ScheduleSiteClassViewModel.setMvpScheduleApiStatusFor(SiteClassesTypeEnum.ByDate, andStatus: true)
    ScheduleSiteClassViewModel.setMvpScheduleApiStatusFor(SiteClassesTypeEnum.ByInstructor, andStatus: true)
    ScheduleSiteClassViewModel.setMvpScheduleApiStatusFor(SiteClassesTypeEnum.ByActivityClass, andStatus: true)
    ScheduleSiteClassViewModel.setMvpScheduleApiStatusFor(SiteClassesTypeEnum.MySchedule, andStatus: true)

  }
  
}
