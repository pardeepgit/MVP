
//
//  SiteClub.swift
//  MVPSports
//
//  Created by Chetu India on 26/09/16.
//

import Foundation


/*
  * SiteClub model class declaration with instance veriable declaration for the SiteClub model class populate from ClubInfo/GetClubNames api endpoint  response.
*/

class SiteClub {
  
  var clubid: String?
  
  var clubName: String?
  
  var address: String?
  
  var phone: String?
  
  var email: String?

  var lat: String?

  var lang: String?

  var facebookPageUrl: String?

  var instagramPageUrl: String?

  var twitterPageUrl: String?

  var youtubePageUrl: String?

  var isUserDafault: Bool?

  var fullWebSiteUrl: String?
  
  var operations: String?
  var operations2: String?
  var operations3: String?
  var operations4: String?
  var operations5: String?
  var operations6: String?
  var operations7: String?
  var operations8: String?

  // MARK:  Default constructor.
  init() {
    // perform default initialization here
    
    clubid = ""
    clubName = ""
    address = ""
    phone = ""
    email = ""
    lat = ""
    lang = ""
    facebookPageUrl = ""
    instagramPageUrl = ""
    twitterPageUrl = ""
    youtubePageUrl = ""
    fullWebSiteUrl = ""
    
    isUserDafault = false
    
    operations = ""
    operations2 = ""
    operations3 = ""
    operations4 = ""
    operations5 = ""
    operations6 = ""
    operations7 = ""
    operations8 = ""
  }

}
