//
//  MyMVPRewardsFilterOptionTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 19/09/16.
//

import UIKit

class MyMVPRewardsFilterOptionTableViewCell: UITableViewCell {

  
  // MARK:  UITableViewCell subclass MyMVPRewardsFilterOptionTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelRewardsFilterOption: UILabel!
  
  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  // MARK:  setSelected method.
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }

}