//
//  User.swift
//  MVPSports
//
//  Created by Chetu India on 18/08/16.
//

import Foundation


/*
 * User model class declaration with instance veriable declaration for the User model class populate from LoginService api response.
 */
class User {
  
  var memberId: String?
  
  var firstName: String?
  
  var token: String?
  
  var memberShipDesc: String?
  
  var email: String?
  
  var memberNumber: String?
  
  var joinDate: String?
  
  var age: String?
  
  var siteName: String?
  
  
  // MARK:  Default constructor.
  init() {
    // perform default initialization here
    
    memberId = ""
    firstName = ""
    token = ""
    memberShipDesc = ""
    email = ""
    memberNumber = ""
    joinDate = ""
    age = ""
    siteName = ""
  }
  
}