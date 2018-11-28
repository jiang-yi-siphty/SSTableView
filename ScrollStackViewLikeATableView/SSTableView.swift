//
//  ScrollStackMockTableView.swift
//  ScrollStackViewLikeATableView
//
//  Created by Yi JIANG on 27/11/18.
//  Copyright © 2018 Yi JIANG. All rights reserved.
//

import Foundation
import UIKit

extension SSTableView {
  
  public enum Style : Int {
    case plain
    case grouped
  }
  
  
  public enum ScrollPosition : Int {
    case none
    case top
    case middle
    case bottom
  }
  
  @objc public enum SizeMatching: Int {
    case Width, Height, Both, None
  }
}


@objc public protocol SSTableViewDelegate {
  
  @objc optional func tableView(_ tableView: SSTableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  @objc optional func tableView(_ tableView: SSTableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
  @objc optional func tableView(_ tableView: SSTableView, didSelectRowAt indexPath: IndexPath)
  @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)

}

@objc public protocol SSTableViewDataSource {
  func tableView(_ tableView: SSTableView, numberOfRowsInSection section: Int) -> Int
  func tableView(_ tableView: SSTableView, cellForRowAt indexPath: IndexPath) -> UIViewController
  @objc optional func numberOfSections(in tableView: SSTableView) -> Int // Default is 1 if not implemented
  @objc optional func tableView(_ tableView: SSTableView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
  @objc optional func tableView(_ tableView: SSTableView, titleForFooterInSection section: Int) -> String?
}

public class SSTableView : UIScrollView, UIScrollViewDelegate {
  
  weak var dataSource: SSTableViewDataSource?
  weak var tableDelegate: SSTableViewDelegate?
  
  var style: SSTableView.Style = .plain
  var rowHeight: CGFloat = 44.0
  @IBOutlet var stackView: UIStackView!
  
  override init(frame: CGRect) {
    //TODO: get
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    tableDelegate?.scrollViewDidScroll?(scrollView)
  }
  
  //MARK: - Properties
  @IBInspectable var sizeMatching = SizeMatching.Width
  
  //MARK: - Lifecycle
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    if let contentView = stackView {
      if (contentView.superview != self) {
        self.addSubview(contentView)
      }
      
      var size = contentView.bounds.size
      
      switch self.sizeMatching {
      case .Width:    size.width = self.bounds.width
      case .Height:   size.height = self.bounds.height
      case .Both:     size.width = self.bounds.width; size.height = self.bounds.height
      case .None:     break
      }
      
      contentView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
      self.contentSize = size
    }
  }
  
  func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UIViewController {
    let viewController: UIViewController
    
    return
    
  }
}

