//
//  AlertDialogueManager.swift
//  MVPSports
//
//  Created by Chetu India on 09/08/16.
//

import UIKit

class AlertDialogueManager: NSObject {

    /*
     * Method to design Singleton design pattern for AlertDialogueManager class.
     * Create singleton instance by global and constant variable declaration.
     */
    class var sharedInstance: AlertDialogueManager {
        struct Singleton {
            static let instance = AlertDialogueManager()
        }
        return Singleton.instance
    }
    
}
