//
//  AccountInfoViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 31/08/16.
//

import Foundation


/*
 * AccountInfoTypeEnumeration is an enumeration of raw type is string.
 * Enumeration infer the type of Account Info sub module by the cases of enum.
 */
enum AccountInfoTypeEnumeration: String {
  
  case AccountSummary = "Summary"
  case ContactInformation = "Contact Information"
  case ChangeUsernamePassword = "Change Username/Password"
  case StatementsTransaction = "Statements/Transaction"
  case UpdateCreditCard = "Update Credit Card on File"
  case ViewHistory = "View History"
  case ConnectedAppsAccounts = "Connected Apps / Accounts"
  case Notifications = "Settings"
}


/*
 * AccountInfoViewModel class with class method declaration and defination implementaion to handle functionality of MVPMyMVPAccountInfoViewController viewController class.
 *
 */
class AccountInfoViewModel {

  
  // MARK:  parseAccountLinksResponse method.
  class func parseAccountLinksResponse(accountLinksResponseData: NSData) -> [String: String] {
    var accountLinksDict = [String: String]()
    var accountLinksResponseDict = [String:AnyObject]()

    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try accountLinksResponseDict = (NSJSONSerialization.JSONObjectWithData(accountLinksResponseData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    if let status = accountLinksResponseDict[STATUS] as? String{
      if status == SUCCESS {
        if let arrayOfAccountLinksDict = accountLinksResponseDict[RESPONSE] as? [String]{
          /*
           * Code to filter account link string to get key value string to insert into dictionary to prepare account links dictionary.
           */
          for index in 0..<arrayOfAccountLinksDict.count {
            let accountLinkString = arrayOfAccountLinksDict[index] as String
            
            let accountKeyStartRange = accountLinkString.rangeOfString("\"",
                                                                       options: NSStringCompareOptions.LiteralSearch,
                                                                       range: accountLinkString.startIndex..<accountLinkString.endIndex,
                                                                       locale: nil)
            let accountKeyEndRange = accountLinkString.rangeOfString("\":\"",
                                                                     options: NSStringCompareOptions.LiteralSearch,
                                                                     range: accountLinkString.startIndex..<accountLinkString.endIndex,
                                                                     locale: nil)
            let key = accountLinkString [(accountKeyStartRange!.startIndex.advancedBy(1))..<accountKeyEndRange!.startIndex]
            let value = accountLinkString [accountKeyEndRange!.startIndex.advancedBy(3)..<accountLinkString.endIndex.advancedBy(-1)]
            accountLinksDict[key] = value
          }
        }
      }
    }
    
    return accountLinksDict
  }
  
}