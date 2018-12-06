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
  
  public enum Style: Int {
    case plain
    case grouped
  }
  
  public enum ScrollPosition: Int {
    case none
    case top
    case middle
    case bottom
  }
  
  // scroll so row of interest is completely visible at top/center/bottom of view
  public enum RowAnimation: Int {
    case fade
    case right // slide in from right (or out to right)
    case left
    case top
    case bottom
    case none
    case middle // attempts to keep cell centered in the space it will/did occupy
    case automatic // chooses an appropriate animation style for you
  }
}

enum SSTableViewRowHeight {
  static let `default`: CGFloat = 44.0
}

enum SSTableViewSectionGapHeight {
  static let `default`: CGFloat = 16.0
}

enum SSTableViewLeadingSpace {
  static let `default`: CGFloat = 5.0
}

@objc public protocol SSTableViewDelegate {
  
  @objc optional func tableView(_ tableView: SSTableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  @objc optional func tableView(_ tableView: SSTableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
  @objc optional func tableView(_ tableView: SSTableView, didSelectRowAt indexPath: IndexPath)
  @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
  @objc optional func tableView(_ tableView: SSTableView, heightForHeaderInSection section: Int) -> CGFloat
  @objc optional func tableView(_ tableView: SSTableView, heightForFooterInSection section: Int) -> CGFloat
  @objc optional func tableView(_ tableView: SSTableView, viewForHeaderInSection section: Int) -> UIView?
  @objc optional func tableView(_ tableView: SSTableView, viewForFooterInSection section: Int) -> UIView?
  
}

@objc public protocol SSTableViewDataSource {
  func tableView(_ tableView: SSTableView, numberOfRowsInSection section: Int) -> Int
  func tableView(_ tableView: SSTableView, cellForRowAt indexPath: IndexPath) -> SSTableViewCell
  @objc optional func tableView(_ tableView: SSTableView, moduleForSectionAt section: Int) -> SSTableViewSectionModuleCapable?
  @objc optional func numberOfSections(in tableView: SSTableView) -> Int
  @objc optional func tableView(_ tableView: SSTableView, titleForHeaderInSection section: Int) -> String?
  @objc optional func tableView(_ tableView: SSTableView, titleForFooterInSection section: Int) -> String?
}

@objc public protocol SSTableViewSectionModuleCapable {
  func prepareModule()
}

public class SSTableView: UIScrollView, UIScrollViewDelegate {
  
  weak var dataSource: SSTableViewDataSource?
  weak var tableDelegate: SSTableViewDelegate?
  
  var style: SSTableView.Style = .plain
  var rowHeight = SSTableViewRowHeight.default
  var sectionGap = SSTableViewSectionGapHeight.default
  var sectionGapColour = UIColor.clear
  //  var tapGesture: UIGestureRecognizer?
  
  @IBOutlet var stackView: UIStackView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func scrollViewDidScroll(_ scrollView: UIScrollView) {
    tableDelegate?.scrollViewDidScroll?(scrollView)
  }
  
  func reloadData(){
    stackView.arrangedSubviews.forEach { view in
      view.removeFromSuperview()
    }
    prepareTableView()
    layoutSubviews()
  }
  
  private func prepareTableView(){
    let sectionNumber: Int = dataSource?.numberOfSections?(in: self) ?? 1
    for sectionIndex in 0..<sectionNumber {
      if let numberOfRows: Int = dataSource?.tableView(self, numberOfRowsInSection: sectionIndex) {
        stackView.addArrangedSubview(prepareSectionHeader(inSection: sectionIndex))
        for rowIndex in 0..<numberOfRows {
          let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
          if let cell = dataSource?.tableView(self, cellForRowAt: indexPath) {
            stackView.addArrangedSubview(cell)
          }
          
        }
        dataSource?.tableView?(self, moduleForSectionAt: sectionIndex)?.prepareModule()
        stackView.addArrangedSubview(prepareSectionFooter(inSection: sectionIndex))
        let sectionGapView = prepareSectionGap()
        stackView.addArrangedSubview(sectionGapView)
      }
    }
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height/2))
    stackView.addArrangedSubview(paddingView)
  }
  
  private func prepareSectionHeader(inSection section: Int) -> UIView {
    if let headerView = tableDelegate?.tableView?(self, viewForHeaderInSection: section) {
      let headerViewHeight = headerView.frame.height
      headerView.translatesAutoresizingMaskIntoConstraints = false
      headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
      headerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: headerViewHeight)
      return headerView
    } else {
      let headerView = UIView()
      let headerViewHeight = tableDelegate?.tableView?(self, heightForHeaderInSection: section) ?? SSTableViewRowHeight.default
      headerView.translatesAutoresizingMaskIntoConstraints = false
      headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
      headerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: headerViewHeight)
      let titleLabel = UILabel()
      headerView.addSubview(titleLabel)
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: SSTableViewLeadingSpace.default)
        ])
      return headerView
    }
  }
  
  private func prepareSectionFooter(inSection section: Int) -> UIView {
    if let footerView =  tableDelegate?.tableView?(self, viewForFooterInSection: section) {
      let footerViewHeight = footerView.frame.height
      footerView.translatesAutoresizingMaskIntoConstraints = false
      footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true
      footerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: footerViewHeight)
      return footerView
    } else {
      let footerView = UIView()
      let footerViewHeight = tableDelegate?.tableView?(self, heightForFooterInSection: section) ?? SSTableViewRowHeight.default
      footerView.translatesAutoresizingMaskIntoConstraints = false
      footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true
      footerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: footerViewHeight)
      let titleLabel = UILabel()
      footerView.addSubview(titleLabel)
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        titleLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
        titleLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: SSTableViewLeadingSpace.default)
        ])
      return footerView
      
    }
  }
  
  private func prepareSectionGap() -> UIView {
    let sectionGapView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: sectionGap))
    sectionGapView.backgroundColor = sectionGapColour
    sectionGapView.translatesAutoresizingMaskIntoConstraints = false
    sectionGapView.heightAnchor.constraint(equalToConstant: sectionGap).isActive = true
    return sectionGapView
  }
  
  func dequeueCell(withNibName identifier: String, for indexPath: IndexPath) -> SSTableViewCell? {
    guard let ssTableViewCell = UINib(nibName: identifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SSTableViewCell else { return nil }
    ssTableViewCell.indexPath = indexPath
    let height = tableDelegate?.tableView?(self, heightForRowAt: indexPath)
    ssTableViewCell.translatesAutoresizingMaskIntoConstraints = false
    ssTableViewCell.heightAnchor.constraint(equalToConstant: height ?? SSTableViewRowHeight.default).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTouchUpInside(_:)))
        tapGesture.delegate = self
        ssTableViewCell.addGestureRecognizer(tapGesture)
    ssTableViewCell.isUserInteractionEnabled = true
    return ssTableViewCell
  }
  
  func cellForRow(at indexPath: IndexPath) -> SSTableViewCell? {
    return self.stackView.arrangedSubviews.first { ($0 as? SSTableViewCell)?.indexPath == indexPath
      } as? SSTableViewCell
  }
  
  @objc private func cellTouchUpInside(_ gesture: UITapGestureRecognizer) {
    if let indexPath = (gesture.view as? SSTableViewCell)?.indexPath {
      tableDelegate?.tableView?(self, didSelectRowAt: indexPath)
    }
  }
}

extension SSTableView: UIGestureRecognizerDelegate {
  
  //  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
  //                                         shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
  //    print("=====================")
  //    print("gestureRecognizer: \(gestureRecognizer.view!)")
  //    print("otherGestureRecognizer: \(otherGestureRecognizer.view!)")
  //
  //    return false
  //  }
  //
  //  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
  //    return false
  //  }
  
  //  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
  //    if (gestureRecognizer is UITapGestureRecognizer) {
  //      return true
  //    } else {
  //      return false
  //    }
  //  }
  
  //  override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
  ////    if gestureRecognizer == tapGesture {
  ////      gestureRecognizer.
  ////    }
  //    print("gestureRecognizer : \(gestureRecognizer)")
  //    return false
  //  }
  
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    
    return stackView.arrangedSubviews.reduce(true) { (result, view) -> Bool in
      if (touch.view?.isDescendant(of: view))!,
        gestureRecognizer.isKind(of: UITapGestureRecognizer.self),
        view.isKind(of: SSTableViewCell.self)
      {
        return result && false
      } else {
        return result
      }
    }
  }
}

// MARK: - Support Module
extension SSTableView {
  
  func reloadModules(at section: Int) {
    dataSource?.tableView?(self, moduleForSectionAt: section)?.prepareModule()
  }
  
}
