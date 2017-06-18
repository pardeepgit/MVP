//
//  MVPMyMVPAccountLinksViewController.swift
//  MVPSports
//
//  Created by Chetu India on 10/09/16.
//

import UIKit
import PKHUD


class MVPMyMVPAccountLinksViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var webViewAccountLink: UIWebView!
  
  
  // MARK:  instance variables, constant decalaration and define with some values.
  var accountLinkUrlString = ""

  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    print(accountLinkUrlString)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self

    // Call method to set UI of screen.
    self.preparedScreenDesign()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    // Code to show progress loader.
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))

    // Code to initiate the load url request.
    let url = NSURL (string: accountLinkUrlString)
    let request = NSMutableURLRequest(URL: url!);
    request.setValue(NSString(format: "Basic %@", NetworkManager.getBase64AuthTokenFromTokenString()) as String, forHTTPHeaderField: "Authorization")
    request.setValue(UserViewModel.getClientToken(), forHTTPHeaderField: "clienttoken")
    webViewAccountLink.loadRequest(request)
  }
  

  
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  // MARK:  Memoey management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}


/*
 * Extension of MVPMyMVPAccountLinksViewController to add UIWebView prototcol UIWebViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPAccountLinksViewController.
 */
// MARK:  Extension of MVPMyMVPAccountLinksViewController by UIWebViewDelegate Delegates method.
extension MVPMyMVPAccountLinksViewController: UIWebViewDelegate{
  
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
    return true
  }
  
  func webViewDidStartLoad(webView: UIWebView){
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

// MARK:  Extension of MVPMyMVPAccountLinksViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPAccountLinksViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

