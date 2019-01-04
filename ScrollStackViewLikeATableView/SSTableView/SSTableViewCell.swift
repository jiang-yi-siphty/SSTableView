//
//  SSTableViewCell.swift
//  ScrollStackViewLikeATableView
//
//  Created by Yi JIANG on 28/11/18.
//  Copyright © 2018 Yi JIANG. All rights reserved.
//

import Foundation
import UIKit

public class SSTableViewCell: UIView {
  var title: String = "Title" {
    didSet {
      titleLabel.text = title
    }
  }
  var height: CGFloat = 44
  var indexPath = IndexPath(row: 0, section: 0)
  @IBOutlet var containerView: UIView!
  @IBOutlet var titleLabel: UILabel!
  
  
}
