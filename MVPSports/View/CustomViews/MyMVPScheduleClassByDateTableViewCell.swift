//
//  MyMVPScheduleClassByDateTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 23/08/16.
//

import UIKit

class MyMVPScheduleClassByDateTableViewCell: UITableViewCell {
  
  
  // MARK:  UITableViewCell subclass MyMVPScheduleClassByDateTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelClassName: UILabel!
  @IBOutlet weak var labelClassDate: UILabel!
  @IBOutlet weak var labelClassInstructor: UILabel!
  @IBOutlet weak var labelClassStartTime: UILabel!
  @IBOutlet weak var buttonFavourite: UIButton!
  @IBOutlet weak var buttonCalender: UIButton!
  @IBOutlet weak var imageViewFavouriteIcon: UIImageView!
  @IBOutlet weak var imageViewCalendarIcon: UIImageView!

  @IBOutlet weak var viewLoggedUserStarCalendarView: UIView!
  @IBOutlet weak var viewUnLoggedUserCalendarView: UIView!
  @IBOutlet weak var imageViewUnLoggedCalendarIcon: UIImageView!
  @IBOutlet weak var buttonUnLoggedCalender: UIButton!

  
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