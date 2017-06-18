//
//  WorkoutViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 12/09/16.
//

import Foundation


/*
 * UserActivityTypeEnumeration is an enumeration of default type.
 * Enumeration infer the type of logged user activity type either its Workout or Journal.
 */
enum UserActivityTypeEnumeration {
  case Workout
  case Journal
}



/*
 * WorkoutFilterOptionTypeEnumeration is an enumeration of default type.
 * Enumeration infer the type of workout filter option user choosed.
 */
enum WorkoutFilterOptionTypeEnumeration {
  case All
  case Annual
  case Monthly
  case Weekly
}



/*
 * PickerTypeEnumeration is an enumeration for the UIPickerView view mode.
 * UIPickerView mode either is MachineType or Duration.
 */
enum PickerTypeEnumeration {
  case MachineType
  case Duration
  case Default
}



/*
 * WorkoutViewModel class implements class method declaration and defination to handle functionality of Workout and Journal functionality execution.
 */
class WorkoutViewModel {
  

  /*
   * copyWorkoutIntoAnotherInstance method copy value from one workout object into another workout object.
   */
  // MARK:  copyWorkoutIntoAnotherInstance method.
  class func copyWorkoutIntoAnotherInstance(sourceWorkout: Workout) -> Workout{
    let workout = Workout()
    workout.workoutid = sourceWorkout.workoutid
    workout.machinetype = sourceWorkout.machinetype
    workout.steps = sourceWorkout.steps
    workout.distance = sourceWorkout.distance
    workout.Name = sourceWorkout.Name
    workout.datecreated = sourceWorkout.datecreated
    workout.duration = sourceWorkout.duration
    workout.calories = sourceWorkout.calories

    return workout
  }
  
  
  
  /*
   * parseWorkoutJsonResponse method parse the response json dictionary into Workout model class field.
   */
  // MARK:  parseWorkoutJsonResponse method.
  class func parseWorkoutJsonResponse(workoutJsonData: NSData) -> [Workout] {
    var workoutResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try workoutResponseDict = (NSJSONSerialization.JSONObjectWithData(workoutJsonData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfWorkoutObject = [Workout]()
    
    if workoutResponseDict.count > 0{
      if let arrayOfWorkoutJsonObject = workoutResponseDict[RESPONSE] as? [[String: AnyObject]]{
        if arrayOfWorkoutJsonObject.count > 0 {
          // Code iterate over to json object array to parse json object into Workout model class.
          for index in 0 ..< arrayOfWorkoutJsonObject.count {
            let workoutObjectData = arrayOfWorkoutJsonObject[index]
            let workout = WorkoutViewModel.createWorkoutObjectForResponseValue(workoutObjectData )
            arrayOfWorkoutObject.append(workout)
          }
        }
      }
    }
    
    return arrayOfWorkoutObject
  }
  

  
  /*
   * filterJournalWorkoutFrom WorkoutArray method to filter journal workout which is not device type.
   */
  // MARK:  filterJournalWorkoutFrom method.
  class func filterJournalWorkoutFrom(workoutArray: [Workout]) -> [Workout] {
    var journalWorkoutArray = [Workout]()
    
    for index in 0..<workoutArray.count{
      let workout = workoutArray[index]
      let workoutType = workout.type! as String
      
      if workoutType != "device"{
        journalWorkoutArray.append(workout)
      }
    }
    
    return journalWorkoutArray
  }
  
  
  
  /*
   * createWorkoutObjectForResponseValue method parse the response json dictionary into Workout model class field.
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createWorkoutObjectForResponseValue method.
  class func createWorkoutObjectForResponseValue(workoutResponseValue: [String: AnyObject]) -> Workout {
    // Code to get value from json object to populate into Workout model class object.
    let workoutObject = Workout()
    
    // Code to validate value existence for workoutid key field else set a defalut value to the field.
    if let workoutid = workoutResponseValue["workoutid"] as? Int {
      workoutObject.workoutid = workoutid
    }
    else {
      workoutObject.workoutid = 0
    }
    
    // Code to validate value existence for machinetype key field else set a defalut value to the field.
    if let machinetype = workoutResponseValue["machinetype"] as? Int {
      workoutObject.machinetype = machinetype
    }
    else {
      workoutObject.machinetype = 0
    }

    // Code to validate value existence for steps key field else set a defalut value to the field.
    if let steps = workoutResponseValue["steps"] as? Int {
      workoutObject.steps = steps
    }
    else {
      workoutObject.steps = 0
    }

    // Code to validate value existence for distance key field else set a defalut value to the field.
    if let distance = workoutResponseValue["distance"] as? Float {
      workoutObject.distance = distance
    }
    else {
      workoutObject.distance = 0.0
    }

    // Code to validate value existence for type key field else set a defalut value to the field.
    if let type = workoutResponseValue["type"] as? String {
      workoutObject.type = type
    }
    else {
      workoutObject.type = ""
    }

    // Code to validate value existence for note key field else set a defalut value to the field.
    if let note = workoutResponseValue["note"] as? String {
      workoutObject.note = note
    }
    else {
      workoutObject.note = ""
    }
    
    // Code to validate value existence for Name key field else set a defalut value to the field.
    if let Name = workoutResponseValue["Name"] as? String {
      workoutObject.Name = Name
    }
    else {
      workoutObject.Name = ""
    }

    // Code to validate value existence for instructorName key field else set a defalut value to the field.
    if let instructorName = workoutResponseValue["instructorName"] as? String {
      workoutObject.instructorName = instructorName
    }
    else {
      workoutObject.instructorName = ""
    }

    // Code to validate value existence for datecreated key field else set a defalut value to the field.
    if let datecreated = workoutResponseValue["datecreated"] as? String {
      workoutObject.datecreated = datecreated
    }
    else {
      workoutObject.datecreated = ""
    }

    // Code to validate value existence for duration key field else set a defalut value to the field.
    if let duration = workoutResponseValue["duration"] as? Int {
      workoutObject.duration = duration
    }
    else {
      workoutObject.duration = 0
    }
    
    // Code to validate value existence for calories key field else set a defalut value to the field.
    if let calories = workoutResponseValue["calories"] as? Int {
      workoutObject.calories = calories
    }
    else {
      workoutObject.calories = 0
    }

    return workoutObject
  }
  
  
  
  
  /*
   * getDurationBetweenCreatedWorkoutTimeFromCurrentTime method to return time duration between workout created time and current time.
   */
  // MARK:  getDurationBetweenCreatedWorkoutTimeFromCurrentTime method.
  class func getDurationBetweenCreatedWorkoutTimeFromCurrentTime(dateString: String) -> String{
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    
    let date = dateFormatter.dateFromString(dateString)! as NSDate
    return NSDate().offsetFrom(date)
  }
  
  
  /*
   * getHoursMinutesStringFromDuration method to covert milli second duration into 00h:00m hours and minutes format.
   */
  // MARK:  getHoursMinutesStringFromDuration method.
  class func getHoursMinutesStringFromDuration(duration: Int) -> String{
    var hoursMinutesString = ""
    let seconds = duration / 1000
    let minutes = seconds / 60
    let hours =  minutes / 60
    let remainingMinutes = minutes % 60
  
    hoursMinutesString = "\(hours)h:\(remainingMinutes)m"
    return hoursMinutesString
  }
  
  
  /*
   * getDateStringFromWorkoutCreatedDateString method to change format of date string from yyyy-MM-dd to another date format dd/MM/yyyy.
   */
  // MARK:  getDateStringFromWorkoutCreatedDateString method.
  class func getDateStringFromWorkoutCreatedDateString(createdString: String) -> String{
    var dateString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(createdString)
    
    dateFormatter.dateFormat = DISPLAYWORKOUTDATEFORMATTER
    dateString = dateFormatter.stringFromDate(dateObj!) as String
    return dateString
  }
  
  
  /*
   * getYearStringFromWorkoutCreatedDateString method to get year string in yyyy format.
   */
  // MARK:  getYearStringFromWorkoutCreatedDateString method.
  class func getYearStringFromWorkoutCreatedDateString(createdString: String) -> String{
    var yearString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(createdString)

    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: dateObj!)
    let year = components.year
    
    yearString = "\(year)"
    return yearString
  }

  
  /*
   * getMonthYearStringFromWorkoutCreatedDateString method to get month year string in MMM yyyy format.
   */
  // MARK:  getMonthYearStringFromWorkoutCreatedDateString method.
  class func getMonthYearStringFromWorkoutCreatedDateString(createdString: String) -> String{
    var monthYearString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(createdString)
    
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: dateObj!)
    let month = components.month
    let year = components.year
    
    monthYearString = " \(UtilManager.sharedInstance.getMonthNameFromMonthValue(month)) \(year)"
    return monthYearString
  }


  // MARK:  getDateCreatedStringFromSelectedDateString method.
  class func validateCreateWorkoutDateTimeWithCurrentTimeBy(workoutDateString: String) -> Bool{
    var validateFlag = false
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale.autoupdatingCurrentLocale()
    dateFormatter.dateFormat = SELECTEDWORKOUTDATEFORMATTER
    let workoutDate = dateFormatter.dateFromString(workoutDateString)! as NSDate
    
    let currentDate = NSDate()

    // Date comparision to compare current date and end date.
    let dateComparisionResult:NSComparisonResult = currentDate.compare(workoutDate)
    
    if dateComparisionResult == NSComparisonResult.OrderedAscending{
      // Current date is smaller than workout date.
      validateFlag = false
    }
    else if dateComparisionResult == NSComparisonResult.OrderedDescending{
      // Current date is greater than workout date.
      validateFlag = true
    }
    else if dateComparisionResult == NSComparisonResult.OrderedSame{
      // Current date and workout date are same.
      validateFlag = true
    }
    
    return validateFlag
  }
  
  
  // MARK:  getDateCreatedStringFromSelectedDateString method.
  class func getDateCreatedStringFromSelectedDateString(selectedString: String) -> String{
    var dateString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC")
    dateFormatter.dateFormat = SELECTEDWORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(selectedString)

    dateFormatter.dateFormat = SAVEWORKOUTDATEFORMATTER
    dateFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC")
    dateFormatter.AMSymbol = "am"
    dateFormatter.PMSymbol = "pm"
    
    dateString = dateFormatter.stringFromDate(dateObj!) as String
    return dateString
  }
  
  
  /*
   * getTimeStringFromDateString method to return date string in date format hh:mma.
   */
  // MARK:  getTimeStringFromDateString method.
  class func getTimeStringFromDateString(dateString: String) -> String{
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = WORKOUTDATEFORMATTER
    let dateObj = dateFormatter.dateFromString(dateString)

    let timeString = WorkoutViewModel.getDateStringFromChooseDate(dateObj!, withStringFormat: "hh:mma")
    return timeString
  }
  
  
  /*
   * getDateStringFromChooseDate method to return date string in date format dd/MM/yyyy.
   */
  // MARK:  getDateStringFromChooseDate method.
  class func getDateStringFromChooseDate(date: NSDate, withStringFormat stringFormat: String) -> String{
    var dateString = ""
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = stringFormat
    dateFormatter.AMSymbol = "am"
    dateFormatter.PMSymbol = "pm"
    
    dateString = dateFormatter.stringFromDate(date) as String
    return dateString
  }

  
  /*
   * getDateObjectFromDateString method to return NSDate instance by date string using date format dd/MM/yyyy.
   */
  // MARK:  getDateObjectFromDateString method.
  class func getDateObjectFromDateString(dateString: String, withStringFormat stringFormat: String) -> NSDate{
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = stringFormat 
    let date = dateFormatter.dateFromString(dateString)
    return date!
  }


  /*
   * getValueForMachineType method will return value of MachineType.
   */
  // MARK:  getValueForMachineType method.
  class func getValueForMachineType(machineType: String) -> Int{
    var machineValue = 0
    switch machineType {
      
    case "Cardio":
      machineValue = 1
      
    case "Strength":
      machineValue = 2

    default:
      machineValue = 0
    }
    
    return machineValue
  }
  
  
  /*
   * getMachineTypeForValue method will return MachineType for type value.
   */
  // MARK:  getMachineTypeForValue method.
  class func getMachineTypeForValue(type: Int) -> String{
    var machineType = ""
    switch type {
      
    case 1:
      machineType = "Cardio"
      break
      
    case 2:
      machineType = "Strength"
      break
      
    default:
      machineType = "type"
    }
    
    return machineType
  }

}


/*
 * extension of NSDate to add method inside of Date to add functionality into NSDate class and executes method by NSDate instance.
 */
extension NSDate {
  
  // MARK:  offsetFrom method to calculate and return Date Day, Hour and Minutes.
  func offsetFrom(date:NSDate) -> String {
    let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute]
    let difference = NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: date, toDate: self, options: [])
    
    let minutes = "\(difference.minute)m"
    let hours = "\(difference.hour)h" + " " + minutes
    let days = "\(difference.day)d" + " " + hours
    
    if difference.day    > 0 { return days }
    if difference.hour   > 0 { return hours }
    if difference.minute > 0 { return minutes }

    return ""
  }
  
}