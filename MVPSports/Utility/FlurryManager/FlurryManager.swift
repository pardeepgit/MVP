//
//  FlurryManager.swift
//  MVPSports
//
//  Created by Chetu India on 07/03/17.
//

import UIKit
import Flurry_iOS_SDK

/*
 * ViewScreensEnum is the custom type enumeration for Screens Type.
 */
enum ViewScreensEnum {
  
  case Dashboard
  case MyMVP
  case MyMVPHealthPointDetail
  case MyMVPRewards
  case MyMVPAccountSetting
  case CheckIn
  case WorkOut
  case CreateWorkOut
  case EditWorkOut
  case ContactUs
  case LeaveFeedback
}



class FlurryManager: NSObject {

  /*
   * Method to design Singleton design pattern for FlurryManager class.
   * Create singleton instance by global and constant variable declaration.
   */
  class var sharedInstance: FlurryManager {
    struct Singleton {
      static let instance = FlurryManager()
    }
    return Singleton.instance
  }

  /*
   * Code to override the default init constructor method with private scope specifier to prevent inilizer outside of the class.
   */
  override private init() {
  }
  
  
  // MARK: -  initializeFlurryWithCredentials method.
  func initializeFlurryWithCredentials() {
    
    // Flurry api and session registration.
    // Flurry.setDebugLogEnabled(true)
    Flurry.startSession(flurryApiKey)
    Flurry.setEventLoggingEnabled(true)
  }
  
  func setFlurryLogForScreenType(screenType: ViewScreensEnum) {
    var logMessage = ""
    
    switch screenType {
    case ViewScreensEnum.Dashboard:
      logMessage = "View Dashboard Screen"
      
    case ViewScreensEnum.MyMVP:
      logMessage = "View MyMVP Screen"
      
    case ViewScreensEnum.MyMVPHealthPointDetail:
      logMessage = "View MyMVPHealthPoint Detail Screen"
      
    case ViewScreensEnum.MyMVPRewards:
      logMessage = "View MyMVP Rewards Screen"
      
    case ViewScreensEnum.MyMVPAccountSetting:
      logMessage = "View MyMVP Account & Setting Screen"
      
    case ViewScreensEnum.CheckIn:
      logMessage = "View CheckIn Screen"
      
    case ViewScreensEnum.WorkOut:
      logMessage = "View WorkOut Screen"
      
    case ViewScreensEnum.CreateWorkOut:
      logMessage = "View Create WorkOut Screen"
      
    case ViewScreensEnum.EditWorkOut:
      logMessage = "View Edit WorkOut Screen"
      
    case ViewScreensEnum.ContactUs:
      logMessage = "View Contact Us Screen"
      
    case ViewScreensEnum.LeaveFeedback:
      logMessage = "View Leave Feedback Screen"
    }
 
    // Code to log event on to flurry api key account.
    Flurry.logEvent(logMessage)
  }

}
