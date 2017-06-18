//
//  ExerciseClassService.swift
//  MVPSports
//
//  Created by Chetu India on 22/08/16.
//

import Foundation


// ExerciseClassServiceCompletion declare callback for ExerciseClassService class method with parameter.
typealias ExerciseClassServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


/*
 * ExerciseClassService class with class method declaration and defination implementaion to handle functionality of SiteClasses api endpoint.
 */
class ExerciseClassService{
  
  
  // MARK:  getSiteClassDescriptionBy method.
  class func getSiteClassDescriptionBy(inputFields: [ String: String], For className: String,  completion: ExerciseClassServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of GetClassDescriptions.
    let request = NetworkManager.requestHeaderForApiByUrl(siteClassDescriptionServiceURL)

    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        let siteClassDescription = ExerciseClassViewModel.parseSiteClassesDescriptionJsonResponseDataBy(responseData as! NSData, forClass: className)
        completion(status, siteClassDescription)
      }
      else{
        completion(status, "")
      }
    })
  }
  
  
  // MARK:  setFavouriteToScheduleExerciseClassesBy method.
  class func setFavouriteToScheduleExerciseClassesBy(inputFields: [ String: AnyObject], favouriteFlag: Bool,  completion: ExerciseClassServiceCompletion) {
    var apiUrl = ""
    if favouriteFlag == false{
      apiUrl = setFavouriteSiteClassServiceURL
    }
    else{
      apiUrl = setUnFavouriteSiteClassServiceURL
    }
    
    let setFavouriteRequest = NetworkManager.requestHeaderForApiByUrl(apiUrl)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      setFavouriteRequest.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestApi(setFavouriteRequest, completion: { (status, responseData) -> () in
      completion(status, responseData)
    })
  }
  
  
  // MARK:  getMyMvpScheduleExerciseClassesBy method.
  class func getMyMvpScheduleExerciseClassesBy(inputFields: [ String: String], For type: SiteClassesTypeEnum,  completion: ExerciseClassServiceCompletion) {
    
    // Code to call ExerciseClassService class method to prepare Site Classes api request
    let request = ExerciseClassService.prepareSiteClassesRequestObjectBy(inputFields, For: type)
    
    // Code to hit web api request header to fetch site classes.
    NetworkManager.requestApi(request, completion: { (siteClassStatus, responseData) -> () in
//      let responseString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//      print(responseString)
      
      if siteClassStatus == ApiResponseStatusEnum.Success{
         let arrayOfExerciseClassObject = ExerciseClassViewModel.parseSiteClassesJsonResponseDataBy(responseData as! NSData)
        
        // For logged user validation.
        let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
        if userLoginFlag == true{ // When user is logged in
          
          // Code to call ExerciseClassService class method to prepare Site Classes api request
          let userFavouriteSiteClassesRequest = ExerciseClassService.prepareUserFavoriteSiteClassesRequestObject()
          // Code to hit web api request header to fetch rewards.
          NetworkManager.requestApi(userFavouriteSiteClassesRequest, completion: { (favouriteStatus, favouriteSiteClassResponseData) -> () in
            
            // Code to get Site Classes logged user favourite Site Classes status.
            let exerciseClassObjectArray = ExerciseClassViewModel.parseFavouriteSiteClassApiResponseDataForSiteClassBy(favouriteSiteClassResponseData as! NSData, with: arrayOfExerciseClassObject)
            completion(siteClassStatus, exerciseClassObjectArray)
          })
        }
        else{
          // When user is not logged in. Call callback method with Site Classes object Array.
          completion(siteClassStatus, arrayOfExerciseClassObject)
        }
      }
      else{
        // Call completion call back method when Site Classes api failure.
        let arrayOfExerciseClassesObject = [ExerciseClass]()
        completion(siteClassStatus, arrayOfExerciseClassesObject)
      }
    })
  }
  
  
  // MARK:  prepareSiteClassesRequestObjectBy method.
  class func prepareSiteClassesRequestObjectBy(inputFields: [ String: String], For type: SiteClassesTypeEnum) -> NSMutableURLRequest {
    var apiUrl = ""
    var urlPostParam = ""
 
    // get Site Class api request url based on Type of Site Class request.
    switch type {
    case SiteClassesTypeEnum.ByDate:
      apiUrl = exerciseClassServiceURL
      break
    case SiteClassesTypeEnum.ByInstructor:
      apiUrl = exerciseClassForInstructorActivityServiceURL
      break
    case SiteClassesTypeEnum.ByActivityClass:
      apiUrl = exerciseClassForInstructorActivityServiceURL
      break
    case SiteClassesTypeEnum.MySchedule:
      apiUrl = favouriteSiteClassesServiceURL
      break
    }
    
    // prepare Url Post request parameter formatted string.
    let keyArray = Array(inputFields.keys)
    for index in 0 ..< keyArray.count{
      let key = keyArray[index] as String
      let value = inputFields[key]! as String
      
      if index == keyArray.count-1{
        urlPostParam = "\(urlPostParam)\(key)=\(value)"
      }
      else{
        urlPostParam = "\(urlPostParam)\(key)=\(value)&"
      }
    }
    
    let postData: NSData = urlPostParam.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
    let postLength: String = "\(postData.length)"
    
    // Code to create NSMutableURLRequest object for header of SiteClasses.
    let request = NetworkManager.requestHeaderForApiByUrl(apiUrl)
    request.setValue(postLength, forHTTPHeaderField: "Content-Length")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = postData

    return request
  }
  
  
  // MARK:  prepareUserFavoriteSiteClassesRequestObject method.
  class func prepareUserFavoriteSiteClassesRequestObject() -> NSMutableURLRequest {
    // Code to create NSMutableURLRequest object for header of getFavouriteSiteClasses.
    let request = NetworkManager.requestHeaderForApiByUrl(favouriteSiteClassesServiceURL)
    
    var inputField = [String: String]()
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    inputField["MemberId"] = memberId
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputField, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }

    return request
  }
    
}
