//
//  MyMVPCommentCardSelectOptionTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 09/11/16.
//

import UIKit

class MyMVPCommentCardSelectOptionTableViewCell: UITableViewCell {
  
  // MARK:  UITableViewCell subclass MyMVPCommentCardSelectOptionTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelSelectOption: UILabel!
  
  
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
