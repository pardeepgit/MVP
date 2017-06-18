//
//  Reward.swift
//  MVPSports
//
//  Created by Chetu India on 18/08/16.
//

import Foundation


/*
 * Reward model class declaration with instance veriable declaration for the Reward model class populate from GetRewards api response.
 */
class Reward {
  
  var memid: String?

  var rewardId: String?

  var name: String?
  
  var desc: String?
  
  var status: String?
  
  var emailto: Bool?
  
  var requestedDate: String?
  
  var expirationDate: String?
  
  var friendsEmail: String?
  
  var copyMeOnEmail: Bool?
  
  var pdfUrl: String?
  
  
  // MARK:  Default constructor.
  init() {
    // perform default initialization here
    
    memid = ""
    rewardId = ""
    name = ""
    desc = ""
    status = ""
    requestedDate = ""
    expirationDate = ""
    friendsEmail = ""
    pdfUrl = ""
    
    emailto = false
    copyMeOnEmail = false
  }
  
}