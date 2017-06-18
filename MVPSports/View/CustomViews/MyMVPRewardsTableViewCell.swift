//
//  MyMVPRewardsTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 18/08/16.
//

import UIKit


class MyMVPRewardsTableViewCell: UITableViewCell {

  // MARK:  UITableViewCell subclass MyMVPRewardsTableViewCell widget instance veriable declaration.
  @IBOutlet weak var viewElementSuperView: UIView!
  @IBOutlet weak var labelRewardsDescription: UILabel!
  @IBOutlet weak var labelRewardsUsedDate: UILabel!
  @IBOutlet weak var buttonView: UIButton!
  @IBOutlet weak var buttonSend: UIButton!
  
  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    buttonSend.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    buttonSend.layer.masksToBounds = true

    buttonView.layer.cornerRadius = VALUEEIGHTCORNERRADIUS
    buttonView.layer.masksToBounds = true
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
}
