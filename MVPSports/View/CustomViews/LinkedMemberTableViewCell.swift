//
//  LinkedMemberTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 02/11/16.
//

import UIKit

class LinkedMemberTableViewCell: UITableViewCell {
  
  
  // MARK:  UITableViewCell subclass LoginTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelMemberName: UILabel!
  @IBOutlet weak var buttonChooseMember: UIButton!

  
  
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
