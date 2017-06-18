//
//  SendCommentService.swift
//  MVPSports
//
//  Created by Chetu India on 03/11/16.
//

import Foundation


// SendCommentServiceCompletion declare callback for SendCommentService class method with parameter.
typealias SendCommentServiceCompletion = (ApiResponseStatusEnum, AnyObject) -> ()


class SendCommentService {
  
  // MARK:  sendCommentBy method.
  class func sendCommentBy(inputFields: [ String: String], For loggedUser: Bool, completion: SendCommentServiceCompletion) {
    var apiUrlAddress = ""
    if loggedUser == true{
      apiUrlAddress = memberSendCommentServiceURL
    }
    else{
      apiUrlAddress = visitorSendCommentServiceURL
    }
    
    // Code to create NSMutableURLRequest object for header of deleteClassCheckedInServiceURL.
    let request = NetworkManager.requestHeaderForApiByUrl(apiUrlAddress)
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
      let sendCommentResponseJsonString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
      print("Response json is :\n\(sendCommentResponseJsonString)")

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