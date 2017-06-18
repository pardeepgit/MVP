//
//  ExerciseClassViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 22/08/16.
//

import Foundation
import UIKit
import EventKit


typealias CompletionOfSiteClassesFromLocal = ([ExerciseClass]) -> ()


/*
 * ExerciseClassViewModel class with class method declaration and defination implementaion to handle functionality of ExerciseClass model class.
 */
class ExerciseClassViewModel {
  
  /*
   * Method to create array list of string type object for the tableview section based on type of SiteClassesTypeEnum object.
   */
  // MARK:  createArrayUniqueSectionStringOfScheduleTypeFromListOf method.
  class func createArrayUniqueSectionStringOfScheduleTypeFromListOf(exerciseClassArray: [ExerciseClass], By classType: SiteClassesTypeEnum) -> [String]{
    var arrayOfUniqueSectionString = [String]()
    
    for classObject in exerciseClassArray {
      var sectionUniqueObjectString = ""
      
      switch classType {
      case SiteClassesTypeEnum.ByDate:
        let classStartTime = classObject.classStartTime! as String
        let classDateArray = classStartTime.componentsSeparatedByString("T")
        sectionUniqueObjectString = classDateArray[0]
        break
        
      case SiteClassesTypeEnum.ByInstructor:
        sectionUniqueObjectString = classObject.classInstructor! as String
        break
      case SiteClassesTypeEnum.ByActivityClass:
        sectionUniqueObjectString = classObject.className! as String
        break
        
      case SiteClassesTypeEnum.MySchedule:
        let classStartTime = classObject.classStartTime! as String
        let classDateArray = classStartTime.componentsSeparatedByString("T")
        sectionUniqueObjectString = classDateArray[0]
        break
      }
      
      if (!arrayOfUniqueSectionString.contains(sectionUniqueObjectString) && sectionUniqueObjectString != ""){
        arrayOfUniqueSectionString.append(sectionUniqueObjectString)
      }
    }
    
    return arrayOfUniqueSectionString
  }
  
  /*
   * Method to create array list of string type object for the tableview section based on type of SiteClassesTypeEnum object.
   * To filter unique objects for section of tableview.
   */
  // MARK:  createArrayUniqueSectionStringOfScheduleTypeFromListOf method.
  class func createUniqueArraySectionStringOfScheduleClassFromListOf(exerciseClassArray: [ExerciseClass], By classType: SiteClassesTypeEnum, with searchString: String) -> [String]{
    var arrayOfUniqueSectionString = [String]()
    
    for classObject in exerciseClassArray {
      var sectionUniqueObjectString = ""
      switch classType {
        
      case SiteClassesTypeEnum.ByDate:
        let classStartTime = classObject.classStartTime! as String
        let classDateArray = classStartTime.componentsSeparatedByString("T")
        if classDateArray.count > 0{
          sectionUniqueObjectString = classDateArray[0]
        }
        break
        
      case SiteClassesTypeEnum.ByInstructor:
        sectionUniqueObjectString = classObject.classInstructor! as String
        break
        
      case SiteClassesTypeEnum.ByActivityClass:
        sectionUniqueObjectString = classObject.className! as String
        break
        
      case SiteClassesTypeEnum.MySchedule:
        let classStartTime = classObject.classStartTime! as String
        let classDateArray = classStartTime.componentsSeparatedByString("T")
        if classDateArray.count > 0{
          sectionUniqueObjectString = classDateArray[0]
        }
        break
      }
      
      if searchString.characters.count == 0{
        if (!arrayOfUniqueSectionString.contains(sectionUniqueObjectString) && sectionUniqueObjectString != ""){
          arrayOfUniqueSectionString.append(sectionUniqueObjectString)
        }
      }
      else{
        let searchStringUpperCased = searchString.uppercaseString
        let sectionUniqueObjectStringUpperCased = sectionUniqueObjectString.uppercaseString
        
        if sectionUniqueObjectStringUpperCased.rangeOfString(searchStringUpperCased) != nil{
          if (!arrayOfUniqueSectionString.contains(sectionUniqueObjectString) && sectionUniqueObjectString != ""){
            arrayOfUniqueSectionString.append(sectionUniqueObjectString)
          }
        }
      }
    }
    
    // Code for sorting array of header section string for Instructor and Site Class type in ascending order.
    if classType == SiteClassesTypeEnum.ByInstructor || classType == SiteClassesTypeEnum.ByActivityClass{
      if arrayOfUniqueSectionString.count > 1{
        let sortedArrayOfUniqueSectionString = arrayOfUniqueSectionString.sort { $0 < $1 }
        arrayOfUniqueSectionString.removeAll()
        arrayOfUniqueSectionString = sortedArrayOfUniqueSectionString
      }
    }
    
    return arrayOfUniqueSectionString
  }
  
  /*
   * Method to create array list of type dstring based on type of SiteClassesTypeEnum object.
   * To filter unique objects for section of tableview.
   */
  // MARK:  createArrayOfExerciseClassForSectionFromListOf method.
  class func createArrayOfExerciseClassForSectionFromListOf(exerciseClassArray: [ExerciseClass],  sectionString: String, classType: SiteClassesTypeEnum) -> [ExerciseClass]{
    var arrayOfExerciseClass = [ExerciseClass]()
    switch classType {
      
    case SiteClassesTypeEnum.ByDate:
      for classObject in exerciseClassArray {
        let classStartTime = classObject.classStartTime! as String
        let classDateArray = classStartTime.componentsSeparatedByString("T")
        var dateString = ""
        if classDateArray.count > 0{
          dateString = classDateArray[0]
        }
        
        if sectionString == dateString{
          arrayOfExerciseClass.append(classObject)
        }
      }
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      for classObject in exerciseClassArray {
        let classInstructor = classObject.classInstructor! as String
        if sectionString == classInstructor{
          arrayOfExerciseClass.append(classObject)
        }
      }
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      for classObject in exerciseClassArray {
        let className = classObject.className! as String
        if sectionString == className{
          arrayOfExerciseClass.append(classObject)
        }
      }
      break
      
    case SiteClassesTypeEnum.MySchedule:
      for classObject in exerciseClassArray {
        let classStartTime = classObject.classStartTime! as String
        let classDateArray = classStartTime.componentsSeparatedByString("T")
        var dateString = ""
        if classDateArray.count > 0{
          dateString = classDateArray[0]
        }
        
        if sectionString == dateString{
          arrayOfExerciseClass.append(classObject)
        }
      }
      break
    }
    
    return arrayOfExerciseClass
  }
  
  
  
  
  
  
  
  
  /*
   * parseSiteClassesDescriptionJsonResponseDataBy method to parse Site Calss Description api response NSData to get class description.
   */
  // MARK:  parseSiteClassesDescriptionJsonResponseDataBy method.
  class func parseSiteClassesDescriptionJsonResponseDataBy(responseData: NSData, forClass name: String) -> String {
    var siteClassDescription = ""
    var siteClassesDescriptionResponse = [String: AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try siteClassesDescriptionResponse = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    if siteClassesDescriptionResponse.count > 0{
      if let siteClassesDescriptionArray = siteClassesDescriptionResponse[RESPONSE] as? [[String: AnyObject]]{
        
        for index in 0..<siteClassesDescriptionArray.count {
          let siteClass = siteClassesDescriptionArray[index] as [String: AnyObject]
          if let classNameToCompare = siteClass["className"] as? String{
            if classNameToCompare == name{
              if let classDesc = siteClass["classDescription"] as? String{
                siteClassDescription = classDesc
                break
              }
            }
          }
        }
      }
    }
    
    return siteClassDescription
  }
  
  /*
   * parseSiteClassesJsonResponseDataBy method parse the response json string into JSON object of array of dictionary.
   * We iterate over the JSON object model to parse the response into ExerciseClass model by calling method createExerciseClassObjectForResponseValue.
   */
  // MARK:  parseSiteClassesJsonResponseDataBy method.
  class func parseSiteClassesJsonResponseDataBy(responseData: NSData) -> [ExerciseClass] {
    var arrayOfExerciseClassObject = [ExerciseClass]()
    
    var siteClassesResponse = [String: AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try siteClassesResponse = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var siteClassesObjectArray = [[String: AnyObject]]()
    
    if siteClassesResponse.count > 0{
      if let siteClassesArray = siteClassesResponse[RESPONSE] as? [[String: AnyObject]]{
        siteClassesObjectArray = siteClassesArray
      }
    }
    
    if siteClassesObjectArray.count > 0 {
      // Code iterate over to json object array to parse json object into ExerciseClass model class.
      for index in 0 ..< siteClassesObjectArray.count {
        let exerciseClassObjectData = siteClassesObjectArray[index]
        let exerciseClass = ExerciseClassViewModel.createExerciseClassObjectForResponseValue(exerciseClassObjectData)
        
        arrayOfExerciseClassObject.append(exerciseClass)
      }
    }
    
    return arrayOfExerciseClassObject
  }
  
  /*
   * parseFavouriteSiteClassApiResponseDataForSiteClassBy method parse the response json data of FavouriteSiteClasses.
   * To prepare Site Classes object for user favorite class or not.
   */
  // MARK:  parseFavouriteSiteClassApiResponseDataForSiteClassBy method.
  class func parseFavouriteSiteClassApiResponseDataForSiteClassBy(responseData: NSData, with siteClassesArray: [ExerciseClass]) -> [ExerciseClass]{
    var arrayOfExerciseClassObject = [ExerciseClass]()
    arrayOfExerciseClassObject = siteClassesArray
    
    var favouriteSiteClassesResponse = [String: AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try favouriteSiteClassesResponse = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var favouriteSiteClassesObjectArray  = [[String: AnyObject]]()
    
    if favouriteSiteClassesResponse.count > 0{
      if let favouriteResponseArray = favouriteSiteClassesResponse[RESPONSE] as? [[String: AnyObject]]{
        favouriteSiteClassesObjectArray = favouriteResponseArray
      }
    }
    
    if favouriteSiteClassesObjectArray.count > 0{
      // Code iterate over to json object array to parse json object into ExerciseClass model class.
      for index in 0 ..< arrayOfExerciseClassObject.count {
        let exerciseClass = arrayOfExerciseClassObject[index]
        
        for index in 0 ..< favouriteSiteClassesObjectArray.count {
          let favouriteSiteClassObjectData = favouriteSiteClassesObjectArray[index]
          
          if let classid = favouriteSiteClassObjectData["classid"] as? String {
            if classid == exerciseClass.classid{
              exerciseClass.userFavourite = true
              break
            }
          }
        }
      }
    }
    
    return arrayOfExerciseClassObject
  }
  
  /*
   * parseCheckInSiteClassesJsonResponse method parse the response json string into JSON object of array of dictionary.
   * We iterate over the JSON object model to parse the response into ExerciseClass model by calling method parseCheckInSiteClassesJsonResponse.
   */
  // MARK:  parseCheckInSiteClassesJsonResponse method.
  class func parseCheckInSiteClassesJsonResponse(checkInSiteClassesResponseJsonData: NSData, with checkedInSiteClassesResponseJsonData: NSData) -> [ExerciseClass] {
    
    var arrayOfExerciseClassObject = [ExerciseClass]()
    var checkInSiteClassesResponse = [String: AnyObject]()
    
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try checkInSiteClassesResponse = (NSJSONSerialization.JSONObjectWithData(checkInSiteClassesResponseJsonData, options: []) as? [String: AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var checkInSiteClassesObjectArray = [[String: AnyObject]]()
    
    if checkInSiteClassesResponse.count > 0{
      if let checkInSiteClassesArray = checkInSiteClassesResponse[RESPONSE] as? [[String: AnyObject]]{
        checkInSiteClassesObjectArray = checkInSiteClassesArray
      }
    }
    
    var checkedInSiteClassesResponse = [String: AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try checkedInSiteClassesResponse = (NSJSONSerialization.JSONObjectWithData(checkedInSiteClassesResponseJsonData, options: []) as? [String: AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var checkedInSiteClassesObjectArray  = [[String: AnyObject]]()
    
    if checkedInSiteClassesResponse.count > 0{
      if let checkedInSiteClassesArray = checkedInSiteClassesResponse[RESPONSE] as? [[String: AnyObject]]{
        checkedInSiteClassesObjectArray = checkedInSiteClassesArray
      }      
    }
    
    if checkInSiteClassesObjectArray.count > 0 {
      // Code iterate over to json object array to parse json object into ExerciseClass model class.
      for index in 0 ..< checkInSiteClassesObjectArray.count {
        let exerciseClassObjectData = checkInSiteClassesObjectArray[index]
        let exerciseClass = ExerciseClassViewModel.createExerciseClassObjectForResponseValue(exerciseClassObjectData)
        exerciseClass.userCheckIn = false
        
        for index in 0 ..< checkedInSiteClassesObjectArray.count {
          let checkedInSiteClassObjectData = checkedInSiteClassesObjectArray[index]
          
          if let classid = checkedInSiteClassObjectData["classid"] as? String {
            if classid == exerciseClass.classid{
              exerciseClass.userCheckIn = true
              
              if let checkinid = checkedInSiteClassObjectData["checkinid"] as? Int {
                exerciseClass.checkedId = "\(checkinid)"
              }
              break
            }
          }
        }
        
        arrayOfExerciseClassObject.append(exerciseClass)
      }
    }
    
    return arrayOfExerciseClassObject
  }
  
  
  
  
  
  
  
  /*
   * createExerciseClassObjectForResponseValue method parse the response json dictionary into ExerciseClass model class field.
   * First we compare the response field value with the null or contains value else set a default value.
   */
  // MARK:  createExerciseClassObjectForResponseValue method.
  class func createExerciseClassObjectForResponseValue(exerciseClassResponseValue: [String: AnyObject]) -> ExerciseClass {
    // Code to get value from json object to populate into ExerciseClass model class object.
    let exerciseClassObject = ExerciseClass()
    
    // Code to validate value existence for classid key field else set a defalut value to the field.
    if let classid = exerciseClassResponseValue["classid"] as? String {
      exerciseClassObject.classid = classid
    }
    else {
      exerciseClassObject.classid = ""
    }
    
    // Code to validate value existence for siteid key field else set a defalut value to the field.
    if let siteid = exerciseClassResponseValue["siteid"] as? String {
      exerciseClassObject.siteid = siteid
    }
    else {
      exerciseClassObject.siteid = ""
    }
    
    // Code to validate value existence for className key field else set a defalut value to the field.
    if let className = exerciseClassResponseValue["className"] as? String {
      exerciseClassObject.className = className
    }
    else {
      exerciseClassObject.className = ""
    }
    
    // Code to validate value existence for classStartTime key field else set a defalut value to the field.
    if let classStartTime = exerciseClassResponseValue["classStartTime"] as? String {
      exerciseClassObject.classStartTime = classStartTime
    }
    else {
      exerciseClassObject.classStartTime = ""
    }
    
    // Code to validate value existence for classEndTime key field else set a defalut value to the field.
    if let classEndTime = exerciseClassResponseValue["classEndTime"] as? String {
      exerciseClassObject.classEndTime = classEndTime
    }
    else {
      exerciseClassObject.classEndTime = ""
    }
    
    // Code to validate value existence for classLocation key field else set a defalut value to the field.
    if let classLocation = exerciseClassResponseValue["classLocation"] as? String {
      exerciseClassObject.classLocation = classLocation
    }
    else {
      exerciseClassObject.classLocation = ""
    }
    
    // Code to validate value existence for classInstructor key field else set a defalut value to the field.
    if let classInstructor = exerciseClassResponseValue["classInstructor"] as? String {
      exerciseClassObject.classInstructor = classInstructor
    }
    else {
      exerciseClassObject.classInstructor = ""
    }
    
    // Code to validate value existence for instructorid key field else set a defalut value to the field.
    if let instructorid = exerciseClassResponseValue["instructorid"] as? Int {
      exerciseClassObject.classInstructorId = "\(instructorid)"
    }
    else {
      exerciseClassObject.classInstructorId = ""
    }
    
    // Code to validate value existence for instructorid key field else set a defalut value to the classInstructorImage field.
    if let instructorid = exerciseClassResponseValue["instructorid"] as? Int {
      let instructorImagePath = "\(instructorProfileThumbnailImageURL)\(instructorid)\(instructorProfileThumbnailImageSize)"
      exerciseClassObject.classInstructorImage = instructorImagePath
    }
    else {
      exerciseClassObject.classInstructorImage = ""
    }
    
    return exerciseClassObject
  }
  
  
  
  /*
   * fetchSiteClassesFromLocalCacheByType method to fetch SiteClass from local cache sqlite database.
   */
  // MARK:  fetchSiteClassesFromLocalCacheByType method.
  class func fetchSiteClassesFromLocalCacheByType(type: SiteClassesTypeEnum, completion: CompletionOfSiteClassesFromLocal){
    var arrayFromLocalCacheSiteClass = [ExerciseClass]()
    var queryString = ""
    
    switch type {
    case SiteClassesTypeEnum.ByDate:
      queryString = loadFromSiteClassByDateQuery
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      queryString = loadFromSiteClassByInstructorQuery
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      queryString = loadFromSiteClassByClassesQuery
      break
      
    case SiteClassesTypeEnum.MySchedule:
      queryString = loadFromSiteClassByUserFavouriteQuery
      break
    }
    
    if let resultSet = DBManager.sharedInstance.executeLoadQueryBy(queryString){
      while resultSet.next() {
        let exerciseClass = ExerciseClass()
        exerciseClass.classid = resultSet.stringForColumn("classid")
        exerciseClass.siteid = resultSet.stringForColumn("siteid")
        exerciseClass.className = resultSet.stringForColumn("className")
        exerciseClass.classDescription = resultSet.stringForColumn("classDescription")
        exerciseClass.classStartTime = resultSet.stringForColumn("classStartTime")
        exerciseClass.classEndTime = resultSet.stringForColumn("classEndTime")
        exerciseClass.classLocation = resultSet.stringForColumn("classLocation")
        exerciseClass.classInstructor = resultSet.stringForColumn("classInstructor")
        exerciseClass.classInstructorId = resultSet.stringForColumn("classInstructorId")
        exerciseClass.classInstructorImage = resultSet.stringForColumn("classInstructorImage")
        exerciseClass.checkedId = resultSet.stringForColumn("checkedId")
        exerciseClass.userFavourite = NSString(string: resultSet.stringForColumn("userFavourite")).boolValue
        exerciseClass.userCheckIn = NSString(string: resultSet.stringForColumn("userCheckIn")).boolValue
        exerciseClass.classInstructorAvailable = NSString(string: resultSet.stringForColumn("classInstructorAvailable")).boolValue
        
        arrayFromLocalCacheSiteClass.append(exerciseClass)
      }
    }

    // Code to call completion block for the Site Class from local cache.
    completion(arrayFromLocalCacheSiteClass)
  }
  
  
  
  
  
  
  /*
   * checkClassEventScheduleFromEventKit method validate value for classEventKey from NSUserDefaults of EventKit schedule.
   * Method will return boolean value true or false. Return true when value exist for classEventKey otherwise return false.
   */
  // MARK:  checkClassEventScheduleFromEventKit method.
  class func checkClassEventScheduleFromEventKit(exerciseClass: ExerciseClass) -> Bool{
    let classEventKey = String(format: "Event%@", exerciseClass.classid! as String)
    if let classEventIdentifier = NSUserDefaults.standardUserDefaults().valueForKey(classEventKey) as? String{
      if classEventIdentifier.characters.count > 0{
        var flag = true
        
        let calendarStore = EKEventStore()
        let event: EKEvent?
        event = calendarStore.eventWithIdentifier(classEventIdentifier)
        
        if event == nil {
          flag = false
          
          NSUserDefaults.standardUserDefaults().setValue("", forKey: classEventKey)
          NSUserDefaults.standardUserDefaults().synchronize()
        }
        return flag
      }
      else{
        return false
      }
    }
    else{
      return false
    }
  }
  
  
  /*
   * prepareMarkFavouriteSiteClassApiRequestParamBy method prepare request param for api to mark favourite Site Class.
   */
  // MARK:  prepareMarkFavouriteSiteClassApiRequestParamBy method.
  class func prepareMarkFavouriteOrUnFavouriteSiteClassApiRequestParamBy(exerciseClassObject: ExerciseClass, and favouriteFlag: Bool) -> [String: AnyObject]{
    var inputField = [String: AnyObject]()
    
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    inputField["memid"] = memberId
    
    if favouriteFlag == false{ // For Favourite.
      var siteClassDict = [String: String]()
      siteClassDict["classid"] = exerciseClassObject.classid! as String
      siteClassDict["className"] = exerciseClassObject.className! as String
      siteClassDict["classStartTime"] = exerciseClassObject.classStartTime! as String
      siteClassDict["classLocation"] = exerciseClassObject.classLocation! as String
      siteClassDict["classInstructor"] = exerciseClassObject.classInstructor! as String
      siteClassDict["siteid"] = exerciseClassObject.siteid! as String
      
      var siteClassArray = [[String: String]]()
      siteClassArray.append(siteClassDict)
      inputField["Classes"] = siteClassArray
    }
    else{ // For UnFavourite.
      inputField["classid"] = exerciseClassObject.classid! as String
    }
    
    return inputField
  }

  
}
