//
//  CheckInService.swift
//  MVPSports
//
//  Created by Chetu India on 06/10/16.
//

import Foundation


// CheckInServiceCompletion declare callback for CheckInService class method with parameter.
typealias CheckInServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


class CheckInService {
  
  
  // MARK:  getUserSiteClubCheckInStatusBy method.
  class func getUserSiteClubCheckInStatusBy(inputFields: [ String: String], completion: CheckInServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of GetIsCheckedIn.
    let request = NetworkManager.requestHeaderForApiByUrl(getUserSiteClubCheckInStatusServiceURL)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request for logged user Site Club CheckIn status.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
//      let responseJsonString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//      print("Response json is :\n\(responseJsonString)")

      if apiStatus == ApiResponseStatusEnum.Success{
        var userSiteClubCheckInStatusResponse = [String: AnyObject]()
        do {
          // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
          try userSiteClubCheckInStatusResponse = (NSJSONSerialization.JSONObjectWithData(responseData as! NSData, options: []) as? [String: AnyObject])!
        }
        catch let error as NSError {
          print(error)
        }
        
        var checkInStatus = false
        if let userSiteClubCheckInStatusResponseArray = userSiteClubCheckInStatusResponse[RESPONSE] as? [[String: AnyObject]]{
          if userSiteClubCheckInStatusResponseArray.count > 0{
            let userSiteClubCheckInStatusDict = userSiteClubCheckInStatusResponseArray[0]
            if let checkinstatus = userSiteClubCheckInStatusDict["IsCheckedIn"] as? Bool{
              checkInStatus = checkinstatus
            }
          }
        }
        
        completion(apiStatus, checkInStatus)
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        completion(apiStatus, false)
      }
      else{ // For Network error
        completion(apiStatus, false)
      }
    })
  }
  
  
  // MARK:  getUserCheckInScheduleClassesBy method.
  class func getUserCheckInScheduleClassesBy(inputFields: [ String: String], completion: CheckInServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of getUserCheckInScheduleClasses.
    let request = NetworkManager.requestHeaderForApiByUrl(getUserCheckInSiteClassesServiceURL)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    
    // Code to hit web api request header to fetch check in site classes.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in

      if apiStatus == ApiResponseStatusEnum.Success{
        /*
         * Code to fetch the checkedIn site class to compare by classid.
         */
        let checkedInSiteClassRequest = NetworkManager.requestHeaderForApiByUrl(getCheckedInSiteClassesServiceURL)
        var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
        let memberId = loggedUserDict["memberId"]! as String
        let siteid = loggedUserDict["Siteid"]! as String

        var checkedInInputField = [String: String]()
        checkedInInputField["memid"] = memberId
        checkedInInputField["siteid"] = siteid

        do {
          // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
          let jsonData = try NSJSONSerialization.dataWithJSONObject(checkedInInputField, options: .PrettyPrinted)
          checkedInSiteClassRequest.HTTPBody = jsonData
        }
        catch let error as NSError {
          print(error)
        }
        
        // Code to hit web api request header to fetch check in site classes.
        NetworkManager.requestApi(checkedInSiteClassRequest, completion: { (checkedinApiStatus, checkedInResponseData) -> () in
          if checkedinApiStatus == ApiResponseStatusEnum.Success{
            let arrayOfExerciseClassObject = ExerciseClassViewModel.parseCheckInSiteClassesJsonResponse(responseData as! NSData, with: checkedInResponseData as! NSData)
            completion(apiStatus, arrayOfExerciseClassObject)
          }
          else if checkedinApiStatus == ApiResponseStatusEnum.Failure{ // For failure case
            let arrayOfExerciseClassObject = ExerciseClassViewModel.parseCheckInSiteClassesJsonResponse(responseData as! NSData, with: NSData())
            completion(apiStatus, arrayOfExerciseClassObject)
          }
          else{ // For Network error
            let arrayOfExerciseClassObject = ExerciseClassViewModel.parseCheckInSiteClassesJsonResponse(responseData as! NSData, with: NSData())
            completion(apiStatus, arrayOfExerciseClassObject)
          }
        })
        
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        let arrayOfExerciseClassObject = [ExerciseClass]()
        completion(apiStatus, arrayOfExerciseClassObject)
      }
      else{ // For Network error
        let arrayOfExerciseClassObject = [ExerciseClass]()
        completion(apiStatus, arrayOfExerciseClassObject)
      }
    })
  }
  
  
  // MARK:  markUserCheckInScheduleClassBy method.
  class func markUserCheckInScheduleClassBy(inputFields: [ String: String], completion: CheckInServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of markUserCheckInScheduleClass.
    let request = NetworkManager.requestHeaderForApiByUrl(markUserCheckInSiteClassServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to mark site class check in.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
      var checkInSiteClassesResponse = [String: AnyObject]()
      do {
        // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
        try checkInSiteClassesResponse = (NSJSONSerialization.JSONObjectWithData(responseData as! NSData, options: []) as? [String: AnyObject])!
      }
      catch let error as NSError {
        print(error)
      }
      
      if apiStatus == ApiResponseStatusEnum.Success{
        var checkedInId = 0
        
        if let checkInSiteClassesObjectArray = checkInSiteClassesResponse[RESPONSE] as? [[String: AnyObject]]{
          if checkInSiteClassesObjectArray.count > 0{
            let checkInSiteClassObject = checkInSiteClassesObjectArray[0]
            
            if let checkinid = checkInSiteClassObject["checkinid"] as? Int{
              checkedInId = checkinid
            }
          }
        }
        
        completion(apiStatus, "\(checkedInId)")
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        completion(apiStatus, responseData)
      }
      else{ // For Network error
        completion(apiStatus, "Network error")
      }
    })
  }
  
  
  // MARK:  deleteClassCheckedInBy method.
  class func deleteClassCheckedInBy(inputFields: [ String: String], completion: CheckInServiceCompletion) {
    print(inputFields)
    // Code to create NSMutableURLRequest object for header of deleteClassCheckedInServiceURL.
    let request = NetworkManager.requestHeaderForApiByUrl(deleteClassCheckedInServiceURL)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to mark site class check in.
    NetworkManager.requestApi(request, completion: { (apiStatus, responseData) -> () in
      if apiStatus == ApiResponseStatusEnum.Success{
        completion(apiStatus, "")
      }
      else if apiStatus == ApiResponseStatusEnum.Failure{ // For failure case
        completion(apiStatus, "")
      }
      else{ // For Network error
        completion(apiStatus, "")
      }
    })
  }
  
}