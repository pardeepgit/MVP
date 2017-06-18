//
//  DrawerTableViewCell.swift
//  CommonTableView
//
//  Created by Chetu India on 24/09/16.
//

import UIKit


/*
 * DrawerTableViewCell subclass of UITableViewCell declaration with overrided method with class instance method declaration.
 */
class DrawerTableViewCell: UITableViewCell {
  
  // MARK:  instance variables, constant decalaration and define with infer type with default values.
  var labelMenuOption: UILabel!
  var viewBottomLine: UIView!


  /*
   * default paramerized overrided contsructor method to initiate the drawer frame view.
   */
  // MARK: -  parametrized overrided constructor method.
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  /*
   * default paramerized overrided contsructor method to initiate the drawer frame view.
   *
   */
  // MARK: -  parametrized overrided constructor method.
  required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = CLEARCOLOR
    self.contentView.backgroundColor =  CLEARCOLOR
    
    labelMenuOption = UILabel()
    labelMenuOption.backgroundColor = CLEARCOLOR
    labelMenuOption.textAlignment = .Left
    labelMenuOption.textColor = WHITECOLOR
    labelMenuOption.font = UIFont.systemFontOfSize(16.0)
    
    viewBottomLine = UIView()
    viewBottomLine.backgroundColor = DARKGRAYCOLOR
    
    self.contentView.addSubview(labelMenuOption)
    self.contentView.addSubview(viewBottomLine)
  }
  
  
  // MARK: -  setLabelFrame method.
  func setLabelFrame(frame: CGRect) {
    labelMenuOption.frame = frame
  }
  
  // MARK: -  setBottomLinelViewFrame method.
  func setBottomLinelViewFrame(frame: CGRect) {
    viewBottomLine.frame = frame
  }

  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
}
