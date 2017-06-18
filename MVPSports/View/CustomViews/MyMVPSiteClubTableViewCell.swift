//
//  MyMVPSiteClubTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 26/09/16.
//

import UIKit

class MyMVPSiteClubTableViewCell: UITableViewCell {

  // MARK:  UITableViewCell subclass MyMVPSiteClubTableViewCell widget instance veriable declaration.
  @IBOutlet weak var labelLocationTitle: UILabel!
  @IBOutlet weak var labelCity: UILabel!
  @IBOutlet weak var labelDistanceInMile: UILabel!
  @IBOutlet weak var imageViewUserFavourite: UIImageView!
  @IBOutlet weak var imageViewDistance: UIImageView!
  @IBOutlet weak var imageViewDetailArrow: UIImageView!
  @IBOutlet weak var buttonGoToDetail: UIButton!
  @IBOutlet weak var buttonSetDefaultSiteClub: UIButton!

  
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