//
//  ExerciseClass.swift
//  MVPSports
//
//  Created by Chetu India on 22/08/16.
//

import Foundation


/*
 * ExerciseClass model class declaration with instance veriable declaration for the ExerciseClass model class populate from Classes/SiteClasses api endpoint  response.
 */

class ExerciseClass {

  var classid: String?

  var siteid: String?

  var className: String?
  
  var classDescription: String?

  var classStartTime: String?
  
  var classEndTime: String?

  var classLocation: String?
  
  var classInstructor: String?
  
  var classInstructorId: String?

  var classInstructorImage: String?

  var checkedId: String?

  var userFavourite: Bool?

  var userCheckIn: Bool?

  var classInstructorAvailable: Bool?

  // MARK:  Default constructor.
  init() {
    // perform default initialization here
    
    classid = ""
    siteid = ""
    className = ""
    classStartTime = ""
    classEndTime = ""
    classLocation = ""
    classInstructor = ""
    classInstructorId = ""
    classInstructorImage = ""
    classDescription = ""
    checkedId = ""
    
    userFavourite = false
    userCheckIn = false
    classInstructorAvailable = false
  }
  
}