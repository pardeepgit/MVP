//
//  MVPMyMVPRewardPdfViewController.swift
//  MVPSports
//
//  Created by Chetu India on 15/11/16.
//

import UIKit
import PKHUD


class MVPMyMVPRewardPdfViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var webViewRewardPdf: UIWebView!
  
  
  // MARK:  instance variables, constant decalaration and define with some values.
  var pdfUrl = ""
  var urlLoadType = LoadUrlType.Reward
  
  
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      HUD.show(.LabeledProgress(title: "", subtitle: ""))
      
      // Code to call fetchDashboardDataByApiService method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        // Call method to set UI of screen.
        self.preparedScreenDesign()
      })
      
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    RemoteNotificationObserverManager.sharedInstance.delegate = nil
  }

  
  
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    if urlLoadType == LoadUrlType.FullWebSite{
      // Code to call method for the default Site Club WebSite Url.
      self.getDefaultSiteClubWebSiteUrl()
    }
    else{
      // Code to load url in web view.
      self.loadWebViewUrl()
    }
  }
  
  // MARK:  loadWebViewUrl method.
  func loadWebViewUrl() {
    let URL = NSURL(string: self.pdfUrl)
    let pdfUrlRequest = NSMutableURLRequest(URL: URL!)
    self.webViewRewardPdf.delegate = self
    self.webViewRewardPdf.loadRequest(pdfUrlRequest)
  }
  
  
  // MARK:  fetchSiteClubs method.
  func getDefaultSiteClubWebSiteUrl() {
    // Code to initiate input param dictionary to fetch all Site Clubs of application.
    let inputField = [String: String]()
    // Code to execute the getSiteClubsBy api endpoint from SiteClubService class method getSiteClubsBy to fetch all SiteClub of application.
    SiteClubService.getSiteClubsBy(inputField, completion: { (apiStatus, arrayOfSiteClubs) -> () in
      let siteClubArray = arrayOfSiteClubs as! [SiteClub]
      
      var siteId = ""
      let loggedUserStatus = UtilManager.sharedInstance.validateLoggedUserStatus()
      if loggedUserStatus ==  true{
        var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
        if let siteid = loggedUserDict["Siteid"]{
          siteId = siteid as String
        }
      }
      else{
        var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
        if let siteid = unLoggedUserDict["siteId"]{
          siteId = siteid as String
        }
      }
      
      for index in 0 ..< siteClubArray.count {
        let siteClub = siteClubArray[index]
        let clubId = siteClub.clubid
        
        if clubId == siteId{
          self.pdfUrl = siteClub.fullWebSiteUrl!
          break
        }
      }
      
      print(self.pdfUrl)
      // Code to load url in web view.
      self.loadWebViewUrl()

    })
  }

  
  
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }

  
  
  
  // MARK:  showAlerrtDialogueWithTitle method.
  func showAlerrtDialogueWithTitle(title: String, AndErrorMsg errorMessage:String) {
    // create the alert
    let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    // add an action (button)
    alert.addAction(UIAlertAction(title: NSLocalizedString(OKACTION, comment: ""), style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK:  showAlerrtDialogueWithSuccessMessage method.
  func showAlerrtDialogueWithSuccessMessage(message: String) {
    // create the alert
    let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    // add an action (button)
    alert.addAction(UIAlertAction(title: NSLocalizedString(OKACTION, comment: ""), style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  
  // MARK:  Memory management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}


/*
 * Extension of MVPMyMVPRewardPdfViewController to add UIWebView prototcol UIWebViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPRewardPdfViewController.
 */
// MARK:  Extension of MVPMyMVPRewardPdfViewController by UIWebViewDelegate Delegates method.
extension MVPMyMVPRewardPdfViewController: UIWebViewDelegate{
  
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
    return true
  }
  
  func webViewDidStartLoad(webView: UIWebView){    
    if urlLoadType != LoadUrlType.Reward{
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide progress hud.
        HUD.hide(animated: true)
      }
    }
  }
  
  func webViewDidFinishLoad(webView: UIWebView){
    dispatch_async(dispatch_get_main_queue()) {
      // Code to hide progress hud.
      HUD.hide(animated: true)
    }
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
    dispatch_async(dispatch_get_main_queue()) {
      // Code to hide progress hud.
      HUD.hide(animated: true)
    }
  }
  
}


// MARK:  Extension of MVPMyMVPRewardPdfViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPRewardPdfViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

