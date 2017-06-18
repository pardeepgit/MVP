//
//  MyMVPAccountInfoTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 31/08/16.
//

import UIKit

class MyMVPAccountInfoTableViewCell: UITableViewCell {

  
  // MARK:  UITableViewCell subclass MyMVPAccountInfoTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelAccountTitle: UILabel!
  @IBOutlet weak var viewBottomLine: UIView!

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
