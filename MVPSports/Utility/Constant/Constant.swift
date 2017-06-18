//
//  Constant.swift
//  MVPSports
//
//  Created by Chetu India on 08/09/16.
//

import Foundation

/*
  * Global declaration of ....
  * Api endpoint base url and basic authorization access token.
 */
let apiBaseUrl = "https://team.mvpsportsclubs.com/restful/mvp/"
let baseAccessToken = "ypN0/BhwPDhmdC/KdbT+oRTYeL+/t9jK0jae4ttjZ6C+/ken4nL1txoI3SQoKpp84Uvzt6hK87RlqDCY0sAxXPZqM2GQf9uMEQvxbzEleoK4D802U2XyEdJ+9ARP3M4q:_&garfinkle8898"

let flurryApiKey = "23DXBC8ZV372VGVKMXGH"


/*
  * Global declaration of ....
  * Login Service api endpoint url.
 */
let loginAuthServiceURL = "\(apiBaseUrl)member/login"
let clientTokenServiceURL = "\(apiBaseUrl)member/RequestClientToken"
let sendPasswordServiceURL = "\(apiBaseUrl)member/SendPassword"
let findMemberByIdServiceURL = "\(apiBaseUrl)member/FindMemberById"

/*
 * Global declaration of ....
 * GetRewards Service api endpoint url.
 */
let rewardServiceURL = "\(apiBaseUrl)MemberRewards/GetRewards"
let sendShowRewardToFriendEmailServiceURL = "\(apiBaseUrl)MemberRewards/SendShowRewardToFriendEmail"
let getHealthPointLevelsServiceURL = "\(apiBaseUrl)MemberHealthPoints/GetHealthPointLevels"
let getMemberHealthPointServiceURL = "\(apiBaseUrl)MemberHealthPoints/GetHealthPoint"
let getUserOptInStatusServiceURL = "\(apiBaseUrl)MemberHealthPoints/GetOptIn"
let getUserPunchCardServiceURL = "\(apiBaseUrl)Classes/GetPunchCard"


/*
 * Global declaration of ....
 * GetAccountLinks Service api endpoint url.
 */
let accountLinksServiceURL = "\(apiBaseUrl)AccountLinks/GetAccountLinks"


/*
 * Global declaration of ....
 * Notification Service api endpoint url.
 */
let getClubToNotifyServiceURL = "\(apiBaseUrl)ClubInfo/GetClubToNotify"
let setClubToNotifyServiceURL = "\(apiBaseUrl)ClubInfo/SetClubToNotify"
let getClubNamesServiceURL = "\(apiBaseUrl)ClubInfo/GetClubNames"
let getConnectedAppsServiceURL = "\(apiBaseUrl)Apps/GetDeviceSetting"
let saveDeviceSettingServiceURL = "\(apiBaseUrl)Apps/SaveDeviceSetting"




/*
 * Global declaration of ....
 * UserCheckInSiteClasses Service api endpoint url.
 */
let getUserSiteClubCheckInStatusServiceURL = "\(apiBaseUrl)Classes/GetIsCheckedIn"
let getUserCheckInSiteClassesServiceURL = "\(apiBaseUrl)Classes/SiteClassesForCheckin"
let getCheckedInSiteClassesServiceURL = "\(apiBaseUrl)Classes/CheckedInClasses"
let markUserCheckInSiteClassServiceURL = "\(apiBaseUrl)Classes/InsertClassCheckIn"
let deleteClassCheckedInServiceURL = "\(apiBaseUrl)Classes/DeleteClassCheckIn"


/*
 * Global declaration of ....
 * SiteClubs Service api endpoint url.
 */
let getSiteClubServiceURL = "\(apiBaseUrl)ClubInfo/GetClubNames"
let getDefaultSiteClubServiceURL = "\(apiBaseUrl)ClubInfo/GetDefaultSite"
let setDefaultSiteClubServiceURL = "\(apiBaseUrl)ClubInfo/SetDefaultSite"
let getSiteClubTrainerInfoServiceURL = "\(apiBaseUrl)Classes/GetTrainerInfo"
let getCommentCardSelectOptionServiceURL = "\(apiBaseUrl)Member/MemberCommentSelection"



/*
 * Global declaration of ....
 * SiteClasses Service api endpoint url.
 */
let exerciseClassServiceURL = "\(apiBaseUrl)classes/SiteClasses"
let exerciseClassForInstructorActivityServiceURL = "\(apiBaseUrl)Classes/GetClassesByClassOrInstructor"
let favouriteSiteClassesServiceURL = "\(apiBaseUrl)Classes/GetFavoriteClasses"
let setFavouriteSiteClassServiceURL = "\(apiBaseUrl)Classes/SetFavorites"
let setUnFavouriteSiteClassServiceURL = "\(apiBaseUrl)Classes/RemoveFavorite"
let siteClassDescriptionServiceURL = "\(apiBaseUrl)Classes/GetClassDescriptions"



/*
 * Global declaration of ....
 * WorkOut Service api endpoint url.
 */
let getWorkOutsServiceURL = "\(apiBaseUrl)WorkOut/GetWorkOuts"
let saveWorkOutsServiceURL = "\(apiBaseUrl)WorkOut/SaveWorkOut"
let editWorkOutsServiceURL = "\(apiBaseUrl)WorkOut/EditWorkOut"
let deleteWorkOutsServiceURL = "\(apiBaseUrl)WorkOut/DeleteWorkOut"
let editManualWorkOutsServiceURL = "\(apiBaseUrl)WorkOut/EditManualWorkOut"
let genericEditWorkOutsServiceURL = "\(apiBaseUrl)Workout/SaveWorkOutEx"



/*
 * Global declaration of ....
 * SendComment Service api endpoint url.
 */
let memberSendCommentServiceURL = "\(apiBaseUrl)Member/MemberSendComment"
let visitorSendCommentServiceURL = "\(apiBaseUrl)Member/VisitorSendComment"


/*
 * Global declaration of ....
 * Announcement module Service api endpoint url.
 */
let setMemberMobileTokenServiceURL = "\(apiBaseUrl)Notification/SetMemberMobileToken"
let setZeroNotificationCountServiceURL = "\(apiBaseUrl)Apps/ZeroNotificationCount"
let announcementNotificationServiceURL = "\(apiBaseUrl)Notification/GetClubNotification"
let deleteNotificationServiceURL = "\(apiBaseUrl)Notification/DeleteIndivualNotification"




/*
 * Global declaration of ......
 * Static web page urls ......
 */
let purchasePunchCardPageURL = "https://registration.mvpsportsclubs.com/Login.aspx?page=PurchasePunchCard&SITE=";
let optInPageURL = "https://registration.mvpsportsclubs.com/Login.aspx?page=OptIn&SITE=";
let healthPointPageURL = "https://registration.mvpsportsclubs.com/Login.aspx?page=HealthPoints&SITE=";
let connectedAppsHelpPageURL = "https://registration.mvpsportsclubs.com/Login.aspx?page=ConnectedApps&SITE=";

let instructorProfileThumbnailImageURL = "https://registration.mvpsportsclubs.com/InstructorPicture.aspx?instructorid=";
let instructorProfileThumbnailImageSize = "&maxwidth=100&maxheight=100";

let FullWebsitePageURL = "http://www.mvpsportsclubs.com/blog/"
let FitFreshBlogPageURL = "http://www.mvpsportsclubs.com/blog/"

let CreateAccountPageURL = "https://registration.mvpsportsclubs.com/CreateAccount.aspx?SITE=1"
let NotAMemberPageURL = "https://registration.mvpsportsclubs.com/CreateAccount.aspx?SITE=1"



/*
 * RGB color code status identifier.
 */
let SendRewardStatusColor = UIColor(red: 24/255.0, green: 182/255.0, blue: 119/255.0, alpha: 1.0)
let SentRewardStatusColor = UIColor(red: 112/255.0, green: 166/255.0, blue: 144/255.0, alpha: 1.0)
let HpFilledStatusColor = UIColor(red: 20/255.0, green: 125/255.0, blue: 186/255.0, alpha: 1.0)

/*
 * RGB color code status identifier.
 */
let UnSelectSiteClassTypeBackgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
let selectSiteClassSectionTitleBackgroundColor = UIColor(red: 8/255.0, green: 49/255.0, blue: 73/255.0, alpha: 1.0)

/*
 * RGB color code for used and un used punch card session.
 */
let UsedPunchCardSessionFilledColor = UIColor(red: 24/255.0, green: 182/255.0, blue: 119/255.0, alpha: 1.0)
let UnUsedPunchCardSessionFilledColor = UIColor(red: 226/255.0, green: 224/255.0, blue: 226/255.0, alpha: 1.0)


/*
 * UItextField placeholder text identifiers.
 */
let FriendEmailFieldIdentifier = "Enter Friend Email."


/*
 * Connected Apps static appid value for Fitbit, UnderArmour and Polar.
 */
let FITBITAPPID = 1
let POLARAPPID = 2
let UNDERARMOURAPPID = 5

/*
 * ConnectedAppTypesEnum is an enumeration of Connected App types.
 */
enum ConnectedAppTypesEnum {
  case Fitbit
  case Polar
  case UnderArmour
}



/*
 *
 *
 */
enum ApiResponseStatusEnum {
  case Success
  case Failure
  case NetworkError
  case ClientTokenExpiry
}

enum UserOptInStatusEnum {
  case DefaultUpChart
  case HpChart
  case OptInView
  case PunchCardSession
  case HideHpView
}




/*
 * Code for the device check whether it is iPhone varient or iPad varient.
 * For iPhone devices varient iPhone4, 5, 6, 6P and iPad device varient iPad and iPad_Pro
 * Device check by the device screen size height and width.
*/
enum UIUserInterfaceIdiom : Int{
  case Unspecified
  case Phone
  case Pad
}

struct ScreenSize{
  static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
  static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
  static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType{
  static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
  static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
  static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
  static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
  static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
  static let IS_IPAD_PRO          = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

