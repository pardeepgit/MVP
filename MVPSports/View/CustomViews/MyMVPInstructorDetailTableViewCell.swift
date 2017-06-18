//
//  MyMVPInstructorDetailTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 24/10/16.
//

import UIKit

class MyMVPInstructorDetailTableViewCell: UITableViewCell {
  
  // MARK:  UITableViewCell subclass MyMVPInstructorDetailTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelInstructorDetailTitle: UILabel!
  @IBOutlet weak var labelInstructorDetailValue: UILabel!
  @IBOutlet weak var viewTopHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var labelTitleHeightConstraint: NSLayoutConstraint!

  
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