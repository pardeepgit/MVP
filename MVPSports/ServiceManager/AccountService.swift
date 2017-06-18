//
//  AccountService.swift
//  MVPSports
//
//  Created by Chetu India on 12/09/16.
//

import Foundation


// AccountServiceCompletion declare callback for AccountService class method with parameter.
typealias AccountServiceCompletion = (ApiResponseStatusEnum, [String: String]) -> ()


/*
 * AccountService class with class method declaration and defination implementaion to handle functionality of logged user Account api endpoint.
 */
class AccountService {

  
  // MARK:  getMyAccountSourceBy method.
  class func getMyAccountLinksBy(inputFields: [ String: String], completion: AccountServiceCompletion) {
    // Code to create NSMutableURLRequest object for header of GetAccountLinks.
    let request = NetworkManager.requestHeaderForApiByUrl(accountLinksServiceURL)
    
    do {
      // Code to serialized input dictionary object into json NSData object to add into request httpBody by NSJSONSerialization class method dataWithJSONObject.
      let jsonData = try NSJSONSerialization.dataWithJSONObject(inputFields, options: .PrettyPrinted)
      request.HTTPBody = jsonData
    }
    catch let error as NSError {
      print(error)
    }
    
    // Code to hit web api request header to GetAccountLinks.
    NetworkManager.requestApi(request, completion: { (status, responseData) -> () in
//      let responseJsonString = NSString(data: responseData as! NSData, encoding: NSUTF8StringEncoding)  as! String
//      print("Response json is :\n\(responseJsonString)")

      if status == ApiResponseStatusEnum.Success{
        let accountLinksDict = AccountInfoViewModel.parseAccountLinksResponse(responseData as! NSData)
        completion(status, accountLinksDict)
      }
      else{
        let accountLinksDict = [String: String]()
        completion(status, accountLinksDict)
      }
    })
  }

}
