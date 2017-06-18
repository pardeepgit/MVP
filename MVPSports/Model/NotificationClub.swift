//
//  NotificationClub.swift
//  MVPSports
//
//  Created by Chetu India on 06/09/16.
//

import Foundation


/*
 * NotificationClub model class declaration with instance veriable declaration for the NotificationClub model class populate from ClubInfo/GetClubToNotify api endpoint  response.
 */

class NotificationClub {
  
  var memid: String?
  
  var clubid: String?
  
  var clubName: String?
  
  var notificationDate: String?
  
  var isDefaultClub: Bool?
  
  
  // MARK:  Default constructor.
  init() {
    // perform default initialization here
    
    memid = ""
    clubid = ""
    clubName = ""
    notificationDate = "10"
    
    isDefaultClub = false
  }
  
}
