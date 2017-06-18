//
//  LoginService.swift
//  MVPSports
//

import Foundation

// LoginServiceCompletion declare callback for LoginService class method with parameter.
typealias LoginServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()

/*
 * SiteClubApiTypesEnum is an enumeration of Site Club Api request.
 */
enum AuthUserApiTypesEnum {
  case AuthUser
  case SendPassword
  case FindMember
}

/*
 * LoginService class with class method declaration and defination implementaion to handle functionality of Login api endpoint.
 */
class LoginService{
  

  // MARK:  authUserWith method.
  class func authUserWith(inputFields: [ String: String], completion: LoginServiceCompletion) {
    let request = LoginService.prepareApiRequestObjectForAuthUserBy(inputFields, forApiType: AuthUserApiTypesEnum.AuthUser)
    print("Login request: \(inputFields)")
    
    // Code to hit web api request header to fetch rewards.
    NetworkManager.requestAuthApi(request, completion: { (status, responseData) -> () in
      let responseJsonString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
      print("Login response: \(responseJsonString)")

      if status == ApiResponseStatusEnum.Success{
        // Code to parse the responseData from reponse of logged user.
        UserViewModel.parseLoggedUserJsonResponseDataToSaveInLocalDefault(responseData as! NSData, with: inputFields)
        
        let userLoginFlag = UtilManager.sharedInstance.validateLoggedUserStatus()
        if userLoginFlag == true{ // When user logged in success.
          if UserViewModel.validateForLoggecdUserMembershipAndDefaultSiteAreSame() == true{
            completion(ApiResponseStatusEnum.Success, "")
          }
          else{ // Code to get Default Site Club name from api service to update Site Name
            
            let inputField = [String: String]()
            // Code to execute the getSiteClubsBy api endpoint from SiteClubService class method getSiteClubsBy to fetch all SiteClub of application.
            SiteClubService.getSiteClubsBy(inputField, completion: { (apiStatus, arrayOfSiteClubs) -> () in
              if let siteClubArray = arrayOfSiteClubs as? [SiteClub]{
                
                // Code to call method of UserViewModel to update Default Site Club of logged user.
                if siteClubArray.count > 0{
                  UserViewModel.updateDefaultSiteClubIdAndNameFrom(siteClubArray)
                }
              }
              
              // Code to Callback completion method
              completion(ApiResponseStatusEnum.Success, "")
            })
          }
        }
        else{ // When user login failure.
          // let failureMessage = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
          completion(ApiResponseStatusEnum.Failure, responseData)
        }
      }
      else{
        // let failureMessage = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
        completion(status, responseData)
      }
    })
  }
  
  
  // MARK:  sendPasswordServiceBy method.
  class func sendPasswordServiceBy(inputFields: [ String: String], completion: LoginServiceCompletion) {
    let request = LoginService.prepareApiRequestObjectForAuthUserBy(inputFields, forApiType: AuthUserApiTypesEnum.SendPassword)
    
    // Code to hit web api request header to send password reset email link to registered email.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
//      let responseJsonString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//      print(responseJsonString)

      if status == ApiResponseStatusEnum.Success{
        completion(status, responseData)
      }
      else{
        // let failureMessage = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
        completion(status, responseData)
      }
    })
  }
  
  
  // MARK:  FindMemberByIdServiceBy method.
  class func FindMemberByIdServiceBy(inputFields: [ String: String], completion: LoginServiceCompletion) {
    let request = LoginService.prepareApiRequestObjectForAuthUserBy(inputFields, forApiType: AuthUserApiTypesEnum.FindMember)
    
    // Code to hit web api request header to send password reset email link to registered email.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        completion(status, responseData)
      }
      else{
        // let failureMessage = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
        completion(status, responseData)
      }
    })
  }
  
  
  // MARK:  prepareApiRequestObjectForAuthUserBy method.
  class func prepareApiRequestObjectForAuthUserBy(inputFields: [ String: String], forApiType type: AuthUserApiTypesEnum) -> NSMutableURLRequest {
    var apiUrl = ""
    switch type {
    case AuthUserApiTypesEnum.AuthUser:
      apiUrl = loginAuthServiceURL
      
    case AuthUserApiTypesEnum.SendPassword:
      apiUrl = sendPasswordServiceURL
      
    case AuthUserApiTypesEnum.FindMember:
      apiUrl = findMemberByIdServiceURL
    }
    
    // Code to create NSMutableURLRequest object for header of Auth user Api request.
    let request = NetworkManager.requestHeaderForApiByUrl(apiUrl)
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    return request
  }
  
}