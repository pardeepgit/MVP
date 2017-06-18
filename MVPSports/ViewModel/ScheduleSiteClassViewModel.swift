//
//  ScheduleSiteClassViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 04/01/17.
//

import Foundation

typealias CompletionOfDeleteSiteClassFromLocal = (Bool) -> ()


/*
 * ScheduleSiteClassViewModel class with class method declaration and defination implementaion to handle functionality of Schedule controller.
 */
class ScheduleSiteClassViewModel {


  // MARK: ----  MyMVP Schedule Api Asyncronous Call ----
  
  // MARK:  getSiteClassesOfSiteClubFromApiServerBy method.
  class func getSiteClassesOfSiteClubFromApiServerBy(inputParam: [String: String], forSiteClass type:SiteClassesTypeEnum){

    // Code to execute the SiteClasses api from ExerciseClassService to fetch all ExerciseClass of siteid.
    ExerciseClassService.getMyMvpScheduleExerciseClassesBy(inputParam, For: type, completion: { (responseStatus, responseExerciseClassesObjectArray) -> () in
      
      // Code to prepare an object for the notification centre to post with notification to get in observer of notification.
      var notificationObject = [String: AnyObject]()
      notificationObject["status"] = responseStatus.hashValue
      notificationObject["msg"] = ""
      
      if responseStatus == ApiResponseStatusEnum.Success{
      }
      else{
      }
      
      let exerciseClassesObjectArray = responseExerciseClassesObjectArray as! [ExerciseClass]
      print(exerciseClassesObjectArray.count)
      
      // Code to delete old record from Site Classes table.
      let deleteQueryString = ScheduleSiteClassViewModel.deleteQueryForSiteClassBy(type)
      DBManager.sharedInstance.executeDeleteQueryBy(deleteQueryString)
      
      for index in 0..<exerciseClassesObjectArray.count{
        let exerciseClass = exerciseClassesObjectArray[index]
        let classid = exerciseClass.classid! as String
        
        var exerciseClassLocalCacheFlag = false
        let loadQuery = ScheduleSiteClassViewModel.prepareLoadQueryForSiteClassIdBySiteClass(classid, andSiteClass: type)
        if let resultSet = DBManager.sharedInstance.executeLoadQueryBy(loadQuery){
          exerciseClassLocalCacheFlag = DashboardViewModel.validateSiteClassResultSetFor(classid, andResultSet: resultSet)
        }
        
        if exerciseClassLocalCacheFlag == true{ // Update.
//          print("Update")
        }
        else{ // Insert.
//          print("Insert")
          let insertQuery = ScheduleSiteClassViewModel.preparedInsertQueryForExerciseSiteClassBy(exerciseClass, forSiteClassType: type)
          DBManager.sharedInstance.executeInsertQueryBy(insertQuery)
        }
      }
      
      
      // Code to set Api execution status for the Site Class type.
      ScheduleSiteClassViewModel.setMvpScheduleApiStatusFor(type, andStatus: true)
      let observerName = ScheduleSiteClassViewModel.notificationObserverForSiteClassBy(type)
      
      // Code to post notification from NSNotificationCenter instance for My MVP Schedule Site Classes api responser type observer name.
      NSNotificationCenter.defaultCenter().postNotificationName(observerName, object: notificationObject)
    
    })
  }
  
  
  
  // MARK: ----  Dashboard SQL queries ----

  class func deleteSiteClassFromUserFavoriteSiteClassFor(exerciseClass: ExerciseClass, completion: CompletionOfDeleteSiteClassFromLocal){
    let classid = exerciseClass.classid! as String
    
    // Code to execute update query for Site Class userFavourite field.
    let deleteQuery = "DELETE from SiteClassByUserFavourite WHERE classid = \(classid)"
    
    let deleteStatus = DBManager.sharedInstance.executeDeleteQueryBy(deleteQuery)
    completion(deleteStatus)
  }

  
  
  class func updateSiteClassFavouriteFlagForSiteClass(exerciseClass: ExerciseClass, forSiteClassType type:SiteClassesTypeEnum, withFavoriteStatus status: Bool){
    let classid = exerciseClass.classid! as String
    var tableName = ""
    var favouriteStatus = "false"

    if status ==  true{
      favouriteStatus = "'true'"
    }
    else{
      favouriteStatus = "'false'"
    }
    
    switch type {
    case SiteClassesTypeEnum.ByDate:
      tableName = "SiteClassByDate"
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      tableName = "SiteClassByInstructor"
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      tableName = "SiteClassByClasses"
      break
      
    case SiteClassesTypeEnum.MySchedule:
      tableName = "SiteClassByUserFavourite"
      break
    }

    // Code to execute update query for Site Class userFavourite field.
    let updateQuery = "UPDATE \(tableName) SET userFavourite = \(favouriteStatus) WHERE classid = \(classid)"
    DBManager.sharedInstance.executeUpdateQueryBy(updateQuery)
  }
  
  // MARK:  preparedInsertQueryForExerciseSiteClassBy method.
  class func preparedInsertQueryForExerciseSiteClassBy(siteClass: ExerciseClass, forSiteClassType type: SiteClassesTypeEnum) -> String{
    
    var tableName = ""
    switch type {
    case SiteClassesTypeEnum.ByDate:
      tableName = "SiteClassByDate"
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      tableName = "SiteClassByInstructor"
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      tableName = "SiteClassByClasses"
      break
      
    case SiteClassesTypeEnum.MySchedule:
      tableName = "SiteClassByUserFavourite"
      break
    }

    var insertQuery = ""
    let classid = siteClass.classid! as String
    let siteid = siteClass.siteid! as String
    let className = siteClass.className! as String
    let classDescription = siteClass.classDescription! as String
    let classStartTime = siteClass.classStartTime! as String
    let classEndTime = siteClass.classEndTime! as String
    let classLocation = siteClass.classLocation! as String
    let classInstructor = siteClass.classInstructor! as String
    let classInstructorId = siteClass.classInstructorId! as String
    let classInstructorImage = siteClass.classInstructorImage! as String
    let checkedId = siteClass.checkedId! as String
    let userFavourite = siteClass.userFavourite! as Bool
    let userCheckIn = siteClass.userCheckIn! as Bool
    let classInstructorAvailable = siteClass.classInstructorAvailable! as Bool
    
    insertQuery = "insert into \(tableName) (classid, siteid, className, classDescription, classStartTime, classEndTime, classLocation, classInstructor, classInstructorId, classInstructorImage, checkedId, userFavourite, userCheckIn, classInstructorAvailable) values ('\(classid)', '\(siteid)', '\(className)', '\(classDescription)', '\(classStartTime)', '\(classEndTime)', '\(classLocation)', '\(classInstructor)', '\(classInstructorId)', '\(classInstructorImage)', '\(checkedId)', '\(userFavourite)', '\(userCheckIn)', '\(classInstructorAvailable)');"
    
    return insertQuery
  }

  // MARK:  deleteQueryForSiteClassBy method.
  class func deleteQueryForSiteClassBy(type: SiteClassesTypeEnum) -> String{
    var deleteQuery = ""
    switch type {
    case SiteClassesTypeEnum.ByDate:
      deleteQuery = deleteFromSiteClassByDateQuery
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      deleteQuery = deleteFromSiteClassByInstructorQuery
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      deleteQuery = deleteFromSiteClassByClassesQuery
      break
      
    case SiteClassesTypeEnum.MySchedule:
      deleteQuery = deleteFromSiteClassByUserFavouriteQuery
      break
    }
    
    return deleteQuery
  }
  
  // MARK:  prepareLoadQueryForSiteClassIdBySiteClass method.
  class func prepareLoadQueryForSiteClassIdBySiteClass(classid: String, andSiteClass type: SiteClassesTypeEnum) -> String{
    var tableName = ""
    switch type {
    case SiteClassesTypeEnum.ByDate:
      tableName = "SiteClassByDate"
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      tableName = "SiteClassByInstructor"
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      tableName = "SiteClassByClasses"
      break
      
    case SiteClassesTypeEnum.MySchedule:
      tableName = "SiteClassByUserFavourite"
      break
    }
    
    var loadQuery = ""
    loadQuery = "Select classid FROM \(tableName) where classid = \(classid)"
    return loadQuery;
  }

  // MARK:  notificationObserverForSiteClassBy method.
  class func notificationObserverForSiteClassBy(type: SiteClassesTypeEnum) -> String{
    var observerName = ""
    
    switch type {
    case SiteClassesTypeEnum.ByDate:
      observerName = "ScheduleSiteClassesByDate"
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      observerName = "ScheduleSiteClassesByInstructor"
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      observerName = "ScheduleSiteClassesByActivityClasses"
      break
      
    case SiteClassesTypeEnum.MySchedule:
      observerName = "ScheduleSiteClassesByMySchedule"
      break
    }

    return observerName
  }
  
  
  
  
  
  // MARK: ----  Dashboard Api Status methods ----
  
  // MARK:  setMvpScheduleApiStatusFor method.
  class func setMvpScheduleApiStatusFor(type: SiteClassesTypeEnum, andStatus status: Bool){
    switch type {
    case SiteClassesTypeEnum.ByDate:
      NSUserDefaults.standardUserDefaults().setValue(status, forKey: "ScheduleSiteClassByDateApiStatus")
      NSUserDefaults.standardUserDefaults().synchronize()
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      NSUserDefaults.standardUserDefaults().setValue(status, forKey: "ScheduleSiteClassByInstructorApiStatus")
      NSUserDefaults.standardUserDefaults().synchronize()
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      NSUserDefaults.standardUserDefaults().setValue(status, forKey: "ScheduleSiteClassByClassesApiStatus")
      NSUserDefaults.standardUserDefaults().synchronize()
      break

    case SiteClassesTypeEnum.MySchedule:
      NSUserDefaults.standardUserDefaults().setValue(status, forKey: "ScheduleSiteClassByMyScheduleApiStatus")
      NSUserDefaults.standardUserDefaults().synchronize()
      break
    }
  }
  
  // MARK:  validateMvpScheduleApiStatusForExecution method.
  class func validateMvpScheduleApiStatusForExecution(type: SiteClassesTypeEnum) -> Bool{
    var apiExecutionFlag = true
    
    switch type {
    case SiteClassesTypeEnum.ByDate:
      if let apiStatus = NSUserDefaults.standardUserDefaults().valueForKey("ScheduleSiteClassByDateApiStatus") as? Bool{
        if apiStatus == false{
          apiExecutionFlag = false
        }
      }
      break
      
    case SiteClassesTypeEnum.ByInstructor:
      if let apiStatus = NSUserDefaults.standardUserDefaults().valueForKey("ScheduleSiteClassByInstructorApiStatus") as? Bool{
        if apiStatus == false{
          apiExecutionFlag = false
        }
      }
      break
      
    case SiteClassesTypeEnum.ByActivityClass:
      if let apiStatus = NSUserDefaults.standardUserDefaults().valueForKey("ScheduleSiteClassByClassesApiStatus") as? Bool{
        if apiStatus == false{
          apiExecutionFlag = false
        }
      }
      break
      
    case SiteClassesTypeEnum.MySchedule:
      if let apiStatus = NSUserDefaults.standardUserDefaults().valueForKey("ScheduleSiteClassByMyScheduleApiStatus") as? Bool{
        if apiStatus == false{
          apiExecutionFlag = false
        }
      }
      break
    }

    return apiExecutionFlag;
  }

}