//
//  ScheduleViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 30/08/16.
//

import Foundation


/*
 * SiteClassesTypeEnum is created to handle the SiteClasses type filtration functionality.
 *
 */
enum SiteClassesTypeEnum {
  case ByDate
  case ByInstructor
  case ByActivityClass
  case MySchedule
}



/*
 * ScheduleViewModel class implements class method declaration and defination to handle functionality of MVPMyMVPScheduleViewController controller  class functionality execution.
 */
class ScheduleViewModel {
  
  
  /*
   * convertFormatOfDateString method to change format of date string from yyyy-MM-dd to another date format MM-dd-yyyy.
   */
  // MARK:  convertFormatOfDateString method.
  class func convertFormatOfDateString(dateString: String) -> String{
    
    if dateString.characters.count > 0 && UtilManager.sharedInstance.dateStringValidationFor(dateString){
      var updatedDateString = ""
      let dateFormatter = NSDateFormatter()
      dateFormatter.timeZone = NSTimeZone.localTimeZone()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let dateObj = dateFormatter.dateFromString(dateString)! as NSDate
      
      let calendar = NSCalendar.currentCalendar()
      let components = calendar.components([.Day , .Month , .Year], fromDate: dateObj)
      let month = components.month
      let day = components.day
      
      let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
      let myComponents = myCalendar.components(.Weekday, fromDate: dateObj)
      let weekDay = myComponents.weekday
      
      updatedDateString = "\(UtilManager.sharedInstance.getDayNameFromDayValue(weekDay)), \(UtilManager.sharedInstance.getMonthNameFromMonthValue(month)) \(day)"
      
      return updatedDateString
    }
    else{
      return dateString
    }
  }
  

  
  /*
   * getTimeStringFromDateString method to change format of date string from yyyy-MM-dd to another date format MM-dd-yyyy.
   */
  // MARK:  getTimeStringFromDateString method.
  class func getTimeStringFromDateString(dateString: String) -> String{
    var timeString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(dateString)

    dateFormatter.dateFormat = WORKOUTTIMEFORMATTER
    dateFormatter.AMSymbol  = "am"
    dateFormatter.PMSymbol = "pm"
    timeString = dateFormatter.stringFromDate(dateObj!) as String

    let firstChar = timeString[timeString.startIndex]
    let zeroCharacter: Character = "0"
    if firstChar == zeroCharacter{
      timeString.removeAtIndex(timeString.startIndex)
    }
    
    return timeString
  }
  
  /*
   * getSiteClassFormattedDateString method to get Site Class formatted date string.
   */
  // MARK:  getSiteClassFormattedDateString method.
  class func getSiteClassFormattedDateString(dateString: String) -> String{
    var updatedDateString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(dateString)
    
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: dateObj!)
    let month = components.month
    let day = components.day
    
    let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let myComponents = myCalendar.components(.Weekday, fromDate: dateObj!)
    let weekDay = myComponents.weekday
    
    var weekDayString = UtilManager.sharedInstance.getDayNameFromDayValue(weekDay)
    let range = weekDayString.startIndex ..< weekDayString.startIndex.advancedBy(3)
    weekDayString = weekDayString.substringWithRange(range)

    updatedDateString = "\(weekDayString), \(month)/\(day)"
    
    return updatedDateString
  }
  
  
  
  /*
   * getSiteClassFormattedDateString method to get Site Class formatted date string.
   */
  // MARK:  getSiteClassFormattedDateString method.
  class func getSiteClassFormattedStartDateFrom(dateString: String) -> String{
    var updatedDateString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(dateString)
        
    let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let myComponents = myCalendar.components(.Weekday, fromDate: dateObj!)
    let weekDay = myComponents.weekday
    
    var weekDayString = UtilManager.sharedInstance.getDayNameFromDayValue(weekDay)
    let range = weekDayString.startIndex ..< weekDayString.startIndex.advancedBy(3)
    weekDayString = weekDayString.substringWithRange(range)

    dateFormatter.dateFormat = DISPLAYWORKOUTDATEFORMATTER
    let siteClassStartDate = dateFormatter.stringFromDate(dateObj!) as String

    updatedDateString =  "\(weekDayString), \(siteClassStartDate)"
    return updatedDateString
  }

  
  
  
  /*
   * getSiteClassStartTimeDate method to create date object from site class tart time string value.
   */
  // MARK:  getSiteClassStartTimeDate method.
  class func getSiteClassStartTimeDate(dateString: String) -> NSDate{
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    
    let dateObj = dateFormatter.dateFromString(dateString)! as NSDate
    return dateObj
  }


  
  // MARK:  validateSiteClubCordinates method.
  class func validateSiteClubCordinates(lat: String, and lang: String) -> Bool{
    var checkFlag = true
    if lat.characters.count == 0{
      checkFlag = false
    }
    if lang.characters.count == 0{
      checkFlag = false
    }
    
    return checkFlag
  }
  
}