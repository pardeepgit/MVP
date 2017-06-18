//
//  DashboardViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 27/12/16.
//

import Foundation


enum DashboardApiEnum {
  case SiteClass
  case OptIn
}


/*
 * DashboardViewModel class with class method declaration and defination implementaion to handle functionality of Dashboard controller.
 */
class DashboardViewModel {
  
  // MARK: ----  Dashboard Api Asyncronous Call ----

  // MARK:  getSiteClassesOfSiteClubFromApiServerBy method.
  class func getSiteClassesOfSiteClubFromApiServerBy(inputParam: [String: String]){

    // Code to execute the SiteClasses api endpoint from ExerciseClassService class method getMyMvpScheduleExerciseClassesBy to fetch all ExerciseClass of siteid.
    ExerciseClassService.getMyMvpScheduleExerciseClassesBy(inputParam, For: SiteClassesTypeEnum.ByDate, completion: { (responseStatus, responseExerciseClassesObjectArray) -> () in

      // Code to prepare an object for the notification centre to post with notification to get in observer of notification.
      var notificationObject = [String: AnyObject]()
      notificationObject["status"] = responseStatus.hashValue
      notificationObject["msg"] = ""

      let arrayOfExerciseClassesObject = responseExerciseClassesObjectArray as! [ExerciseClass]
      if arrayOfExerciseClassesObject.count > 0{
        
        // Code to delete old record from table SiteClassByDate.
        let deleteQueryString = deleteFromSiteClassByDateQuery
        DBManager.sharedInstance.executeDeleteQueryBy(deleteQueryString)
        
        for index in 0..<arrayOfExerciseClassesObject.count{
          let exerciseClass = arrayOfExerciseClassesObject[index] 
          let classid = exerciseClass.classid! as String
          
          var exerciseClassLocalCacheFlag = false
          let loadQuery = DashboardViewModel.prepareLoadQueryForClassIdBySiteClass(classid)
          if let resultSet = DBManager.sharedInstance.executeLoadQueryBy(loadQuery){
            exerciseClassLocalCacheFlag = DashboardViewModel.validateSiteClassResultSetFor(classid, andResultSet: resultSet)
          }
          
          if exerciseClassLocalCacheFlag == true{ // Update.
            // print("Update into SiteClassByDate table")
          }
          else{ // Insert.
            // print("Insert into SiteClassByDate table")
            let insertQuery = DashboardViewModel.prepareInsertQueryForExerciseSiteClass(exerciseClass)
            DBManager.sharedInstance.executeInsertQueryBy(insertQuery)
          }
        }
      }
      
      // Code to update SiteClass api status on Dashboard screen.
      DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.SiteClass, andStatus: true)

      // Code to post notification from NSNotificationCenter instance for DashboardSiteClassesByDate observer name.
      NSNotificationCenter.defaultCenter().postNotificationName("DashboardSiteClassesByDate", object: notificationObject)
    })
  }

  // MARK:  getLoggedUserOptInStatusBy method.
  class func getLoggedUserOptInStatusBy(inputParam: [String: String]){

    // Code to execute the GetRewards api endpoint from RewardService class method getMyMvpRewardBy to fetch all rewards of memid.
    RewardService.getUserOptInStatusBy(inputParam, completion: { (apiStatus, optInStatus) -> () in
      
      // Code to prepare an object for the notification centre to post with notification to get in observer of notification.
      var notificationObject = [String: AnyObject]()
      notificationObject["status"] = apiStatus.hashValue
      notificationObject["msg"] = ""
      
      if optInStatus == UserOptInStatusEnum.HpChart{
        // Default inputParam dictionary.
        let inputField = [String: String]()
        // Code to execute the GetRewards api endpoint from RewardService class method getMyMvpRewardBy to fetch all rewards of memid.
        RewardService.getHealthPointLevelsBy(inputField, completion: { (responseStatus, arrayOfHealthPointLevel) -> () in

          // Code to create input Param dictionary for the earned point level.
          var inputField = [String: String]()
          inputField = inputParam
          inputField["RequestedDate"] = "1/1/2016"
          
          // Code to execute the GetHealthPoint api endpoint service to fetch logged member health point level.
          RewardService.getMemberHealthPointsBy(inputField, completion: { (responseStatus, earnedPointLevel) -> () in
            // Code to validate for the health point levele array count.
            if arrayOfHealthPointLevel.count > 0{
              // Code to save HpChart data information into local.
              BarChartViewModel.setHpChartDataFor(arrayOfHealthPointLevel, And: earnedPointLevel)
            }
            else{
              /*
               * Code to save Default HpChart data of logged user for OptIn Status functionality.
               */
              BarChartViewModel.setDeafultOptInHpChartData()
            }
            
            // Code to update OptIn api status on Dashboard screen.
            DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.OptIn, andStatus: true)

            // Code to post notification from NSNotificationCenter instance for UserOptInStatus observer name.
            NSNotificationCenter.defaultCenter().postNotificationName("UserOptInStatus", object: notificationObject)
          })
        })
        
      }
      else if optInStatus == UserOptInStatusEnum.PunchCardSession{
        
        // Code to execute the GetRewards api endpoint from RewardService class method getMyMvpRewardBy to fetch all rewards of memid.
        RewardService.getUserPunchCardBy(inputParam, completion: { (apiStatus, punchCardTuppleResponse) -> () in
          
          // Code to save OptIn View data information into local.
          BarChartViewModel.setPunchCardSessionDataFor(punchCardTuppleResponse )
          
          // Code to update OptIn api status on Dashboard screen.
          DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.OptIn, andStatus: true)
          
          // Code to post notification from NSNotificationCenter instance for UserOptInStatus observer name.
          NSNotificationCenter.defaultCenter().postNotificationName("UserOptInStatus", object: notificationObject)
          
        })
      }
      else if optInStatus == UserOptInStatusEnum.OptInView{
        // Code to save OptIn View data information into local.
        BarChartViewModel.setOptInViewDataFor()
        
        // Code to update OptIn api status on Dashboard screen.
        DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.OptIn, andStatus: true)

        // Code to post notification from NSNotificationCenter instance for UserOptInStatus observer name.
        NSNotificationCenter.defaultCenter().postNotificationName("UserOptInStatus", object: notificationObject)
      }
      else if optInStatus == UserOptInStatusEnum.DefaultUpChart{
        /*
         * Code to save Default HpChart data of logged user for OptIn Status functionality.
         */
        BarChartViewModel.setDeafultOptInHpChartData()
        
        // Code to update OptIn api status on Dashboard screen.
        DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.OptIn, andStatus: true)

        // Code to post notification from NSNotificationCenter instance for UserOptInStatus observer name.
        NSNotificationCenter.defaultCenter().postNotificationName("UserOptInStatus", object: notificationObject)
      }
      else if optInStatus == UserOptInStatusEnum.HideHpView{
        /*
         * Code to save Hide HpChart and OptIn status of logged user for OptIn Status functionality.
         */
        BarChartViewModel.setHideOptInHpChartStatus()
        
        // Code to update OptIn api status on Dashboard screen.
        DashboardViewModel.setDashoboardApiStatusFor(DashboardApiEnum.OptIn, andStatus: true)
        
        // Code to post notification from NSNotificationCenter instance for UserOptInStatus observer name.
        NSNotificationCenter.defaultCenter().postNotificationName("UserOptInStatus", object: notificationObject)
      }
      
    })

  }
  
  
  
  // MARK: ----  Dashboard SQL queries ----
  
  // MARK:  prepareInsertQueryForExerciseSiteClass method.
  class func prepareInsertQueryForExerciseSiteClass(siteClass: ExerciseClass) -> String{
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

    insertQuery = "insert into SiteClassByDate (classid, siteid, className, classDescription, classStartTime, classEndTime, classLocation, classInstructor, classInstructorId, classInstructorImage, checkedId, userFavourite, userCheckIn, classInstructorAvailable) values ('\(classid)', '\(siteid)', '\(className)', '\(classDescription)', '\(classStartTime)', '\(classEndTime)', '\(classLocation)', '\(classInstructor)', '\(classInstructorId)', '\(classInstructorImage)', '\(checkedId)', '\(userFavourite)', '\(userCheckIn)', '\(classInstructorAvailable)');"
    return insertQuery
  }
  
  // MARK:  prepareLoadQueryForClassIdBySiteClass method.
  class func prepareLoadQueryForClassIdBySiteClass(classid: String) -> String{
    var loadQuery = ""
    loadQuery = "Select classid FROM SiteClassByDate where classid = \(classid)"
    return loadQuery;
  }
  
  
  
  
  // MARK: ----  Dashboard Api & SQL query helper methods ----
  
  // MARK:  validateSiteClassResultSetFor method.
  class func validateSiteClassResultSetFor(classId: String, andResultSet resultSet: FMResultSet) -> Bool{
    var flag = false
    if resultSet.next() {
      if let classid = resultSet.stringForColumn("classid"){
        if classid == classId{
          flag = true
        }
      }
    }
    return flag
  }
  
  
  
  
  // MARK: ----  Dashboard Api Status methods ----
  
  // MARK:  setDashoboardApiStatusFor method.
  class func setDashoboardApiStatusFor(type: DashboardApiEnum, andStatus status: Bool){
    switch type {
    case DashboardApiEnum.SiteClass:
      NSUserDefaults.standardUserDefaults().setValue(status, forKey: "SiteClassApiStatus")
      NSUserDefaults.standardUserDefaults().synchronize()
      break
      
    case DashboardApiEnum.OptIn:
      NSUserDefaults.standardUserDefaults().setValue(status, forKey: "OptInApiStatus")
      NSUserDefaults.standardUserDefaults().synchronize()
      break
    }
  }
  
  // MARK:  validateDashoboardApiStatusForExecution method.
  class func validateDashoboardApiStatusForExecution() -> Bool{
    var apiExecutionFlag = true

    if let siteClassApiStatus = NSUserDefaults.standardUserDefaults().valueForKey("SiteClassApiStatus") as? Bool{
      if siteClassApiStatus == false{
        apiExecutionFlag = false
      }
    }
    
    if let optInApiStatus = NSUserDefaults.standardUserDefaults().valueForKey("OptInApiStatus") as? Bool{
      if optInApiStatus == false{
        apiExecutionFlag = false
      }
    }

    return apiExecutionFlag;
  }
  
}