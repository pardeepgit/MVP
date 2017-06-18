//
//  MyMVPCheckInTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 06/10/16.
//

import UIKit

class MyMVPCheckInTableViewCell: UITableViewCell {
  
  // MARK:  UITableViewCell subclass MyMVPCheckInTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelClassDate: UILabel!
  @IBOutlet weak var labelClassName: UILabel!
  @IBOutlet weak var buttonClassCheckIn: UIButton!
  
  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    /*
     * Code to Change the lable font size for the iPhone_5 device.
     */
    if DeviceType.IS_IPHONE_5 {
      labelClassName.font = FIVETEENSYSTEMFONT
      labelClassDate.font = FIVETEENSYSTEMFONT
    }
    else if DeviceType.IS_IPHONE_6 {
    }
    else if DeviceType.IS_IPHONE_6P {
    }
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
}