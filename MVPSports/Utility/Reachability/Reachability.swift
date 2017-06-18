//
//  Reachability.swift
//  MVPSports
//
//  Created by Chetu India on 27/08/16.
//

import Foundation
import SystemConfiguration

/*
 * Reachability class is used to check internet connection available or not by using the Cocoa Touch SystemConfiguration framework.
 */
public class Reachability {
  
  
  /*
   * isConnectedToNetwork method is used to validate internet network connectivity with the device or not.
   * Method will return true or false on the basis of internet network connectivity.
  */
  // MARK:  isConnectedToNetwork method.
  class func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
      SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    
    // Validating for Cellular and WIFI
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let rechableConnection = (isReachable && !needsConnection)
    return rechableConnection
  }

}