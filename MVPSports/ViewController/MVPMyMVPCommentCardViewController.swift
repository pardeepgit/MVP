//
//  MVPMyMVPCommentCardViewController.swift
//  MVPSports
//
//  Created by Chetu India on 21/10/16.
//

import UIKit
import PKHUD


class MVPMyMVPCommentCardViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var viewCommentCardView: UIView!
  @IBOutlet weak var viewCommentCardViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var textFieldFeedbackEmail: UITextField!
  @IBOutlet weak var labelCommentCardTitleLabel: UILabel!

  @IBOutlet weak var viewFeedbackOptionView: UIView!
  @IBOutlet weak var viewFeedbackOptionViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewFeedbackText: UITextView!
  @IBOutlet weak var buttonSubmit: UIButton!

  @IBOutlet weak var viewFeedbackEmailOptionView: UIView!
  @IBOutlet weak var viewFeedbackEmailOptionViewHeightConstraint: NSLayoutConstraint!

  @IBOutlet weak var tableViewFeedbackOptionTableView: UITableView!
  @IBOutlet weak var buttonFeedbackOptionButton: UIButton!
  @IBOutlet weak var imageViewSelectOptionViewStatusImage: UIImageView!

  @IBOutlet weak var viewSubmittedView: UIView!
  @IBOutlet weak var imageViewWantUsToContactYou: UIImageView!
  @IBOutlet weak var buttonWantUsToContactYou: UIButton!
  var wantUsToContactYouFlag = false

  
  // MARK:  instance variables, constant decalaration and define with some values.
  var arrayOfSelectOptionObject = [[String: AnyObject]]()
  var selectOption = false
  var loggedUserStatus = UtilManager.sharedInstance.validateLoggedUserStatus()
  var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]

  var unLoggedUserSiteId = ""
  var selectOptionIndex = ""
  var timer: NSTimer?
  
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Code to mark log event on to flurry for LeaveFeedback screen view.
    dispatch_async(dispatch_get_main_queue(), {
      FlurryManager.sharedInstance.setFlurryLogForScreenType(ViewScreensEnum.LeaveFeedback)
    })
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()

    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      /*
       * Code to validate arrayOfUserCheckInSiteClubObject have SiteClub or not. If not in that case hit web api endpoint of GetClubToNotify to fetch all NotificationClubs of memeid
       */
      if arrayOfSelectOptionObject.count == 0{
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
        
        // Code to call fetchSelectOptionForCommentCard method after certain one second delay.
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
          self.fetchSelectOptionForCommentCard()
        })
      }
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    // Code to hide Submitted View
    viewSubmittedView.hidden = true
    
    textFieldFeedbackEmail.layer.cornerRadius = VALUETENCORNERRADIUS
    textFieldFeedbackEmail.layer.borderWidth = VALUEONEBORDERWIDTH
    textFieldFeedbackEmail.layer.borderColor = LIGHTGRAYCOLOR.CGColor

    let feedbackEmailPaddingView = UIView(frame: CGRectMake(0, 0, 10, textFieldFeedbackEmail.frame.height))
    textFieldFeedbackEmail.leftView = feedbackEmailPaddingView
    textFieldFeedbackEmail.leftViewMode = UITextFieldViewMode.Always
    
    viewFeedbackOptionView.layer.cornerRadius = VALUETENCORNERRADIUS
    viewFeedbackOptionView.layer.borderWidth = VALUEONEBORDERWIDTH
    viewFeedbackOptionView.layer.borderColor = LIGHTGRAYCOLOR.CGColor
    
    textViewFeedbackText.layer.cornerRadius = VALUEFIVECORNERRADIUS
    textViewFeedbackText.layer.borderWidth = VALUEONEBORDERWIDTH
    textViewFeedbackText.layer.borderColor = LIGHTGRAYCOLOR.CGColor

    buttonSubmit.layer.cornerRadius = VALUEFIFTEENCORNERRADIUS
    buttonSubmit.layer.masksToBounds = true
    
    imageViewWantUsToContactYou.image = UIImage(named: "uncheck")

    /*
     * Code to update view for the logged and unlogged user.
     * Method to update the view constraint height of feedback email and option field view.
    */
    self.setViewForLoggedUnLoggedUser()
  }

  // MARK:  setViewForLoggedUnLoggedUser method.
  func setViewForLoggedUnLoggedUser() {
    labelCommentCardTitleLabel.text = "GIVE US FEEDBACK!"
    if loggedUserStatus == true{ // When user is Logged In
      // labelCommentCardTitleLabel.text = "TELL US WHAT\("\n")YOU THINK!"
      textViewFeedbackText.text = "Enter your comment here."
    }
    else{ // When user is not logged in.
      // labelCommentCardTitleLabel.text = "GIVE US FEEDBACK!"
      textViewFeedbackText.text = "Add a comment..."
    }

    if selectOption == true{ // When Select option is open
      viewFeedbackOptionViewHeightConstraint.constant = 140
      
      tableViewFeedbackOptionTableView.reloadData()
      imageViewSelectOptionViewStatusImage.image = UIImage(named: "black-arrow-up")
      
      if loggedUserStatus == true{ // When user is Logged In
        viewFeedbackEmailOptionViewHeightConstraint.constant =  0
        viewCommentCardViewHeightConstraint.constant = 690
      }
      else{
        viewFeedbackEmailOptionViewHeightConstraint.constant =  40
        viewCommentCardViewHeightConstraint.constant = 730
      }
    }
    else{ // When select option is hidden
      viewFeedbackOptionViewHeightConstraint.constant = 40
      
      tableViewFeedbackOptionTableView.reloadData()
      imageViewSelectOptionViewStatusImage.image = UIImage(named: "black-arrow-down")
      
      if loggedUserStatus == true{ // When user is Logged In
        viewFeedbackEmailOptionViewHeightConstraint.constant =  0
        viewCommentCardViewHeightConstraint.constant = 590
      }
      else{
        viewFeedbackEmailOptionViewHeightConstraint.constant =  40
        viewCommentCardViewHeightConstraint.constant = 630
      }
    }
    
  }

  // MARK:  buttonFeedbackOptionButtonTapped method.
  @IBAction func buttonFeedbackOptionButtonTapped(sender: UIButton){
    if selectOption == true{ // When select Option is option
      selectOption = false
      
      // Code to call setViewForLoggedUnLoggedUser method to update comment card Option view.
      self.setViewForLoggedUnLoggedUser()
    }
    else{ // When select Option is hidden
      selectOption = true
      
      // Code to call setViewForLoggedUnLoggedUser method to update comment card Option view.
      self.setViewForLoggedUnLoggedUser()
    }
  }


  
  
  
  
  
  // MARK:  fetchSelectOptionForCommentCard method.
  func fetchSelectOptionForCommentCard() {
    // Code to initiate input param dictionary to fetch all MemberCommentSelection of Member.
    let inputField = [String: String]()
    
    // Code to execute the MemberCommentSelection api endpoint from SiteClubService class method getCommentCardSelectOptionBy to fetch Member Select Option.
    SiteClubService.getCommentCardSelectOptionBy(inputField, completion: { (apiStatus, arrayOfSelectOptionObject) -> () in
      
      // Code to assign CommentCard Select Option
      self.arrayOfSelectOptionObject = arrayOfSelectOptionObject as! [[String: AnyObject]]
      
      // Code to upate UI in the Main thread when SiteClassesForCheckin api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        HUD.hide(animated: true)
      }
    })
  }
  
  /*
   * Method to validate comment card form, for user status and execute an api endpoint service to submit comment ffedback of user to site club.
   */
  // MARK:  submitCommentCardButtonTapped method.
  @IBAction func submitCommentCardButtonTapped(sender: UIButton){
    self.view.endEditing(true)
    
    let commentCardValidation = self.validateCommentCardFormForUser(loggedUserStatus)
    let validationFlag = commentCardValidation.0
    let title = commentCardValidation.1
    let message = commentCardValidation.2
    
    if validationFlag == true{ // Form is valid
      let requestBodyParam = self.prepareRequestBodyParameterOfSendComment()

      // Code to start loader.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(SENDINGMSG, comment: "")))
      
      // Code to call executeSendCommentApiServiceWith method after certain one second delay.
      let triggerTime = (Int64(NSEC_PER_SEC) * 1)
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
        self.executeSendCommentApiServiceWith(requestBodyParam)
      })
    }
    else{ // Form is invalid
      self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
    }
  }
  
  /*
   * Method to call api method from SendCommentService class to execute SendComment Api endpoint service.
   */
  // MARK:  executeSendCommentApiServiceWith method.
  func executeSendCommentApiServiceWith(inputParam: [String: String]) {
    var apiFlag = false
    var title = ""
    var message = ""

    SendCommentService.sendCommentBy(inputParam, For: loggedUserStatus, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{ // For Api Success
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTAPISUCCESSMSG, comment: "")
      }
      else if status == ApiResponseStatusEnum.Failure{ // For Api Failure
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTAPIERRORMSG, comment: "")
      }
      else{ // For Api Network Error
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      // Code to update loader hide UI in the Main thread and show a alert dialogue of invalid credentials.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide progress hud.
        HUD.hide(animated: true)

        if apiFlag == true{
          // Code to UnHide the Submitted View.
          self.viewSubmittedView.hidden = false
          
          self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(MVPMyMVPCommentCardViewController.callNavigationCrossMethod(_:)), userInfo: ["custom":"data"], repeats: true)
        }
        else{
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
  }
  
  /*
   * Method to prepare request body parameter for api SendComment.
   */
  // MARK:  prepareRequestBodyParameterOfSendComment method.
  func prepareRequestBodyParameterOfSendComment () -> [String: String] {
    var inputParam = [String: String]()
    
    if loggedUserStatus == true{ // For logged user
      // {"comment":"Hello MVPSports!!!","EmailAddress":"abhishekm@chetu.com","IsMember":true,"MemberId":50742014,"siteid":458}
      var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
      
      let commentText = textViewFeedbackText.text as String
      let emailAddress = loggedUserDict["email"]! as String
      let memberId = loggedUserDict["memberId"]! as String
      let siteId = loggedUserDict["Siteid"]! as String
      
      inputParam["comment"] = commentText
      inputParam["EmailAddress"] = emailAddress
      inputParam["IsMember"] = "true"
      inputParam["MemberId"] = memberId
      inputParam["siteid"] = siteId
      inputParam["select"] = selectOptionIndex
    }
    else{ // For unlogged user
      // {"comment":"Hello MVPSports!!!","EmailAddress":"aquibh@chetu.com","IsMember":false,"select":2,"siteid":458}
      let commentText = textViewFeedbackText.text as String
      let emailAddress = textFieldFeedbackEmail.text! as String
      
      inputParam["comment"] = commentText
      inputParam["EmailAddress"] = emailAddress
      inputParam["IsMember"] = "false"
      inputParam["select"] = selectOptionIndex
      
      var unLoggedUserDict = UserViewModel.getUnLoggedUserDictFromUserDefaut() as [String: String]
      if unLoggedUserDict.count > 0{ // Code to validate for un logged user default Site Class already in local .plist DB.
        if let siteid = unLoggedUserDict["siteId"]{
          unLoggedUserSiteId = siteid as String
        }
      }
      
      inputParam["siteid"] = unLoggedUserSiteId
    }

    if wantUsToContactYouFlag == true{
      inputParam["contactyou"] = "1"
    }
    else{
      inputParam["contactyou"] = "0"
    }

    return inputParam
  }
  
  // MARK:  validateCommentCardFormForUser method.
  func validateCommentCardFormForUser(loggedUserFlag: Bool) -> (Bool, String, String) {
    var validationFlag = true
    var title = ""
    var message = ""
    
    if loggedUserFlag == true{ // Validate form for logged user.
      if selectOptionIndex.characters.count == 0{
        validationFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTSELECTOPTIONVALIDATIONMSG, comment: "")
      }
      else if textViewFeedbackText.text.characters.count == 0 || textViewFeedbackText.text == "Enter your comment here."{
        validationFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTVALIDATIONMSG, comment: "")
      }
    }
    else{ // Validate form for unlogged user.
      if selectOptionIndex.characters.count == 0{
        validationFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTSELECTOPTIONVALIDATIONMSG, comment: "")
      }
      else if textViewFeedbackText.text.characters.count == 0 || textViewFeedbackText.text == "Add a comment..."{
        validationFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTVALIDATIONMSG, comment: "")
      }
      else if textFieldFeedbackEmail.text!.characters.count == 0{
        validationFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTEMAILVALIDATIONMSG, comment: "")
      }
      else if !UtilManager.sharedInstance.isValidEmail(textFieldFeedbackEmail.text!){
        validationFlag = false
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = NSLocalizedString(SENDCOMMENTVALIDEMAILVALIDATIONMSG, comment: "")
      }
    }
    
    return (validationFlag, title, message)
  }
  

  
  
  
  
  // MARK:  callNavigationCrossMethod method.
  func callNavigationCrossMethod(timerRef: NSTimer!) {
    if (timer != nil){
      timer!.invalidate()
      self.crossButtonTapped(UIButton())
    }
  }
  
  // MARK:  crossButtonTapped method.
  @IBAction func crossButtonTapped(sender: UIButton){
    if (timer != nil){
      timer?.invalidate()
    }
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  buttonWantUsToContactYouTapped method.
  @IBAction func buttonWantUsToContactYouTapped(sender: UIButton){
    if wantUsToContactYouFlag == true{
      wantUsToContactYouFlag = false
      imageViewWantUsToContactYou.image = UIImage(named: "uncheck")
    }
    else{
      wantUsToContactYouFlag = true
      imageViewWantUsToContactYou.image = UIImage(named: "check")
    }
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

  // MARK:  Memoey management method.
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}



/*
 * Extension of MVPMyMVPCommentCardViewController to add UITextView prototcol UITextViewDelegate method.
 * Override the protocol method to add textViewNote in MVPMyMVPCommentCardViewController.
 */
// MARK:  Extension of MVPMyMVPCommentCardViewController by UIPickerView DataSource & Delegates method.
extension MVPMyMVPCommentCardViewController: UITextViewDelegate{
  
  func textViewDidBeginEditing(textView: UITextView) {
    if loggedUserStatus == true{ // For logged user
      if textView.text == "Enter your comment here." {
        textView.text = ""
      }
    }
    else{ // For UnLogged user.
      if textView.text == "Add a comment..." {
        textView.text = ""
      }
    }
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    if loggedUserStatus == true{ // For logged user
      if textView.text.isEmpty {
        textView.text = "Enter your comment here."
      }
    }
    else{ // For UnLogged user.
      if textView.text.isEmpty {
        textView.text = "Add a comment..."
      }
    }
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    // Combine the textView text and the replacement text to
    // Create the updated text string
    let currentText:NSString = textView.text
    let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
    
    // If updated text view will be empty, add the placeholder
    // and set the cursor to the beginning of the text view
    if updatedText.isEmpty {
      if loggedUserStatus == true{ // For logged user
        textView.text = "Enter your comment here."
      }
      else{
        textView.text = "Add a comment..."
      }
      textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
      return false
    }
      
      // Else if the text view's placeholder is showing and the
      // length of the replacement string is greater than 0, clear
      // the text view and set its color to black to prepare for
      // the user's entry
    else if loggedUserStatus == false && textView.text == "Add a comment..." && !text.isEmpty {
      textView.text = nil
      textView.textColor = BLACKCOLOR
    }
    else if loggedUserStatus == true && textView.text == "Enter your comment here." && !text.isEmpty {
      textView.text = nil
      textView.textColor = BLACKCOLOR
    }
    else if text == "\n"{
      textView.resignFirstResponder()
      return false
    }
    
    return true
  }
  
}


/*
 * Extension of MVPMyMVPCommentCardViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPCommentCardViewController.
 */
// MARK:  Extension of MVPMyMVPCommentCardViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPCommentCardViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return arrayOfSelectOptionObject.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 40.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPCommentCardSelectOptionTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPCOMMENTCARDSELECTOPTIONTABLEVIEWCELL) as? MyMVPCommentCardSelectOptionTableViewCell!)!
    
    let selectOption = arrayOfSelectOptionObject[indexPath.row] as [String: AnyObject]
    if let name = selectOption["name"]{
      cell.labelSelectOption.text = "    \(name as! String)"
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewFeedbackOptionTableView.reloadData()

    let selectOptionObject = arrayOfSelectOptionObject[indexPath.row] as [String: AnyObject]
    if let name = selectOptionObject["name"]{
      buttonFeedbackOptionButton.setTitle("    \(name as! String)", forState: UIControlState.Normal)
    }

    if let index = selectOptionObject["index"]{
      selectOptionIndex = "\(index as! Int)"
    }

    selectOption = false
    // Code to call setViewForLoggedUnLoggedUser method to update comment card Option view.
    self.setViewForLoggedUnLoggedUser()

  }
  
}

// MARK:  Extension of MVPMyMVPCommentCardViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPCommentCardViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

