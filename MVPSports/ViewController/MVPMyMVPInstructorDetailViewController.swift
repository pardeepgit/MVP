//
//  MVPMyMVPInstructorDetailViewController.swift
//  MVPSports
//
//  Created by Chetu India on 20/10/16.
//

import UIKit
import PKHUD


class MVPMyMVPInstructorDetailViewController: UIViewController {
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var viewInstructorDetailView: UIView!
  @IBOutlet weak var tableViewInstructorDetailTableView: UITableView!
  @IBOutlet weak var labelInstructorNameLabel: UILabel!
  @IBOutlet weak var labelInstructorTitleLabel: UILabel!
  @IBOutlet weak var labelInstructorQuoteLabel: UILabel!
  @IBOutlet weak var imageViewInstructorProfile: UIImageView!
  @IBOutlet weak var labelInstructorQuoteHeightConstraint: NSLayoutConstraint!

  // MARK:  instance variables, constant decalaration and define with some values.
  var apiResponseFlag = false
  var selectedInstructorId = ""
  var selectedInstructorName = ""  
  var selectedInstructor = [String: AnyObject]()
  var instructorDetailDictArray = [[String: String]]()
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self

    
    // Code to check device is connected to internet connection or not.
    if Reachability.isConnectedToNetwork() == true {
      // Code to execute web api endpoint services of Classes/GetTrainerInfo to fetch instructor detail information of siteclub.
      HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(LOADINGMSG, comment: "")))
      self.fetchSiteClubInstructorDetail()
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(NOINTERNETCONNECTIONTITLE, comment: ""), AndErrorMsg: NSLocalizedString(NOINTERNETCONNECTIONMSG, comment: ""))
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  
  
  // MARK:  preparedScreenDesign method.
  func  preparedScreenDesign() {
    if apiResponseFlag == true{
      // Code to UnHide viewInstructorDetailView view.
      viewInstructorDetailView.hidden = false
      
      // Code to get Instructor Title and Quote from instructor detail api.
      var instructorTitle = ""
      var instructorQuote = ""
      var instructorImageString = ""
      if let title = selectedInstructor["Title"] as? String{
        instructorTitle = title
      }
      if let quote = selectedInstructor["quote"] as? String{
        instructorQuote = quote
      }
      if let imgPath = selectedInstructor["ImgPath"] as? String{
        instructorImageString = imgPath
      }
      
      // Code to set UI label value for instructor and instructor image.
      labelInstructorNameLabel.text = selectedInstructorName.uppercaseString
      labelInstructorTitleLabel.text = instructorTitle.uppercaseString
      if instructorImageString.characters.count > 0{
        let decodedData = NSData(base64EncodedString: instructorImageString, options: NSDataBase64DecodingOptions(rawValue: 0))
        let decodedimage = UIImage(data: decodedData!)
        imageViewInstructorProfile.image = decodedimage! as UIImage
      }

      // Code for the Instructor Quote label.
      if instructorQuote.characters.count > 0{
        labelInstructorQuoteLabel.text = instructorQuote
        let labelFont = self.labelInstructorQuoteLabel.font
        let labelWidth = self.view.frame.size.width - 40
        let labelHeight = UtilManager.sharedInstance.heightForLabel(instructorQuote, font: labelFont, width: labelWidth)
        self.labelInstructorQuoteHeightConstraint.constant = labelHeight + 5
      }
      else{
        labelInstructorQuoteHeightConstraint.constant = 0.0
      }
      
      // Code to call method for prepare instructor detail information.
      self.prepareInstructorDetailInformation()
    }
    else{
      viewInstructorDetailView.hidden = true
    }
  }
  
  // MARK:  prepareInstructorDetailInformation method.
  func prepareInstructorDetailInformation() {
    if let word = selectedInstructor["word"] as? String{
      if word.characters.count > 0{
        var dict = [String: String]()
        dict["key"] = "ONE WORD TO DESCRIBE ME"
        dict["value"] = word
        instructorDetailDictArray.append(dict)
      }
    }
    if let song = selectedInstructor["song"] as? String{
      if song.characters.count > 0{
        var dict = [String: String]()
        dict["key"] = "FAVORITE SONG"
        dict["value"] = song
        instructorDetailDictArray.append(dict)
      }
    }
    if let favoriteclass = selectedInstructor["favoriteclass"] as? String{
      if favoriteclass.characters.count > 0{
        var dict = [String: String]()
        dict["key"] = "FAVORITE CLASS"
        dict["value"] = favoriteclass
        instructorDetailDictArray.append(dict)
      }
    }
    if let motivated = selectedInstructor["motivated"] as? String{
      if motivated.characters.count > 0{
        var dict = [String: String]()
        dict["key"] = "WHAT GETS ME MOTIVATED"
        dict["value"] = motivated
        instructorDetailDictArray.append(dict)
      }
    }
    if let findme = selectedInstructor["findme"] as? String{
      if findme.characters.count > 0{
        var dict = [String: String]()
        dict["key"] = "YOU CAN FIND ME"
        dict["value"] = findme
        instructorDetailDictArray.append(dict)
      }
    }
    
    // Code to call UITableView reload method to notify table view.
    tableViewInstructorDetailTableView.reloadData()
  }
  
  

  
  // MARK:  fetchSiteClubInstructorDetail method.
  func fetchSiteClubInstructorDetail() {
    // Code to initiate input param dictionary to execute api endpoinr service of Classes/GetTrainerInfo.
    var inputField = [String: String]()
    inputField["instructorid"] = selectedInstructorId
    
    var title = ""
    var message = ""

    SiteClubService.getSiteClubInstructorBy(inputField, completion: { (status, responseData) -> () in
      if status == ApiResponseStatusEnum.Success{
        self.apiResponseFlag = true

        // Code to parse GetTrainerInfo api response.
        let arrayOfInstructorDetailObjects = SiteClubsViewModel.parseSiteClubTrainerInstructorInfoResponseData(responseData as! NSData)
        if arrayOfInstructorDetailObjects.count > 0{
          self.selectedInstructor = arrayOfInstructorDetailObjects[0]
        }
      }
      else if status == ApiResponseStatusEnum.Failure{
        title = NSLocalizedString(ALERTTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else if status == ApiResponseStatusEnum.NetworkError{
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      else if status == ApiResponseStatusEnum.ClientTokenExpiry{
      }
      else{
      }
      
      // Code to upate UI in the Main thread when SiteClasses api response status is false to dismis loader.
      dispatch_async(dispatch_get_main_queue()) {
        // Code to hide progress hud.
        HUD.hide(animated: true)

        // Code to update the UI of screen for api response data.
        self.preparedScreenDesign()
        
        if self.apiResponseFlag == false{ // For the failure case.
          let alert = UIAlertController(title: title, message:message , preferredStyle: UIAlertControllerStyle.Alert)
          // On 'Yes' click.
          alert.addAction(UIAlertAction(title: NSLocalizedString(OKACTION, comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            
            // Code to call back navigation for pop to viewController.
            self.crossButtonTapped(UIButton())
          }))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
    })
  }
  
  
  
  // MARK:  crossButtonTapped method.
  @IBAction func crossButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK:  calculateCellHeightForInstructorDetail method.
  func calculateCellHeightForInstructorDetail(detailDict: [String: String]) -> CGFloat {
    var title = ""
    var detail = ""
    
    if let key = detailDict["key"] {
      title = key as String
    }
    if let value = detailDict["value"] {
      detail = value as String
    }

    let labelDetailFont = FIVETEENSYSTEMMEDIUMFONT
    let labelWidth = self.view.frame.size.width - 40
    
    let labelTitleHeight = self.calculateTitleLabelHeightFor(title)
    let labelDetailHeight = UtilManager.sharedInstance.heightForLabel(detail, font: labelDetailFont, width: labelWidth)

    var heighInFloat = labelTitleHeight + labelDetailHeight
    heighInFloat = heighInFloat + 5.0

    return heighInFloat
  }
  
  // MARK:  calculateTitleLabelHeightFor method.
  func calculateTitleLabelHeightFor(title: String) -> CGFloat {
    let labelTitleFont = THIRTEENSYSTEMFONT
    let labelWidth = self.view.frame.size.width - 40
    
    let labelTitleHeight = UtilManager.sharedInstance.heightForLabel(title, font: labelTitleFont, width: labelWidth)
    return labelTitleHeight + 5.0
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
 * Extension of MVPMyMVPInstructorDetailViewController to add UITableView prototcol UITableViewDataSource and UITableViewDelegate.
 * Override the protocol method to add tableview in MVPMyMVPInstructorDetailViewController.
 */
// MARK:  Extension of MVPMyMVPInstructorDetailViewController by UITableView DataSource & Delegates method.
extension MVPMyMVPInstructorDetailViewController: UITableViewDataSource, UITableViewDelegate{
  
  func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return instructorDetailDictArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var instructorDetailDict = [String: String]()
    instructorDetailDict = instructorDetailDictArray[indexPath.row] as [String: String]
    let floatValue = self.calculateCellHeightForInstructorDetail(instructorDetailDict)
    return floatValue + 5.0
  }
  
  func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    let cell: MyMVPInstructorDetailTableViewCell = (tableView.dequeueReusableCellWithIdentifier(MYMVPINSTRUCTORDETAILTABLEVIEWCELL) as? MyMVPInstructorDetailTableViewCell!)!
    
    var instructorDetailDict = [String: String]()
    instructorDetailDict = instructorDetailDictArray[indexPath.row] as [String: String]
    let floatValue = self.calculateCellHeightForInstructorDetail(instructorDetailDict)
    cell.viewTopHeightConstraint.constant = floatValue
    
    var key = ""
    var value = ""
    if let keyString = instructorDetailDict["key"]{
      key = keyString
    }
    if let valueString = instructorDetailDict["value"]{
      value = valueString
    }
    
    let labelTitleHeight = self.calculateTitleLabelHeightFor(key)
    cell.labelTitleHeightConstraint.constant = labelTitleHeight

    cell.labelInstructorDetailTitle.text = key
    cell.labelInstructorDetailValue.text = value
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableViewInstructorDetailTableView.reloadData()
  }
  
}


// MARK:  Extension of MVPMyMVPInstructorDetailViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPInstructorDetailViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

