//
//  MVPMyMVPCreateWorkoutViewController.swift
//  MVPSports
//
//  Created by Chetu India on 15/09/16.
//

import UIKit
import PKHUD


class MVPMyMVPCreateWorkoutViewController: UIViewController {
  
  
  // MARK:  Widget elements declarations.
  @IBOutlet weak var labelHeaderTitle: UILabel!
  @IBOutlet weak var buttonWorkoutDate: UIButton!
  @IBOutlet weak var buttonWorkoutTime: UIButton!
  @IBOutlet weak var buttonWorkoutType: UIButton!
  @IBOutlet weak var buttonWorkoutDuration: UIButton!

  @IBOutlet weak var textFieldWorkoutDistance: UITextField!
  @IBOutlet weak var textFieldWorkoutCalorie: UITextField!
  @IBOutlet weak var textFieldWorkoutSteps: UITextField!
  
  @IBOutlet weak var viewWorkoutNoteView: UIView!
  @IBOutlet weak var textViewWorkoutNote: UITextView!

  @IBOutlet weak var buttonSaveWorkout: UIButton!
  @IBOutlet weak var buttonCancelWorkout: UIButton!
  @IBOutlet weak var buttonDeleteWorkout: UIButton!

  @IBOutlet weak var viewChooseDateView: UIView!
  @IBOutlet weak var datePickerViewChooseDate: UIDatePicker!
  @IBOutlet weak var viewChooseTimeView: UIView!
  @IBOutlet weak var datePickerViewChooseTime: UIDatePicker!
  @IBOutlet weak var viewChooseMachineTypeView: UIView!
  @IBOutlet weak var labelPickerViewTitle: UILabel!
  @IBOutlet weak var pickerViewChooseMachineTypeDuration: UIPickerView!
  
  @IBOutlet weak var createWorkoutViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var workoutStepsViewHeightConstraint: NSLayoutConstraint!
  
  
  
  // MARK:  instance variables, constant decalaration and define with some values.
  var arrayOfMachineType = ["Cardio","Strength"]
  var arrayOfDuration = [String]()
  var arrayOfPickerView = [String]()
  
  var editWorkout = Workout()
  var editFlag = false
  var manualWorkoutFlag = false
  
  var hoursFlag = true
  var typeOfPicker = PickerTypeEnumeration.Default
  var dimView = UIView()
  var durationInMinutes = 0
  
  
  /*
   * UIViewController class life cycle overrided method to handle viewController functionality on the basis of the states of life cycle method in application.
   * E.g viewDidLoad method to iniailize all the component before appear screem. viewWillAppear method to show loadder or UI related task.
   */
  // MARK:  UIViewController class overrided method.
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    var screenType = ViewScreensEnum.EditWorkOut
    if editFlag == true{
      screenType = ViewScreensEnum.EditWorkOut
    }
    else{
      screenType = ViewScreensEnum.CreateWorkOut
    }
    // Code to mark log event on to flurry for Create/Edit WorkOut screen view.
    dispatch_async(dispatch_get_main_queue(), {
      FlurryManager.sharedInstance.setFlurryLogForScreenType(screenType)
    })
    
    
    // Call method to set UI of screen.
    self.preparedScreenDesign()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Code to set delegate self to RemoteNotificationObserverManager
    RemoteNotificationObserverManager.sharedInstance.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  
  
  /*
   * preparedScreenDesign method is created to set all UI design element configuration with some property.
   */
  // MARK:  preparedScreenDesign method.
  func preparedScreenDesign() {
    // Code to call method to initialize array of duration for the value.
    self.prepareDurationArrayWithHoursMinutesFlag(hoursFlag)
    
    // Code to set delegate to pickerView
    pickerViewChooseMachineTypeDuration.dataSource = self
    pickerViewChooseMachineTypeDuration.delegate = self
    
    // Code to set corener layer radius of delete workout button.
    buttonDeleteWorkout.layer.cornerRadius = VALUETENCORNERRADIUS

    // Code to initiate and prepare the viewChooseMachineTypeView.
    self.viewChooseMachineTypeView.layer.cornerRadius = VALUETENCORNERRADIUS
    self.viewChooseMachineTypeView.layer.masksToBounds = true
    self.viewChooseMachineTypeView.hidden = true
    
    // Code to initiate and prepare the chooseDateView.
    self.viewChooseDateView.layer.cornerRadius = VALUETENCORNERRADIUS
    self.viewChooseDateView.layer.masksToBounds = true
    self.viewChooseDateView.hidden = true

    // Code to initiate and prepare the chooseTimeView.
    self.viewChooseTimeView.layer.cornerRadius = VALUETENCORNERRADIUS
    self.viewChooseTimeView.layer.masksToBounds = true
    self.viewChooseTimeView.hidden = true
    
    // Code to set border frame to Note textview and round rect to the note textview.
    self.viewWorkoutNoteView.layer.borderWidth = VALUEONEBORDERWIDTH
    self.viewWorkoutNoteView.layer.borderColor = LIGHTGRAYCOLOR.CGColor
    self.viewWorkoutNoteView.layer.cornerRadius = VALUETENCORNERRADIUS
    self.viewWorkoutNoteView.layer.masksToBounds = true
    
    // Code to set textField toolBar button inputAccessoryView.
    let toolbarDone = UIToolbar.init()
    toolbarDone.sizeToFit()
    let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Done,
                                          target: self, action: #selector(MVPMyMVPCreateWorkoutViewController.doneButton_Clicked(_:)))
    toolbarDone.items = [barBtnDone] // You can even add cancel button too
    textFieldWorkoutCalorie.inputAccessoryView = toolbarDone
    
    
    // Code to call method to set constraint and view for Create and Edit workout view.
    self.setCreateOrEditWorkoutViewConstraint()
  }
  
  // MARK:  doneButton_Clicked method.
  func doneButton_Clicked(textField: UITextField) {
    self.view.endEditing(true)
  }

  
  // MARK:  setCreateOrEditWorkoutViewConstraint method.
  func setCreateOrEditWorkoutViewConstraint() {
    
    let workOutType = editWorkout.type! as String
    var viewHeightConstraintValue = 0
    
    // Code to validate editWorkout flag to load edit Workout in a view.
    if editFlag == true{
      self.loadEditWorkoutIntoView()
      labelHeaderTitle.text = "Edit Workout"
      
      // Code to check for the Delete Workout button show/hide.
      if workOutType == "manual"{
        workoutStepsViewHeightConstraint.constant = 0
        buttonDeleteWorkout.hidden = false
        
        viewHeightConstraintValue = 610
      }
      else if workOutType == "device"{
        workoutStepsViewHeightConstraint.constant = 50
        buttonDeleteWorkout.hidden = false
        
        viewHeightConstraintValue = 660
      }
      else{
        workoutStepsViewHeightConstraint.constant = 0
        buttonDeleteWorkout.hidden = true
        
        viewHeightConstraintValue = 540
      }
    }
    else{
      datePickerViewChooseDate.maximumDate = NSDate()
      labelHeaderTitle.text = "Add Workout"
      
      buttonDeleteWorkout.hidden = true
      workoutStepsViewHeightConstraint.constant = 0
      viewHeightConstraintValue = 540
    }
    
    // Code to set calculated height of create or edit workout view height constraint.
    createWorkoutViewHeightConstraint.constant = CGFloat(viewHeightConstraintValue)
  }
  
  
  // MARK:  loadEditWorkoutIntoView method.
  func loadEditWorkoutIntoView() {
    let workOutType = editWorkout.type! as String
    if workOutType == "manual"{
      manualWorkoutFlag = true
    }
    
    if manualWorkoutFlag == true{
      if let type = editWorkout.machinetype{ // For Workout Type.
        let machineType = WorkoutViewModel.getMachineTypeForValue(type)
        buttonWorkoutType.setTitle(machineType, forState: UIControlState.Normal)
      }
    }
    else{
      buttonWorkoutType.setTitle(workOutType, forState: UIControlState.Normal)
      buttonWorkoutType.userInteractionEnabled = false
    }
    
    // Code to disabled Date and Time.
    buttonWorkoutDate.userInteractionEnabled = false
    buttonWorkoutTime.userInteractionEnabled = false
    
    // Code to set value to label field for the workout.
    if let workoutDateCreated = editWorkout.datecreated { // For Workout Date & Time.
      if workoutDateCreated.characters.count != 0{
        print(workoutDateCreated)
        let workoutDateString = WorkoutViewModel.getDateStringFromWorkoutCreatedDateString(workoutDateCreated)
        buttonWorkoutDate.setTitle(workoutDateString, forState: UIControlState.Normal)
        
        let workoutTimeString = WorkoutViewModel.getTimeStringFromDateString(workoutDateCreated)
        buttonWorkoutTime.setTitle(workoutTimeString, forState: UIControlState.Normal)
      }
    }
    
    if let workoutDuration = editWorkout.duration{  // For Workout Duration.
      if workoutDuration > 0{
        let durationInSeconds = workoutDuration / 1000
        durationInMinutes = durationInSeconds / 60
        self.setDurationLablelValue()
      }
    }
    
    if let workoutDistance = editWorkout.distance{ // For Workout Distance.
      if workoutDistance > 0{
        textFieldWorkoutDistance.text = "\(workoutDistance)"
      }
    }
    
    if let workoutCalorie = editWorkout.calories{ // For Workout Calorie.
      if workoutCalorie > 0{
        textFieldWorkoutCalorie.text = "\(workoutCalorie)"
      }
    }
    
    if let workoutNote = editWorkout.note { // For Workout Note.
      if workoutNote.characters.count != 0{
        textViewWorkoutNote.text = workoutNote
      }
    }
    
    if let workoutSteps = editWorkout.steps { // For Workout Steps.
      if workoutSteps > 0{
        textFieldWorkoutSteps.text = "\(workoutSteps)"
      }
    }
  }
  
  

  /*
   * prepareDurationArrayWithHoursMinutesFlag method to prepare array of duration for hours and minutes.
   */
  // MARK:  prepareDurationArrayWithHoursMinutesFlag method.
  func prepareDurationArrayWithHoursMinutesFlag(hoursFlag: Bool) {
    // Code to remove all objects from array.
    arrayOfDuration.removeAll()
    
    if hoursFlag == true{ // For Hours
      for value in 0..<25 {
        arrayOfDuration.append("\(value)")
      }
    }
    else{ // // For Minutes
      for value in 0..<60 {
        arrayOfDuration.append("\(value)")
      }
    }
  }
  
  func prepareEditWorkoutRequestParamObject() -> [String: String] {
    let calorie = (textFieldWorkoutCalorie.text)! as String
    let distance = (textFieldWorkoutDistance.text)! as String
    let machineType = (buttonWorkoutType.titleLabel?.text)! as String
    let workoutNote = (textViewWorkoutNote.text)! as String
    
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String

    var inputParams = [String: String]()
    inputParams["memid"] = memberId
    inputParams["workoutid"] = "\(editWorkout.workoutid! as Int)"
    inputParams["steps"] = "\(editWorkout.steps! as Int)"

    if calorie.characters.count == 0{ // For optional Calorie.
      inputParams["calories"] = "0"
    }
    else{
      inputParams["calories"] = calorie
    }

    if distance.characters.count == 0{ // For optional Distance.
      inputParams["distance"] = "0.0"
    }
    else{
      inputParams["distance"] = distance
    }
    
    inputParams["duration"] = "\(durationInMinutes*60*1000)"
    inputParams["machinetype"] = "\(WorkoutViewModel.getValueForMachineType(machineType))"
    if workoutNote == "Add a note."{
      inputParams["note"] = ""
    }
    else{
      inputParams["note"] = workoutNote
    }

    
    let dateCreated = editWorkout.datecreated! as String
    inputParams["Datecreated"] = dateCreated

    let workOutType = editWorkout.type! as String
    if workOutType == "manual"{
      inputParams["flagType"] = "1"
    }
    else if workOutType == "Trainning"{
      inputParams["flagType"] = "4"
    }
    else if workOutType == "Classes"{
      inputParams["flagType"] = "3"
    }
    else{
      inputParams["flagType"] = "2"
    }
    
    return inputParams
  }
  
  // MARK:  executeEditWorkoutApiService method.
  func executeEditWorkoutApiService() {
    var inputParams = [String: String]()
    inputParams = self.prepareEditWorkoutRequestParamObject()
    print(inputParams)
    
    print(inputParams)
    var apiFlag = false
    var title = ""
    var message = ""
    
    // Code to execute the SaveWorkOuts api endpoint from WorkoutService class method saveMyMvpWorkoutsBy to mark Save workOuts of memid.
    WorkoutService.editMyMvpWorkoutsBy(inputParams, And: true, completion: { (responseStatus, arrayOfWorkoutsObject) -> () in
      if responseStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = NSLocalizedString(WORKOUTEDITSUCCESFULLYALERTMSG, comment: "")
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        apiFlag = false
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = NSLocalizedString(INCOMPLETEPARAMETERALERTMSG, comment: "")
      }
      else{ // For Network error.
        apiFlag = false
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      if apiFlag == true{
        // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
        dispatch_async(dispatch_get_main_queue()) {
          /*
           * Code to update the user status flag boolean value to true.
           * We edit a workout here succesfully. Just to update the Workout viewController screen.
           */
          UserViewModel.setUserStatusInApplication(true)
          
          // Code to hide loader
          HUD.hide(animated: true)
          
          let triggerTime = (Int64(NSEC_PER_MSEC) * 1000)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            // Code to call back button action selector to dismis view controller.
            self.backButtonTapped(UIButton())
          })
          
        }
      }
      else{
        // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
        dispatch_async(dispatch_get_main_queue()) {
          HUD.hide(animated: true)
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }

    })
  }
  
  
  
  /*
   * Method to execute Save workout api endpoint services to create a new workout for the logged user.
   */
  // MARK:  executeSaveWorkOutApiService method.
  func executeSaveWorkOutApiService() {
    let inputField = self.prepareSaveWorkoutRequestParamObject()
    
    // Add a note.
    var apiFlag = false
    var title = ""
    var message = ""

    print(inputField)
    // Code to execute the SaveWorkOuts apKi endpoint from WorkoutService class method saveMyMvpWorkoutsBy to mark Save workOuts of memid.
    WorkoutService.saveMyMvpWorkoutsBy(inputField, completion: { (responseStatus, responseData) -> () in
      if responseStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = NSLocalizedString(SAVEWORKOUTSUCCESFULLYMSG, comment: "")
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        apiFlag = false
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else{ // For Network error.
        apiFlag = false
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      if apiFlag == true{
        // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
        dispatch_async(dispatch_get_main_queue()) {
          /*
           * Code to update the user status flag boolean value to true.
           * We added a new workout here succesfully. Just to update the Workout viewController screen.
           */
          UserViewModel.setUserStatusInApplication(true)

          // Code to hide Loader.
          HUD.hide(animated: true)
          
          let triggerTime = (Int64(NSEC_PER_MSEC) * 1000)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            // Code to call back button action selector to dismis view controller.
            self.backButtonTapped(UIButton())
          })
          
        }
      }
      else{
        // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
        dispatch_async(dispatch_get_main_queue()) {
          HUD.hide(animated: true)
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
  }
  
  func prepareSaveWorkoutRequestParamObject() -> [String: AnyObject] {
    var inputField = [String: AnyObject]()

    let date = (buttonWorkoutDate.titleLabel?.text)! as String
    let time = (buttonWorkoutTime.titleLabel?.text)! as String
    let machineType = (buttonWorkoutType.titleLabel?.text)! as String
    let distance = (textFieldWorkoutDistance.text)! as String
    let calorie = (textFieldWorkoutCalorie.text)! as String
    let workoutNote = (textViewWorkoutNote.text)! as String
    
    let dateCreated = WorkoutViewModel.getDateCreatedStringFromSelectedDateString("\(date) \(time)")
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    
    inputField["memid"] = Int(memberId)
    inputField["MachineType"] = WorkoutViewModel.getValueForMachineType(machineType)
    inputField["duration"] = (durationInMinutes*60*1000)
    
    if calorie.characters.count > 0{
      inputField["calories"] = Int(calorie)
    }
    else{
      inputField["calories"] = 0
    }
    
    if distance.characters.count > 0{
      inputField["distance"] = Double(distance)
    }
    else{
      inputField["distance"] = 0.0
    }
    
    inputField["datecreated"] = dateCreated
    if workoutNote == "Add a note."{
      inputField["note"] = ""
    }
    else{
      inputField["note"] = workoutNote
    }

    return inputField
  }
  
  
  
  
  
  /*
   * Method to execute create workout api endpoint services to create a new workout for the logged user.
   */
  // MARK:  saveWorkoutButtonTapped method.
  @IBAction func saveWorkoutButtonTapped(sender: UIButton){
    var typeCheckFlag = false
    if editFlag == true{
      if manualWorkoutFlag == true{
        typeCheckFlag = true
      }
    }
    else{
      typeCheckFlag = true
    }
    
    // Code to validate create workout form field value.
    var checkFlag =  true
    var message = ""
    
    let date = (buttonWorkoutDate.titleLabel?.text)! as String
    let time = (buttonWorkoutTime.titleLabel?.text)! as String
    let machineType = (buttonWorkoutType.titleLabel?.text)! as String
    let duration = (buttonWorkoutDuration.titleLabel?.text)! as String
//    let distance = (textFieldWorkoutDistance.text)! as String
//    let calorie = (textFieldWorkoutCalorie.text)! as String
//    let workoutNote = (textViewWorkoutNote.text)! as String
    
    if date == "MM/dd/yyyy"{
      checkFlag =  false
      message = NSLocalizedString(DATEVALIDATIONMSG, comment: "")
    }
    else if time == "HH:mm"{
      checkFlag =  false
      message = NSLocalizedString(TIMEVALIDATIONMSG, comment: "")
    }
    else if WorkoutViewModel.validateCreateWorkoutDateTimeWithCurrentTimeBy("\(date) \(time)") == false{
      checkFlag =  false
      message = NSLocalizedString(DATETIMEVALIDATIONMSG, comment: "")
    }
    else if (typeCheckFlag == true) && (machineType == "type"){
      checkFlag =  false
      message = NSLocalizedString(MACHINETYPEVALIDATIONMSG, comment: "")
    }
    else if duration == "00h:00m"{
      checkFlag =  false
      message = NSLocalizedString(DURATIONVALIDATIONMSG, comment: "")
    }
//    else if distance.characters.count == 0{
//      checkFlag =  false
//      message = NSLocalizedString(DISTANCEVALIDATIONMSG, comment: "")
//    }
//    else if calorie.characters.count == 0{
//      checkFlag =  false
//      message = NSLocalizedString(CALORIEVALIDATIONMSG, comment: "")
//    }
//    else if workoutNote.characters.count == 0 || workoutNote == "Add a note."{
//      checkFlag =  false
//      message = NSLocalizedString(NOTEVALIDATIONMSG, comment: "")
//    }
    
    if checkFlag == true{ // Successfully validate and execute api for create workout.
      if editFlag == true{
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(EDITWORKOUTMSG, comment: "")))
        self.executeEditWorkoutApiService()
      }
      else{
        HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(SAVEWORKOUTMSG, comment: "")))
        self.executeSaveWorkOutApiService()
      }
    }
    else{
      self.showAlerrtDialogueWithTitle(NSLocalizedString(ALERTTITLE, comment: ""), AndErrorMsg: message)
    }
  }
  
  
  /*
   * Method to cancel create workout api endpoint services to dismiss view of create or edit workout.
   */
  // MARK:  cancelWorkoutButtonTapped method.
  @IBAction func cancelWorkoutButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  /*
   * Method to cancel create workout api endpoint services to dismiss view of create or edit workout.
   */
  // MARK:  deleteWorkoutButtonTapped method.
  @IBAction func deleteWorkoutButtonTapped(sender: UIButton){
    HUD.show(.LabeledProgress(title: "", subtitle: NSLocalizedString(DELETEWORKOUTMSG, comment: "")))
    self.executeDeleteWorkOutApiService()
  }
  
  /*
   * Method to execute Delete workout api endpoint services to delete a workout.
   */
  // MARK:  executeDeleteWorkOutApiService method.
  func executeDeleteWorkOutApiService() {
    let inputField = self.prepareDeleteWorkoutRequestParamObject()
    
    // Add a note.
    var apiFlag = false
    var title = ""
    var message = ""
    
    // Code to execute the DeleteWorkOut api endpoint from WorkoutService class method deleteMyMvpWorkoutsBy to delete workOuts.
    WorkoutService.deleteMyMvpWorkoutsBy(inputField, completion: { (responseStatus, responseData) -> () in
      if responseStatus == ApiResponseStatusEnum.Success{ // For Success.
        apiFlag = true
        title = NSLocalizedString(SUCCESSTITLE, comment: "")
        message = NSLocalizedString(SAVEWORKOUTSUCCESFULLYMSG, comment: "")
      }
      else if responseStatus == ApiResponseStatusEnum.Failure{ // For Failure.
        apiFlag = false
        title = NSLocalizedString(ERRORTITLE, comment: "")
        message = UtilManager.sharedInstance.parseFailureMessageFromApiResponseData(responseData as! NSData)
      }
      else{ // For Network error.
        apiFlag = false
        title = NSLocalizedString(NETWORKERRORTITLE, comment: "")
        message = NSLocalizedString(REQUESTTIMEOUTMSG, comment: "")
      }
      
      if apiFlag == true{
        // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
        dispatch_async(dispatch_get_main_queue()) {
          /*
           * Code to update the user status flag boolean value to true.
           * We deleted a workout here succesfully. Just to update the Workout viewController screen.
           */
          UserViewModel.setUserStatusInApplication(true)
          
          // Code to hide Loader.
          HUD.hide(animated: true)
          
          let triggerTime = (Int64(NSEC_PER_MSEC) * 1000)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            // Code to call back button action selector to dismis view controller.
            self.backButtonTapped(UIButton())
          })
          
        }
      }
      else{
        // Code to upate UI in the Main thread when GetRewards api response status is false to dismis loader.
        dispatch_async(dispatch_get_main_queue()) {
          HUD.hide(animated: true)
          self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
        }
      }
      
    })
  }
  
  func prepareDeleteWorkoutRequestParamObject() -> [String: AnyObject] {
    // params : memid=Int&workoutid=INt&flagtype=Int
    
    var inputField = [String: AnyObject]()
    var loggedUserDict = UserViewModel.getUserDictFromUserDefaut() as [String: String]
    let memberId = loggedUserDict["memberId"]! as String
    let workoutType = editWorkout.type! as String
    
    inputField["memid"] = Int(memberId)
    inputField["workoutid"] = "\(editWorkout.workoutid! as Int)"
    
    if workoutType == "manual"{
      inputField["flagtype"] = 1
    }
    else{
      inputField["flagtype"] = 2
    }
    
    return inputField
  }
  
  

  
  /*
   * Method to handle workout form view textfield entry view action.
   */
  // MARK:  createWorkoutFormFieldEntryButtonTapped method.
  @IBAction func createWorkoutFormFieldEntryButtonTapped(sender: UIButton) {
    let indexTag = sender.tag
    switch indexTag {
      
    case 0: // For Date
      if buttonWorkoutDate.titleLabel?.text != "MM/dd/yyyy"{
        let date = WorkoutViewModel.getDateObjectFromDateString((buttonWorkoutDate.titleLabel?.text)! as String, withStringFormat: "MM/dd/yyyy")
        datePickerViewChooseDate.date = date
      }
      else{
        datePickerViewChooseDate.date = NSDate()
      }
      self.showOrHideChooseDateView(true)
      
    case 1: // For Time
      if buttonWorkoutTime.titleLabel?.text != "HH:mm"{
        let currentDateString = WorkoutViewModel.getDateStringFromChooseDate(NSDate(), withStringFormat: "dd/MM/yyyy")
        let time = WorkoutViewModel.getDateObjectFromDateString("\(currentDateString) \((buttonWorkoutTime.titleLabel?.text)! as String)", withStringFormat: "dd/MM/yyyy hh:mma")
        datePickerViewChooseTime.date = time
      }
      else{
        datePickerViewChooseTime.date = NSDate()
      }
      self.showOrHideChooseTimeView(true)
      break
      
    case 2: // For Machine Type
      typeOfPicker = PickerTypeEnumeration.MachineType
      labelPickerViewTitle.text = "Machine Type"
      arrayOfPickerView = arrayOfMachineType
      self.showOrHideDurationMachineTypeView(true)
      break

    case 3: // For Duration
      typeOfPicker = PickerTypeEnumeration.Duration
      labelPickerViewTitle.text = "Duration"
      
      self.showOrHideDurationMachineTypeView(true)
      break
      
    default:
      print("")
    }
  }
  
  
  /*
   * Method to invoke from back button selector target method to pop viewController from the stack.
   */
  // MARK:  backButtonTapped method.
  @IBAction func backButtonTapped(sender: UIButton){
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  
  
  
  // MARK:  ChooseDatePickerButtonsTappedAction method.
  @IBAction func ChooseDatePickerButtonsTappedAction(sender: UIButton){
    let tagIndex = sender.tag
    switch tagIndex {
    case 101:
      // Cancel date picker value.
      self.showOrHideChooseDateView(false)

    case 201:
      // Save date picker value.
      let chooseDate = datePickerViewChooseDate.date
      let dateString = WorkoutViewModel.getDateStringFromChooseDate(chooseDate, withStringFormat: "MM/dd/yyyy")
      buttonWorkoutDate.setTitle(dateString, forState: UIControlState.Normal)
      
      self.showOrHideChooseDateView(false)

    default:
      print("")
    }
  }
  
  // MARK:  showOrHideChooseDateView method.
  func showOrHideChooseDateView(showFlag: Bool)  {
    if showFlag == true{
      dimView = UIView()
      dimView.frame = self.view.frame
      dimView.backgroundColor = BLACKCOLOR
      dimView.alpha = 0.0
      self.view.addSubview(dimView)
      
      self.view.bringSubviewToFront(self.viewChooseDateView)
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
        self.dimView.alpha = 0.6
        }, completion: { finished in
            self.viewChooseDateView.hidden = false
      })
    }
    else{
      self.viewChooseDateView.hidden = true
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
        self.dimView.alpha = 0.0
        }, completion: { finished in
          self.dimView.removeFromSuperview()
      })
    }
    
    
  }
  
  
  
  
  
  // MARK:  ChooseTimePickerButtonsTappedAction method.
  @IBAction func ChooseTimePickerButtonsTappedAction(sender: UIButton){
    let tagIndex = sender.tag
    switch tagIndex {
    case 101:
      self.showOrHideChooseTimeView(false)
      
    case 201:
      // Save Time picker value.
      let chooseTime = datePickerViewChooseTime.date
      let timeString = WorkoutViewModel.getDateStringFromChooseDate(chooseTime, withStringFormat: "hh:mma")
      buttonWorkoutTime.setTitle(timeString, forState: UIControlState.Normal)
      self.showOrHideChooseTimeView(false)
      
    default:
      print("")
    }
  }
  
  // MARK:  showOrHideChooseTimeView method.
  func showOrHideChooseTimeView(showFlag: Bool)  {
    if showFlag == true{
      dimView = UIView()
      dimView.frame = self.view.frame
      dimView.backgroundColor = BLACKCOLOR
      dimView.alpha = 0.0
      self.view.addSubview(dimView)
      
      self.view.bringSubviewToFront(self.viewChooseTimeView)
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
        self.dimView.alpha = 0.6
        }, completion: { finished in
          self.viewChooseTimeView.hidden = false
      })
    }
    else{
      self.viewChooseTimeView.hidden = true
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
        self.dimView.alpha = 0.0
        }, completion: { finished in
          self.dimView.removeFromSuperview()
      })
    }
  }
  
  
  
  
  
  // MARK:  ChooseTimePickerButtonsTappedAction method.
  @IBAction func ChooseDurationMachineTypePickerButtonsTappedAction(sender: UIButton){
    let tagIndex = sender.tag
    switch tagIndex {
    case 101:
      // Cancel picker value.
      buttonWorkoutDuration.userInteractionEnabled = true
      self.showOrHideDurationMachineTypeView(false)
        break
      
    case 201:
      // Save picker value.
      switch typeOfPicker {
      case PickerTypeEnumeration.MachineType:
        let pickerValueIndex = pickerViewChooseMachineTypeDuration.selectedRowInComponent(0)
        let pickerValue = arrayOfPickerView[pickerValueIndex] as String
        buttonWorkoutType.setTitle(pickerValue, forState: UIControlState.Normal)
        
        self.showOrHideDurationMachineTypeView(false)
        
      case PickerTypeEnumeration.Duration:
        if hoursFlag == true{ // For Hours.
          buttonWorkoutDuration.userInteractionEnabled = false
          hoursFlag = false

          let pickerValueIndex = pickerViewChooseMachineTypeDuration.selectedRowInComponent(0)
          let valueInHours = arrayOfPickerView[pickerValueIndex] as String
          let hours = Int(valueInHours)
          let minutes = hours!*60
          
          let previousHoursValue = durationInMinutes / 60
          let previousHoursValueInMinutes = previousHoursValue * 60
          
          durationInMinutes = durationInMinutes - previousHoursValueInMinutes + minutes
          self.setDurationLablelValue()
          
          self.showOrHideDurationMachineTypeView(false)

          // Code to call method to prepare duration pickerview for Minutes.
          NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1.0), target: self, selector: #selector(MVPMyMVPCreateWorkoutViewController.callMethodForDurationPickerInMinutes(_:)), userInfo: nil, repeats: false)
        }
        else{ // For Minutes.
          buttonWorkoutDuration.userInteractionEnabled = true
          hoursFlag = true

          let pickerValueIndex = pickerViewChooseMachineTypeDuration.selectedRowInComponent(0)
          let valueInMinutes = arrayOfPickerView[pickerValueIndex] as String
          let minutes = Int(valueInMinutes)
          let previousMinutesValue = durationInMinutes % 60

          durationInMinutes = durationInMinutes - previousMinutesValue + minutes!
          self.setDurationLablelValue()
          
          self.showOrHideDurationMachineTypeView(false)
        }
        break
        
      case PickerTypeEnumeration.Default:
        print("")
      }
      break
      
    default:
      print("")
    }
  }
  
  // MARK:  callMethodForDurationPickerInMinutes method.
  func callMethodForDurationPickerInMinutes(timer : NSTimer){
    typeOfPicker = PickerTypeEnumeration.Duration
    labelPickerViewTitle.text = "Duration"
    self.showOrHideDurationMachineTypeView(true)
  }

    // MARK:  showOrHideDurationMachineTypeView method.
  func showOrHideDurationMachineTypeView(showFlag: Bool)  {
    if showFlag == true{
      pickerViewChooseMachineTypeDuration.reloadAllComponents()
      
      dimView = UIView()
      dimView.frame = self.view.frame
      dimView.backgroundColor = BLACKCOLOR
      dimView.alpha = 0.0
      self.view.addSubview(dimView)
      
      // Code to set value on picker for type MachineType and Duration.
      switch typeOfPicker {
      case PickerTypeEnumeration.MachineType:
        let machineType = (buttonWorkoutType.titleLabel?.text)! as String
        if machineType != ""{
          var rowIndex = 0
          for index in 0 ..< arrayOfPickerView.count{
            let pickerType = arrayOfPickerView[index] as String
            if machineType == pickerType{
              rowIndex = index
              break
            }
          }
          pickerViewChooseMachineTypeDuration.selectRow(rowIndex, inComponent: 0, animated: true)
        }
        else{
          pickerViewChooseMachineTypeDuration.selectRow(0, inComponent: 0, animated: true)
        }
        break
        
      case PickerTypeEnumeration.Duration:
        // Code to call method to initialize array of duration for the value.
        self.prepareDurationArrayWithHoursMinutesFlag(hoursFlag)
        arrayOfPickerView = arrayOfDuration
        pickerViewChooseMachineTypeDuration.reloadAllComponents()
        
        if durationInMinutes != 0{
          var valueToCompare = ""
          if hoursFlag == true{
            let hoursInValue = durationInMinutes / 60
            valueToCompare = "\(hoursInValue)"
          }
          else{
            let hoursInValue = durationInMinutes / 60
            if hoursInValue != 0{
              valueToCompare = "\(durationInMinutes % 60)"
            }
            else{
              valueToCompare = "\(durationInMinutes)"
            }
          }
          
          var rowIndex = 0
          for index in 0 ..< arrayOfPickerView.count{
            let pickerValue = arrayOfPickerView[index] as String
            if valueToCompare == pickerValue{
              rowIndex = index
              break
            }
          }
          pickerViewChooseMachineTypeDuration.selectRow(rowIndex, inComponent: 0, animated: true)
        }
        else{
          pickerViewChooseMachineTypeDuration.selectRow(0, inComponent: 0, animated: true)
        }
        break
        
      case PickerTypeEnumeration.Default:
        print("")
      }
      
      self.view.bringSubviewToFront(self.viewChooseMachineTypeView)
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
        self.dimView.alpha = 0.6
        }, completion: { finished in
          self.viewChooseMachineTypeView.hidden = false
      })
    }
    else{
      self.viewChooseMachineTypeView.hidden = true
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
        self.dimView.alpha = 0.0
        }, completion: { finished in
          self.dimView.removeFromSuperview()
      })
    }
  }
  
  // MARK:  setDurationLablelValue method.
  func setDurationLablelValue() {
    if durationInMinutes == 0{
      buttonWorkoutDuration.setTitle("00h 00m", forState: UIControlState.Normal)
    }
    else{
      let hoursValue = durationInMinutes / 60
      let minutesValue = durationInMinutes % 60
      var hour = ""
      var minutes = ""
      
      if hoursValue < 10{
        hour = "0\(hoursValue)"
      }
      else{
        hour = "\(hoursValue)"
      }

      if minutesValue < 10{
        minutes = "0\(minutesValue)"
      }
      else{
        minutes = "\(minutesValue)"
      }

      let durationString = "\(hour)h \(minutes)m"
      buttonWorkoutDuration.setTitle(durationString, forState: UIControlState.Normal)
    }
  }
  
  // MARK:  prepareViewForPicker method.
  func prepareViewForPicker() {
    switch typeOfPicker {
    case PickerTypeEnumeration.MachineType:
      print("")

    case PickerTypeEnumeration.Duration:
      print("")

    case PickerTypeEnumeration.Default:
      print("")
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
 * Extension of MVPMyMVPCreateWorkoutViewController to add UIPickerView prototcol UIPickerViewDataSource and UIPickerViewDelegate.
 * Override the protocol method to add pickerView in MVPMyMVPCreateWorkoutViewController.
 */
// MARK:  Extension of MVPMyMVPCreateWorkoutViewController by UIPickerView DataSource & Delegates method.
extension MVPMyMVPCreateWorkoutViewController: UIPickerViewDataSource, UIPickerViewDelegate{
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return arrayOfPickerView.count;
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    var rowValue = ""
    switch typeOfPicker {
    case PickerTypeEnumeration.MachineType:
      rowValue =  arrayOfPickerView[row] as String
      break
      
    case PickerTypeEnumeration.Duration:
      if hoursFlag == true{
        rowValue = "\(arrayOfPickerView[row] as String) Hours"
      }
      else{
        rowValue = "\(arrayOfPickerView[row] as String) Minutes"
      }
      break
      
    case PickerTypeEnumeration.Default:
      rowValue = arrayOfPickerView[row] as String
      break
    }
    
    return rowValue
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
      // print(arrayOfPickerView[row] as String)
  }
  
}


/*
 * Extension of MVPMyMVPCreateWorkoutViewController to add UITextView prototcol UITextViewDelegate method.
 * Override the protocol method to add textViewNote in MVPMyMVPCreateWorkoutViewController.
 */
// MARK:  Extension of MVPMyMVPCreateWorkoutViewController by UIPickerView DataSource & Delegates method.
extension MVPMyMVPCreateWorkoutViewController: UITextViewDelegate{

  func textViewDidBeginEditing(textView: UITextView) {
    if textView.text == "Add a note." {
      textView.text = ""
    }
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Add a note."
    }
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    
    // Combine the textView text and the replacement text to
    // create the updated text string
    let currentText:NSString = textView.text
    let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
    
    // If updated text view will be empty, add the placeholder
    // and set the cursor to the beginning of the text view
    if updatedText.isEmpty {
      textView.text = "Add a note."
      textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
      return false
    }
      // Else if the text view's placeholder is showing and the
      // length of the replacement string is greater than 0, clear
      // the text view and set its color to black to prepare for
      // the user's entry
    else if textView.text == "Add a note." && !text.isEmpty {
      textView.text = nil
      textView.textColor = BLACKCOLOR
    }
    else if text == "\n"{
        textView.resignFirstResponder()
      return false
    }
    else if updatedText.characters.count > 512{
      var title = ""
      var message = ""
      title = NSLocalizedString(ALERTTITLE, comment: "")
      message = NSLocalizedString(NOTETEXTLENGTHVALIDATIONMSG, comment: "")
      self.showAlerrtDialogueWithTitle(title, AndErrorMsg: message)
      return false;
    }
    
    return true
  }

}


/*
 * Extension of MVPMyMVPCreateWorkoutViewController to add UITextField prototcol UITextFieldDelegate.
 * Override the protocol method of textfield delegate in MVPMyMVPCreateWorkoutViewController to handle textfield action event and slector method.
 */
// MARK:  UITextField Delegates methods
extension MVPMyMVPCreateWorkoutViewController: UITextFieldDelegate{
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
    let textfieldTag = textField.tag
    if textfieldTag == 101{ // For Distance
      if string != ""{ // When user tapped back slash
        let aSet = NSCharacterSet(charactersInString:"0123456789.").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        if string == numberFiltered{ // When user tapped a valid keyboard key.
          
          if textField.text!.rangeOfString(".") != nil && string == "."{
            return false
          }
          
          if textField.text!.rangeOfString(".") != nil {
            let endindex = textField.text!.rangeOfString(".", options: .BackwardsSearch)?.endIndex
            let substring = textField.text!.substringFromIndex(endindex!)
            if substring.characters.count == 2{
              return false
            }
          }
          
        }
        else{ // return false when user entered non valid keyboard key.
          return false
        }
      }
    }
    
    return true
  }
  
}


// MARK:  Extension of MVPMyMVPCreateWorkoutViewController by RemoteNotificationObserverDelegate method.
extension MVPMyMVPCreateWorkoutViewController: RemoteNotificationObserverDelegate{
  
  func announcementDelegate(){
    print("MVPMyMVPCreateWorkoutViewController announcementDelegate")
    // Code to navigate user to annoucemnet screen for the notification.
    NavigationViewManager.instance.navigateToAnnouncementsViewControllerFrom(self)
  }
}

