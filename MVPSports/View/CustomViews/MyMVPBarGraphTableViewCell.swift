//
//  MyMVPBarGraphTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 08/09/16.
//

import UIKit

class MyMVPBarGraphTableViewCell: UITableViewCell {
  
  
  // MARK:  UITableViewCell subclass MyMVPBarGraphTableViewCell widget instance veriable declaration.
  @IBOutlet weak var topView: UIView!
  
  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    topView.layer.cornerRadius = VALUEFIVECORNERRADIUS
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
}
