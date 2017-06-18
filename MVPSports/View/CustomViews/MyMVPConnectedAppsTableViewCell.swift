//
//  MyMVPConnectedAppsTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 01/09/16.
//

import UIKit

class MyMVPConnectedAppsTableViewCell: UITableViewCell {
  
  
  // MARK:  UITableViewCell subclass MyMVPConnectedAppsTableViewCell widget instance veriable declaration.
  @IBOutlet weak var viewParentViewOfConnectedApp: UIView!
  @IBOutlet weak var imageViewConnectedAppIcon: UIImageView!
  @IBOutlet weak var labelConnectedAppState: UILabel!
  @IBOutlet weak var buttonLinkConnectedApp: UIButton!
  
  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    viewParentViewOfConnectedApp.layer.cornerRadius = VALUEFIVECORNERRADIUS
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
}