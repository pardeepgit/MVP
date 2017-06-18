//
//  WorkoutService.swift
//  MVPSports
//
//  Created by Chetu India on 12/09/16.
//

import Foundation

// WorkoutServiceCompletion declare callback for WorkoutService class method with parameter.
typealias WorkoutServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


class WorkoutService {

  
  // MARK:  getMyMvpWorkoutsBy method.
  class func getMyMvpWorkoutsBy(inputFields: [ String: String], completion: WorkoutServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of GetWorkOuts.
    let request = NetworkManager.requestHeaderForApiByUrl(getWorkOutsServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
//      let responseString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//      print(responseString)
      
      if status == ApiResponseStatusEnum.Success{
        let arrayOfWorkoutObject = WorkoutViewModel.parseWorkoutJsonResponse(responseData as! NSData)
        completion(status, arrayOfWorkoutObject)
      }
      else{
        let arrayOfWorkoutObject = [Workout]()
        completion(status, arrayOfWorkoutObject)
      }
    })
    
  }

  
  // MARK:  editMyMvpWorkoutsBy method.
  class func editMyMvpWorkoutsBy(inputFields: [ String: String], And manualWorkoutFlag: Bool, completion: WorkoutServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of Edit Workout.
    let request = NetworkManager.requestHeaderForApiByUrl(genericEditWorkOutsServiceURL)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        completion(status, "")
      }
      else{
        completion(status, "")
      }
    })
  }
  
  
  // MARK:  saveMyMvpWorkoutsBy method.
  class func saveMyMvpWorkoutsBy(inputFields: [ String: AnyObject], completion: WorkoutServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of WorkOut/SaveWorkOut.
    let request = NetworkManager.requestHeaderForApiByUrl(saveWorkOutsServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        completion(status, responseData)
      }
      else if status == ApiResponseStatusEnum.Failure{
        completion(status, responseData)
      }
      else{
        completion(status, responseData)
      }
    })
  }
  

  // MARK:  deleteMyMvpWorkoutsBy method.
  class func deleteMyMvpWorkoutsBy(inputFields: [ String: AnyObject], completion: WorkoutServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of WorkOut/DeleteWorkOut.
    let request = NetworkManager.requestHeaderForApiByUrl(deleteWorkOutsServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        completion(status, responseData)
      }
      else if status == ApiResponseStatusEnum.Failure{
        completion(status, responseData)
      }
      else{
        completion(status, responseData)
      }
    })
  }
  

  // MARK:  validateTokenAuthenticityForConnectedAppsBy method.
  class func validateTokenAuthenticityForConnectedAppsBy(){
    
    // Code to create input param dictionary.
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    var inputField = [String: String]()
    inputField["memid"] = memberId
    
    // Code to execute the GetConnectedAppsBy api endpoint from NotificationService class method ConectedApp to fetch all NotificationClub of memberid.
    NotificationService.getConnectedAppsBy(inputField, completion: { (responseStatus, arrayOfConnectedAppsObject) -> () in
      var status = false
      var msg = ""
      
      if responseStatus == ApiResponseStatusEnum.Success{
        let failedConnectedApps = WorkoutService.getFailedTokenAuthenticityConnectedAppFrom(arrayOfConnectedAppsObject as! [ConnectedApp])
        if failedConnectedApps.characters.count > 0{
          status = true
          msg = failedConnectedApps
        }
      }
      
      // Code to prepare an object for the notification centre to post with notification to get in observer of notification.
      var notificationObject = [String: AnyObject]()
      notificationObject["status"] = status
      notificationObject["msg"] = msg
      
      // Code to post notification from NSNotificationCenter instance for ConnectedAppsTokenAuthenticity observer name.
      NSNotificationCenter.defaultCenter().postNotificationName("ConnectedAppsTokenAuthenticity", object: notificationObject)
    })
  }
  
  
  // MARK:  getFailedTokenAuthenticityConnectedAppFrom method.
  class func getFailedTokenAuthenticityConnectedAppFrom(connectedAppArray: [ConnectedApp]) -> String{
    var faliedApps = ""
    if connectedAppArray.count > 0{
      
      for index in 0..<connectedAppArray.count {
        let connectedAppObject = connectedAppArray[index]
        let appid = connectedAppObject.appid
        let tokenAuthenticity = connectedAppObject.tokenAuthenticity
        
        if tokenAuthenticity == 0{
          
          switch appid! {
          case 1:
            faliedApps = faliedApps.characters.count > 0 ? "\(faliedApps), FitBit" : "FitBit"
            break
          case 2:
            faliedApps = faliedApps.characters.count > 0 ? "\(faliedApps), Polar" : "Polar"
            break
          case 5:
            faliedApps = faliedApps.characters.count > 0 ? "\(faliedApps), Under Armour" : "Under Armour"
            break
          default:
            print("")
            break
          }
        }
      }
    }
    
    return faliedApps
  }
  
  
}
