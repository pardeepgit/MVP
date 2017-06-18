//
//  NotificationClub.swift
//  MVPSports
//
//  Created by Chetu India on 06/09/16.
//

import Foundation


/*
 * ConnectedApp model class declaration with instance veriable declaration for the ConnectedApp model class populate from GetConnectedAppsStatus api endpoint  response.
 */

class ConnectedApp {
  
  var memid: Int?
  
  var appName: String?
  
  var appid: Int?
  
  var status: Bool?
  
  var tokenAuthenticity: Int?
  
  var userid: String?
  
  var memAccessToken: String?
  
  var memRefreshToken: String?

 
  // MARK:  Default constructor.
  init() {
    // perform default initialization here
    
    memid = 0
    appName = ""
    appid = 0
    status = false
    tokenAuthenticity = 0
    userid = ""
    memAccessToken = ""
    memRefreshToken = ""
  }
  
}
