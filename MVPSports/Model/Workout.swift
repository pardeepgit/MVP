//
//  Workout.swift
//  MVPSports
//
//  Created by Chetu India on 28/09/16.
//

import Foundation


/*
 * WorkoutClass model class declaration with instance veriable declaration for the WorkoutClass model class populate from WorkOut/GetWorkOuts api endpoint  response.
 */

class Workout {
  
  var workoutid: Int?

  var machinetype: Int?
  
  var steps: Int?
  
  var distance: Float?
  
  var type: String?

  var note: String?
  
  var Name: String?
  
  var instructorName: String?
  
  var datecreated: String?
  
  var duration: Int?
  
  var calories: Int?
  
  
  // MARK:  Default constructor.
  init() {
    // perform default initialization here
    
    workoutid = 0
    machinetype = 0
    steps = 0
    distance = 0.0
    type = ""
    note = ""
    Name = ""
    instructorName = ""
    datecreated = ""
    duration = 0
    calories = 0
  }

}