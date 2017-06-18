//
//  MyMVPNotificationsTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 06/02/17.
//

import UIKit

class MyMVPNotificationsTableViewCell: UITableViewCell {

  // MARK:  UITableViewCell subclass MyMVPNotificationsTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelNotificationDescription: UILabel!
  @IBOutlet weak var buttonDeleteAnnouncement: UIButton!

  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    buttonDeleteAnnouncement.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    buttonDeleteAnnouncement.layer.masksToBounds = true
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
}