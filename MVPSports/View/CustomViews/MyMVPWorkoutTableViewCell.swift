//
//  MyMVPWorkoutTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 13/09/16.
//

import UIKit

class MyMVPWorkoutTableViewCell: UITableViewCell {

  // MARK:  UITableViewCell subclass MyMVPWorkoutTableViewCell widget instance veriable declaration.
  @IBOutlet weak var buttonWorkoutEdit: UIButton!

  @IBOutlet weak var labelWorkoutName: UILabel!
  @IBOutlet weak var textFieldWorkoutCalorie: UITextField!
  @IBOutlet weak var textFieldWorkoutDuration: UITextField!
  @IBOutlet weak var textFieldWorkoutDistance: UITextField!
  @IBOutlet weak var textFieldWorkoutSteps: UITextField!

  
  /*
   * Method awakeFromNib to sset default property on UI widget elements.
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