//
//  MyMVPTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 17/08/16.
//

import UIKit


class MyMVPTableViewCell: UITableViewCell {
  
  // MARK:  UITableViewCell subclass MyMVPTableViewCell widget instance veriable declaration.
  @IBOutlet weak var viewElementSuperView: UIView!
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var labelSubTitle: UILabel!
  
  
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