//
//  ConnectedAppsViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 01/09/16.
//

import Foundation


/*
 * ConnectedAppsType is an enumeration.
 * Enumeration infer the type of Account Info sub module by the cases of enum.
 */
enum ConnectedAppsType: String {
  
  case FitBit
  case Polar
  case UnderArmour
}


/*
 * ConnectedAppsViewModel class with class method declaration and defination implementaion to handle functionality of MVPMyMVPConnectedAppsViewController viewController class.
 *
 */
class ConnectedAppsViewModel {
  
  
  /*
   * parseConnectedAppsResponseData method to parse.
   */
  // MARK:  parseConnectedAppsResponseData method.
  class func parseConnectedAppsResponseData(responseData: NSData, type: ConnectedAppsType) -> [String: String] {
    var connectedAppResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try connectedAppResponseDict = (NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var connectedApp = [String: String]()
    if connectedAppResponseDict.count > 0{
      
      if type == ConnectedAppsType.Polar{
        if let x_user_id = connectedAppResponseDict["x_user_id"] as? Int{
          connectedApp["userid"] = "\(x_user_id)"
        }
        else{
          connectedApp["userid"] = ""
        }
        if let access_token = connectedAppResponseDict["access_token"] as? String{
          connectedApp["MemAccessToken"] = access_token
        }
        else{
          connectedApp["MemAccessToken"] = ""
        }
        if let expires_in = connectedAppResponseDict["expires_in"] as? Int{
          connectedApp["MemRefreshToken"] = "\(expires_in)"
        }
        else{
          connectedApp["MemRefreshToken"] = ""
        }
      }
      else{
        
        if let user_id = connectedAppResponseDict["user_id"] as? String{
          connectedApp["userid"] = user_id
        }
        else{
          connectedApp["userid"] = ""
        }
        if let access_token = connectedAppResponseDict["access_token"] as? String{
          connectedApp["MemAccessToken"] = access_token
        }
        else{
          connectedApp["MemAccessToken"] = ""
        }
        if let refresh_token = connectedAppResponseDict["refresh_token"] as? String{
          connectedApp["MemRefreshToken"] = refresh_token
        }
        else{
          connectedApp["MemRefreshToken"] = ""
        }
      }
      
    }

    return connectedApp
  }
  
}