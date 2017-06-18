//
//  MyMVPJournalTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 13/09/16.
//

import UIKit

class MyMVPJournalTableViewCell: UITableViewCell {
  
  // MARK:  UITableViewCell subclass MyMVPJournalTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelJournalWorkoutTimeAgo: UILabel!
  @IBOutlet weak var labelJournalWorkoutTimeTaken: UILabel!
  @IBOutlet weak var labelJournalWorkoutCalorieBurned: UILabel!
  @IBOutlet weak var labelJournalWorkoutDistanceCovered: UILabel!
  @IBOutlet weak var buttonFacebookShare: UIButton!
  @IBOutlet weak var buttonJournalWorkout: UIButton!

  
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