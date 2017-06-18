//
//  RemoteNotificationObserverManager.swift
//  BroadcastReceiver
//
//  Created by Pardeep Kumar on 31/01/2017.
//  Copyright © 2017 Pardeep Kumar. All rights reserved.
//

import UIKit

@objc protocol RemoteNotificationObserverDelegate {

  @objc optional func announcementDelegate()
  @objc optional func badgeCountDelegate()
}


class RemoteNotificationObserverManager: NSObject {

  static let sharedInstance = RemoteNotificationObserverManager()
  weak var delegate: RemoteNotificationObserverDelegate?
  
  private override init() {
  }
  
  // MARK:  remoteNotificationHandlerBy method.
  func remoteNotificationHandlerBy(notificationObject: [String: String]) {
    
    if let identifer = notificationObject["identifier"]{
      if identifer == "NavigateToAnnouncementScreen"{
        
        // Code to navigate to Announcement screen on receive notification.
        if delegate != nil{
          delegate?.announcementDelegate?()
        }
      }
      else if identifer == "UpdateAlertNotificationBadgeCount"{
        // Code to navigate to Announcement screen on receive notification.
        if delegate != nil{
          delegate?.badgeCountDelegate?()
        }
      }
    }
  }

}
