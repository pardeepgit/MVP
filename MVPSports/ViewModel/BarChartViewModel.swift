//
//  BarChartViewModel.swift
//  MVPSports
//
//  Created by Chetu India on 07/09/16.
//

import Foundation


/*
 * BarChartViewModel class implements class method declaration and defination to handle functionality of Member/HealthPoint BarChartGraph functionality execution.
 */
class BarChartViewModel {
  
  
  /*
   * createBarChartViewWithFrame method to design a Bar Chart view with parametrized frame.
   */
  // MARK:  createBarChartViewWithFrame method.
  class func createBarChartViewWithFrame(chartFrame: CGRect) -> SimpleBarChart{
    let chart = SimpleBarChart(frame: chartFrame)
    chart.barShadowOffset = CGSizeMake(2.0, 1.0);
    chart.animationDuration = 0.0;
    chart.barShadowColor = LIGHTGRAYCOLOR
    chart.barShadowAlpha = 0.5;
    chart.barShadowRadius = 1.0;
    chart.barWidth = 25.0;
    chart.xLabelType = SimpleBarChartXLabelTypeHorizontal;
    chart.barTextType = SimpleBarChartBarTextTypeTop;
    chart.hasGrids = false;
    chart.barTextColor = BLACKCOLOR
    chart.gridColor = BLACKCOLOR

    return chart
  }
  


  
  
  /*
   * createArrayOfGraphYlabelValuesFromHelathPoints method to prepare array of y-label value of graph.
   */
  // MARK:  createArrayOfGraphYlabelValuesFromHelathPoints method.
  class func createArrayOfGraphYlabelValuesFromHelathPoints(arrayOfHealthPointLevelObject: [[String: AnyObject]]) -> [Int]{
    var arrayOfYlabelValue = [Int]()
    
    for index in 0 ..< arrayOfHealthPointLevelObject.count{
      let healthPointLevelObject = arrayOfHealthPointLevelObject[index] as [String: AnyObject]
      let rulepoints = healthPointLevelObject["rulepoints"] as! String
      arrayOfYlabelValue.append(Int(rulepoints)!)
    }
    
    return arrayOfYlabelValue
  }
  
  /*
   * createArrayOfGraphXlabelValuesFromHelathPoints method to prepare array of x-label value of graph.
   */
  // MARK:  createArrayOfGraphXlabelValuesFromHelathPoints method.
  class func createArrayOfGraphXlabelValuesFromHelathPoints(arrayOfHealthPointLevelObject: [[String: AnyObject]]) -> [String]{
    var arrayOfXlabelValue = [String]()
    
    for index in 0 ..< arrayOfHealthPointLevelObject.count{
      let healthPointLevelObject = arrayOfHealthPointLevelObject[index] as [String: AnyObject]
      
      if let levelnameString = healthPointLevelObject["levelname"] as? String{
        let levelnameStartRange = levelnameString.rangeOfString("-",
                                                                options: NSStringCompareOptions.LiteralSearch,
                                                                range: levelnameString.startIndex..<levelnameString.endIndex,
                                                                locale: nil)
        
        let levelname = levelnameString [(levelnameString.startIndex)..<(levelnameStartRange!.startIndex.advancedBy(-1))]
        arrayOfXlabelValue.append(levelname)
      }
      else{
        arrayOfXlabelValue.append("")
      }
    }
    
    return arrayOfXlabelValue
  }
  
  /*
   * createArrayOfErnedPointArrayForPointLevelByEarnedLevel method to prepare  array of filled y-label value on graph by earned point level.
   */
  // MARK:  createArrayOfErnedPointArrayForPointLevelByEarnedLevel method.
  class func createArrayOfErnedPointArrayForPointLevelByEarnedLevel(arrayOfYlablePoints: [Int], with ernedPoint: Int) -> [Int]{
    var arrayOfEarnedPointsLabelValue = [Int]()

    if ernedPoint == 0{
      for _ in 0 ..< arrayOfYlablePoints.count{
        arrayOfEarnedPointsLabelValue.append(0)
      }
    }
    else{
      var doneFlag = false
      for index in 0 ..< arrayOfYlablePoints.count{
        
        if doneFlag == false{
          let pointLevel = arrayOfYlablePoints[index] as Int
          if pointLevel >= ernedPoint{
            arrayOfEarnedPointsLabelValue.append(ernedPoint)
            doneFlag = true
          }
          else{
            arrayOfEarnedPointsLabelValue.append(pointLevel)
          }
        }
        else{
          arrayOfEarnedPointsLabelValue.append(0)
        }
      }
    }
    
    return arrayOfEarnedPointsLabelValue
  }
  
  /*
   * getNextLevelPointOfErnedPointBy method to calculate next level point of earned point from chart y lable array.
   */
  // MARK:  getNextLevelPointOfErnedPointBy method.
  class func getNextLevelPointOfErnedPointBy(arrayOfYlablePoints: [Int], with ernedPoint: Int) -> Int{
    var nextLevelPoint = 0

    if ernedPoint == 0{
      if arrayOfYlablePoints.count > 0{
        nextLevelPoint = arrayOfYlablePoints[0]
      }
    }
    else{
      for index in 0 ..< arrayOfYlablePoints.count{
        
        let pointLevel = arrayOfYlablePoints[index] as Int
        if pointLevel >= ernedPoint{
          nextLevelPoint = pointLevel - ernedPoint
          break
        }
      }
    }
    
    return nextLevelPoint
  }
  
  /*
   * getChartYlableIncrementValue method to get increamneted value of yLabel.
   */
  // MARK:  getChartYlableIncrementValue method.
  class func getChartYlableIncrementValue(arrayOfGraphYlabelValues: [Int]) -> Int{
    var max = 0
    var increamentedValue = 0
    for index in 0 ..< arrayOfGraphYlabelValues.count{
      let value = arrayOfGraphYlabelValues[index]
      
      if value > max{
        max = value
      }
    }
    
    let reminder = max % 10
    if reminder == 0{
      increamentedValue = (max/5)
    }
    else{
      let valueToAdd = 10 - reminder
      max = max + valueToAdd
      increamentedValue = (max/5)
    }
    
    return increamentedValue
  }
  

  /*
   * parseUserPunchCardResponse method parse the Punch Card response Data into left value.
   */
  // MARK:  parseUserPunchCardResponse method.
  class func parseUserPunchCardResponse(punchCardData: NSData) -> (String, String){
    var visitLeft = "0"
    var total = "0"

    var punchCardResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try punchCardResponseDict = (NSJSONSerialization.JSONObjectWithData(punchCardData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfPunchCardObject = [[String: AnyObject]]()
    
    if punchCardResponseDict.count > 0{
      if let punchCardObjectArray = punchCardResponseDict[RESPONSE] as? [[String: AnyObject]]{
        arrayOfPunchCardObject = punchCardObjectArray
      }
    }
    
    var punchCardObject = [String: AnyObject]()
    if arrayOfPunchCardObject.count > 0{
      punchCardObject = arrayOfPunchCardObject[0]

      if let leftVisit = punchCardObject["visitsleft"] as? Int{
        visitLeft = String(leftVisit)
      }
      
      if let totalQuantity = punchCardObject["initialquantity"] as? Int{
        total = String(totalQuantity)
      }
    }

    return (visitLeft, total)
  }
  

  /*
   * parseHealthPointLevelResponse method parse the response json dictionary into HealthPointLevel.
   */
  // MARK:  parseHealthPointLevelResponse method.
  class func parseOptInStatusResponse(optInStatusData: NSData) -> UserOptInStatusEnum{
    var optInStatusType = UserOptInStatusEnum.DefaultUpChart
    
    var optInStatusResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try optInStatusResponseDict = (NSJSONSerialization.JSONObjectWithData(optInStatusData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfOptInStatusObject = [[String: AnyObject]]()
    if let optInStatusObjectArray = optInStatusResponseDict[RESPONSE] as? [[String: AnyObject]]{
      arrayOfOptInStatusObject = optInStatusObjectArray
    }
    
    var optInStatusObject = [String: AnyObject]()
    if arrayOfOptInStatusObject.count > 0{
      optInStatusObject = arrayOfOptInStatusObject[0]
      
      // Code to retrieve hp and optIn flag for OptInStatus of logged user.
      var ismemberFlag = false
      var hpFlag = false
      var optInFlag = false

      if let ismember = optInStatusObject["ismember"] as? Bool{
        ismemberFlag = ismember
      }
      if let hp = optInStatusObject["showhp"] as? Bool{
        hpFlag = hp
      }
      if let optIn = optInStatusObject["optin"] as? Bool{
        optInFlag = optIn
        print(optInFlag)
      }
      
      
      if ismemberFlag == true{ // logged user is eligible
        if hpFlag == true{ // Eligible for hpChart
          if optInFlag == true{ // Valid for HpChart
            optInStatusType = UserOptInStatusEnum.HpChart
          }
          else{ // Invalid due to OptIn. First OptIn.
            optInStatusType = UserOptInStatusEnum.OptInView
          }
        }
        else{ // Logged user is not eligible for the HpChart.
          optInStatusType = UserOptInStatusEnum.HideHpView
        }
      }
      else{ // Logged user is not a Member of HpChart.
        optInStatusType = UserOptInStatusEnum.PunchCardSession
      }
      
    }
    
    return optInStatusType
  }

  
  /*
   * parseHealthPointLevelResponse method parse the response json dictionary into HealthPointLevel.
   */
  // MARK:  parseHealthPointLevelResponse method.
  class func parseHealthPointLevelResponse(healthPointJsonData: NSData) -> [[String: AnyObject]] {
    var healthPointLevelResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try healthPointLevelResponseDict = (NSJSONSerialization.JSONObjectWithData(healthPointJsonData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    var arrayOfHealthPointLevelObject = [[String: AnyObject]]()
    if healthPointLevelResponseDict.count > 0{
      if let arrayOfHealthPointLevels = healthPointLevelResponseDict[RESPONSE] as? [[String: AnyObject]]{
        arrayOfHealthPointLevelObject = arrayOfHealthPointLevels
      }
    }
    
    return arrayOfHealthPointLevelObject
  }
  
  /*
   * parseMemberHealthPointResponseForEarnedPoint method parse the response for logged member health point earned level.
   */
  // MARK:  parseMemberHealthPointResponseForEarnedPoint method.
  class func parseMemberHealthPointResponseForEarnedPoint(healthPointJsonData: NSData) -> Int{
    var earnedHealthPointLevel = 0
    
    var healthPointLevelResponseDict = [String:AnyObject]()
    do {
      // Code to serialized json string into json object by NSJSONSerialization class method JSONObjectWithData.
      try healthPointLevelResponseDict = (NSJSONSerialization.JSONObjectWithData(healthPointJsonData, options: []) as? [String:AnyObject])!
    }
    catch let error as NSError {
      print(error)
    }
    
    if healthPointLevelResponseDict.count > 0{
      if let memberHealthPointObject = healthPointLevelResponseDict[RESPONSE] as? [[String: AnyObject]]{

        if memberHealthPointObject.count > 0{
          let ernedPointDict = memberHealthPointObject[0] as [String: AnyObject]
          if let rulePoint = ernedPointDict["Points"] as? String {
            earnedHealthPointLevel = Int(rulePoint)!
          }
          else{
            earnedHealthPointLevel = 0
          }
        }
      }
    }
    
    return earnedHealthPointLevel
  }


  
  /*
   * setHideOptInHpChartStatus method to save default data for logged user HpChart and OptIn status in local NSuserDefault.
   */
  // MARK:  setHideOptInHpChartStatus method.
  class func setHideOptInHpChartStatus() {
    let optInStatus = 4
    
    var optInDataDict = [String: AnyObject]()
    optInDataDict["optInStatus"] = optInStatus
    
    NSUserDefaults.standardUserDefaults().setValue(optInDataDict, forKey: "optInData")
    NSUserDefaults.standardUserDefaults().synchronize()
  }

  
  /*
   * setDeafultOptInHpChartData method to save default data for logged user HpChart in local NSuserDefault.
   */
  // MARK:  setDeafultOptInHpChartData method.
  class func setDeafultOptInHpChartData() {
    let arrayOfGraphYlabelValues: [Int] = [100, 200, 400, 600]
    let arrayOfGraphXlabelValues: [String] = ["Level 1", "Level 2", "Level 3", "Level 4"]
    let earnedPoint = 0
    let optInStatus = 0
    
    var optInDataDict = [String: AnyObject]()
    optInDataDict["yLabel"] = arrayOfGraphYlabelValues
    optInDataDict["xLabel"] = arrayOfGraphXlabelValues
    optInDataDict["earnedPoint"] = earnedPoint
    optInDataDict["optInStatus"] = optInStatus

    NSUserDefaults.standardUserDefaults().setValue(optInDataDict, forKey: "optInData")
    NSUserDefaults.standardUserDefaults().synchronize()
  }

  /*
   * setDeafultOptInHpChartData method to save HpChart data for logged user HpChart in local NSuserDefault.
   */
  // MARK:  setDeafultOptInHpChartData method.
  class func setHpChartDataFor(healthPointLevel: [[String: AnyObject]], And earnedPoint: Int) {
    let arrayOfGraphYlabelValues: [Int] = BarChartViewModel.createArrayOfGraphYlabelValuesFromHelathPoints(healthPointLevel)
    let arrayOfGraphXlabelValues: [String] = BarChartViewModel.createArrayOfGraphXlabelValuesFromHelathPoints(healthPointLevel)
    let earnedPoint = earnedPoint
    let optInStatus = 1
    
    var optInDataDict = [String: AnyObject]()
    optInDataDict["yLabel"] = arrayOfGraphYlabelValues
    optInDataDict["xLabel"] = arrayOfGraphXlabelValues
    optInDataDict["earnedPoint"] = earnedPoint
    optInDataDict["optInStatus"] = optInStatus
    
    NSUserDefaults.standardUserDefaults().setValue(optInDataDict, forKey: "optInData")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  
  /*
   * setOptInViewDataFor method to save OptInView data for logged user OptIn in local NSuserDefault.
   */
  // MARK:  setOptInViewDataFor method.
  class func setOptInViewDataFor() {
    let optInStatus = 2

    var optInDataDict = [String: AnyObject]()
    optInDataDict["optInStatus"] = optInStatus
    
    NSUserDefaults.standardUserDefaults().setValue(optInDataDict, forKey: "optInData")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  
  /*
   * setPunchCardSessionDataFor method to save PunchCard Session data for logged user OptIn in local NSuserDefault.
   */
  // MARK:  setPunchCardSessionDataFor method.
  class func setPunchCardSessionDataFor(punchCardTuppleResponse: (String, String)) {
    let optInStatus = 3
    let visitLeft = punchCardTuppleResponse.0
    let totalSession = punchCardTuppleResponse.1
    
    var optInDataDict = [String: AnyObject]()
    optInDataDict["optInStatus"] = optInStatus
    optInDataDict["visitLeft"] = visitLeft
    optInDataDict["totalSession"] = totalSession

    NSUserDefaults.standardUserDefaults().setValue(optInDataDict, forKey: "optInData")
    NSUserDefaults.standardUserDefaults().synchronize()
  }

  
  /*
   * Code to get client token from local NSUserDeafult object of default .plist file.
   * Get parameter value for key clientToken
   */
  class func getOptInData() -> [String: AnyObject]{
    if let optInDataDict = NSUserDefaults.standardUserDefaults().valueForKey("optInData") as? [String: AnyObject]{
      return optInDataDict
    }
    else{
      return [String: AnyObject]()
    }
  }

}
