//
//  LoginTableViewCell.swift
//  MVPSports
//
//  Created by Chetu India on 09/08/16.
//

import UIKit

class LoginTableViewCell: UITableViewCell {
  
  
  // MARK:  UITableViewCell subclass LoginTableViewCell widget instance veriable declaration.
  @IBOutlet weak var textFieldEntries: UITextField!

  
  /*
   * Method awakeFromNib to set default property on UI widget elements.
   */
  // MARK:  awakeFromNib method.
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    // Code to make rround rect of textFieldEntries.
    textFieldEntries.layer.cornerRadius = VALUEFIVECORNERRADIUS
    
    // Code to set left padding to the textFieldEntries for the text enter value.
    let paddingView = UIView(frame: CGRectMake(0, 0, 10, textFieldEntries.frame.height))
    textFieldEntries.leftView = paddingView
    textFieldEntries.leftViewMode = UITextFieldViewMode.Always
    
    // Code to set font value to the textFieldEntries.
    textFieldEntries.font = LOGINFIELDFONT
  }
  
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
}
