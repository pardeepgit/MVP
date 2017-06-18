//
//  MyMVPNotificationClubsTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 06/09/16.
//

import UIKit

class MyMVPNotificationClubsTableViewCell: UITableViewCell {
  
  // MARK:  UITableViewCell subclass MyMVPNotificationClubsTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelNotificationClubNameState: UILabel!
  @IBOutlet weak var buttonNotificationClubActivation: UIButton!
  
  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }

}