//
//  NetworkManager.swift
//  MVPSportsRestApiDummy
//
//  Created by Chetu India on 16/08/16.
//

import Foundation


// NetworkManagerCompletion declare callback for NetworkManager class method with parameter.
typealias NetworkManagerCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


/*
 * NetworkManager class with class method declaration and defination implementaion to handle functionality api endpoints.
 * NetworkManager class method for base httpRequest and NSSession method.
 */
class NetworkManager {
  
  
  /*
   * basicRequestHeaderForUrl method return base header httprequest for the MVPSports api endpoints.
   * basicRequestHeaderForUrl method return httprequest with Basic 64Encoded authorization.
   */
  // MARK:  basicRequestHeaderForUrl method.
  class func basicRequestHeaderForUrl(urlAddress: String) -> NSMutableURLRequest{
    let url: NSURL = NSURL(string: urlAddress)!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Application/json,text/javascript,*/*;q=0.01", forHTTPHeaderField: "Accept")
    request.setValue(NSString(format: "Basic %@", NetworkManager.getBase64AuthTokenFromTokenString()) as String, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 20.0

    return request
  }
  
  /*
   * requestHeaderForClientTokeByUrl method return  header httprequest for the client token api endpoints.
   */
  // MARK:  requestHeaderForClientTokeByUrl method.
  class func requestHeaderForClientTokeByUrl(urlAddress: String) -> NSMutableURLRequest{
    let request = NetworkManager.basicRequestHeaderForUrl(urlAddress)
    request.setValue(UserViewModel.getRefreshToken(), forHTTPHeaderField: "Refresh_token")
    return request
  }
  
  /*
   * requestHeaderForClientTokeByUrl method return  header httprequest for the api endpoints with client token.
   */
  // MARK:  requestHeaderForApiByUrl method.
  class func requestHeaderForApiByUrl(urlAddress: String) -> NSMutableURLRequest{
    let request = NetworkManager.basicRequestHeaderForUrl(urlAddress)
    let client_token = UserViewModel.getClientToken()
    if client_token.characters.count > 0{
      request.setValue(client_token, forHTTPHeaderField: "clienttoken")
    }
    return request
  }
  
  
  
  
  
  /*
   * Code to execute request api from NSURLSession class method dataTask to resume operation.
   * Code to cofirm httpResponseStatus code for sucess and failure.
   */
  // MARK:  requestAuthApi method.
  class func requestAuthApi(request: NSMutableURLRequest, completion: NetworkManagerCompletion){
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      if data != nil{
        /*
         * Code to Validate Api endpoint response for the success and failure cases.
         * Call method of UtilManager class validateApiForSuccessResponse to validate response NSData on Status key field value resoponse.
         * Compare the response value for the Success and Failure identifier.
        */
        if UtilManager.sharedInstance.validateApiForSuccessResponse(data!){
          /*
           * Code to fetch refresh_token from NSHTTPURLResponse object of api response header.
           * Fetch refresh token value on the key of refresh_token.
          */
          let httpResponse = response as? NSHTTPURLResponse
          if let refresh_token = httpResponse?.allHeaderFields["refresh_token"] as? String {
            // Code to save refresh token in user default local.
            UserViewModel.setRefreshToken(refresh_token)
          }
          else{
            // Code to save refresh token in user default local.
            UserViewModel.setRefreshToken("")
          }
          
          // Code to call completion block for the api response success.
          completion(ApiResponseStatusEnum.Success, data!)
        }
        else{
          // now val is not nil and the Optional has been unwrapped, so use it
          completion(ApiResponseStatusEnum.Failure, data!)
        }
      }
      else{
        let respData = NSData()
        completion(ApiResponseStatusEnum.NetworkError, respData)
      }
    })
    
    task.resume()
  }
  
  /*
   * Code to execute request api from NSURLSession class method dataTask to resume operation.
   * Code to cofirm httpResponseStatus code for sucess and failure.
   */
  // MARK:  requestApi method.
  class func requestApi(request: NSMutableURLRequest, completion: NetworkManagerCompletion){
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      /*
       * Code to validate api response data exist or not.
      */
      if data != nil{
        /*
         * Code to validate api response httpResponse code is 201 or not for api successfull execution.
         */
        let httpResponse = response as? NSHTTPURLResponse
        if httpResponse!.statusCode == 201{
          /*
           * Code to validate api response data for token expiry or not.
           * If case is the client token is expired and we need to fetch the new client token by the refresh_token
           * Else case for the api success response.
           */
          if NetworkManager.validateApiResponseForClientTokenExpiry(data!) == false{
            // Code to hit api for client token by refresh token.
            let clientTokenHeaderRequest = NetworkManager.requestHeaderForClientTokeByUrl(clientTokenServiceURL)
            NetworkManager.requestAuthApi(clientTokenHeaderRequest, completion: { (status, responseData) -> () in
              /*
               * Code to validate the client token api response status true or failse for success and failure.
               * Case true means, get the client token successfully and we need to execute api for parent request by new client token.
               * Case false means, Not able to get the client token by refresh token. May be refresh token is expired due to some other reason like, change password or removed existing refresh token.
               */
              if status == ApiResponseStatusEnum.Success{
                let clientTokenString = UserViewModel.parseClientTokenFormJsonResponse(responseData as! NSData)
                UserViewModel.setClientToken(clientTokenString)
                
                request.setValue(UserViewModel.getClientToken(), forHTTPHeaderField: "clienttoken")
                NetworkManager.recursiveRequestApi(request, completion: { (status, responseData) -> () in
                  /*
                   * Code to validate parent super api endpoint request execution to handle api response either success or failure.
                   * Case true means, parent api get execute succesfully and execute callback with response data.
                   * Case false means, parent api endpoint request execution is failure and then in result call the callback method with nil NSData.
                   */
                  if status == ApiResponseStatusEnum.Success{
                    completion(ApiResponseStatusEnum.Success, responseData)
                  }
                  else{
                    completion(ApiResponseStatusEnum.Failure, data!)
                  }
                })
                
              }
              else{
                var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
                loggedUserDict["username"] = loggedUserDict["username"]
                loggedUserDict["LogInPwd"] = loggedUserDict["LogInPwd"]

                LoginService.authUserWith(loggedUserDict as [String : String], completion: { (status, responseData) -> () in
                  /*
                   * Code to validate logged user credential login service execution to handle api response either success or failure.
                   * Case true means, login service executes successfully and got refresh and client token to execute parent request.
                   * Case false means, parent api endpoint request execution is failure and then in result call the callback method with nil NSData.
                   */
                  if status == ApiResponseStatusEnum.Success{
                    request.setValue(UserViewModel.getClientToken(), forHTTPHeaderField: "clienttoken")
                    NetworkManager.recursiveRequestApi(request, completion: { (status, responseData) -> () in
                      
                      /*
                       * Code to validate parent super api endpoint request execution to handle api response either success or failure.
                       * Case true means, parent api get execute succesfully and execute callback with response data.
                       * Case false means, parent api endpoint request execution is failure and then in result call the callback method with nil NSData.
                       */
                      if status == ApiResponseStatusEnum.Success{
                        completion(ApiResponseStatusEnum.Success, responseData)
                      }
                      else{
                        completion(ApiResponseStatusEnum.Failure, data!)
                      }
                    })
                  }
                  else{
                    completion(ApiResponseStatusEnum.Failure, data!)
                    
                    // Code to update UI in the Main thread and navigate to MVPDashboardViewController.
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                      dispatch_async(dispatch_get_main_queue()) {
                        // Code to set the blank refresh_token value and user dict in user default to logout user status.
                        UserViewModel.setRefreshToken("")
                        UserViewModel.saveUserDictInUserDefault([String: String]())
                        
                        // Code to prepare the instance of application appDelegate method.
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        // Code to re-set rootViewController for the application after logged out user.
                        appDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
                      }
                    }
                    
                  }
                })
              }
            })
            
          }
          else{
            /*
             * Code to Validate Api endpoint response for the success and failure cases.
             * Call method of UtilManager class validateApiForSuccessResponse to validate response NSData on Status key field value resoponse.
             * Compare the response value for the Success and Failure identifier.
             */
            if UtilManager.sharedInstance.validateApiForSuccessResponse(data!){
              // Completion block to execute when api execution succesfully.
              completion(ApiResponseStatusEnum.Success, data!)
            }
            else{
              // Completion block to execute when api execution failuere.
              completion(ApiResponseStatusEnum.Failure, data!)
            }
          }
        }
        else{
          /*
           * Completion block for the failure case of api execution when server is not responsding return diffterent httpResponse code.
           */
          completion(ApiResponseStatusEnum.Failure, data!)
        }
      }
      else{
        /*
         * Completion block for the failure case api execition when server is not working and response we get nil in the response data.
        */
        let respData = NSData()
        completion(ApiResponseStatusEnum.NetworkError, respData)
      }
    })
    task.resume()
    
  }
  
  /*
   * Code to execute the recursive api request of token expiry.
   */
  // MARK:  recursiveRequestApi method.
  class func recursiveRequestApi(request: NSMutableURLRequest, completion: NetworkManagerCompletion){
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      
      if data != nil{
        let httpResponse = response as? NSHTTPURLResponse
        if httpResponse!.statusCode == 201{
          
          /*
           * Code to validate api response data for token expiry or not.
           * If case is the client token is expired and we need to fetch the new client token by the refresh_token
           * Else case for the api success response.
           */
          if NetworkManager.validateApiResponseForClientTokenExpiry(data!) == false{
            completion(ApiResponseStatusEnum.Failure, data!)
          }
          else{
            completion(ApiResponseStatusEnum.Success, data!)
          }
        }
        else{
          completion(ApiResponseStatusEnum.Failure, data!)
        }
      }
      else{
        let respData = NSData()
        completion(ApiResponseStatusEnum.NetworkError, respData)
      }
    })
    task.resume()
  }
  
  
  
  
  
  
  /*
   * Code to convert base access token string into Utf*Encoding Data.
   * Code convert to return base64 encoded string from base64 data.
   */
  // MARK:  getBase64AuthTokenFromTokenString method.
  class func getBase64AuthTokenFromTokenString() -> String{
    let loginData: NSData = baseAccessToken.dataUsingEncoding(NSUTF8StringEncoding)!
    let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
    return base64LoginString
  }
  
  /*
   * validateApiResponseForClientTokenExpiry method validate api endpoint response for the client token expiry.
   * Method will return boolean value.
   */
  // MARK:  validateApiResponseForClientTokenExpiry method.
  class func validateApiResponseForClientTokenExpiry(responseData: NSData) -> Bool{
    var apiResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try apiResponseDict = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }

    var flag = true
    var statusField = ""
    var messageField = ""
    
    if let status = apiResponseDict[STATUS] as? String{
      statusField = status
    }
    if let message = apiResponseDict[MESSAGE] as? String{
      messageField = message
    }
    
    if (statusField == "failure") && (messageField == "failure The client token has expired") {
      flag = false
    }
    
    return flag
  }

}