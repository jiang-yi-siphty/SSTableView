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

@objc public protocol SSTableViewDelegate {
    
    @objc optional func tableView(_ tableView: SSTableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    @objc optional func tableView(_ tableView: SSTableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    @objc optional func tableView(_ tableView: SSTableView, didSelectRowAt indexPath: IndexPath)
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func tableView(_ tableView: SSTableView, heightForHeaderInSection section: Int) -> CGFloat
    @objc optional func tableView(_ tableView: SSTableView, heightForFooterInSection section: Int) -> CGFloat
    @objc optional func tableView(_ tableView: SSTableView, viewForHeaderInSection section: Int) -> UIView?
    @objc optional func tableView(_ tableView: SSTableView, viewForFooterInSection section: Int) -> UIView?
    @objc optional func tableView(_ tableView: SSTableView, didTapFotterInSection section: Int)
    @objc optional func tableView(_ tableView: SSTableView, didTapHeaderInSection section: Int)
    
}

@objc public protocol SSTableViewDataSource {
    func tableView(_ tableView: SSTableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: SSTableView, cellForRowAt indexPath: IndexPath) -> SSTableViewCell
    @objc optional func tableView(_ tableView: SSTableView, moduleForSectionAt section: Int) -> SSTableViewSectionModuleCapable?
    @objc optional func numberOfSections(in tableView: SSTableView) -> Int
    @objc optional func tableView(_ tableView: SSTableView, titleForHeaderInSection section: Int) -> String?
    @objc optional func tableView(_ tableView: SSTableView, titleForFooterInSection section: Int) -> String?
    @objc optional func didAddModule(_ module: SSTableViewSectionModuleCapable)
    @objc optional func didRemoveModule(_ module: SSTableViewSectionModuleCapable)
}

@objc public protocol SSTableViewSectionModuleCapable: class {
    func prepareModule()
}

public class SSTableView: UIScrollView, UIScrollViewDelegate {
    
    static let automaticDimension: CGFloat = -1.0
    
    enum TagShift: Int {
        case module = 1000
        case header = 2000
        case footer = 3000
    }
    
    enum Constants {
        static let rowHeight: CGFloat = SSTableView.automaticDimension
        static let sectionHeaderFooterHeight: CGFloat = 0.0
        static let sectionGapHeight: CGFloat = 16.0
        static let leadingSpace: CGFloat = 5.0
        static let padding: CGFloat = 16.0
    }
    
    private var moduleDict = [Int: SSTableViewSectionModuleCapable]()
    
    weak var dataSource: SSTableViewDataSource?
    weak var tableDelegate: SSTableViewDelegate?
    
    var bottomPadding: CGFloat?
    
    var style: SSTableView.Style = .plain
    var rowHeight = Constants.rowHeight
    var sectionGap = Constants.sectionGapHeight
    var sectionGapColour = UIColor.clear
    
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
        moduleDict.forEach {
            if let viewController = $0.value as? UIViewController {
                viewController.removeFromParent()
            }
            dataSource?.didRemoveModule?( $0.value )
        }
        moduleDict.removeAll()
        prepareTableView()
    }
    
    private func prepareTableView(){
        let sectionNumber: Int = dataSource?.numberOfSections?(in: self) ?? 1
        for sectionIndex in 0..<sectionNumber {
            if let numberOfRows: Int = dataSource?.tableView(self, numberOfRowsInSection: sectionIndex) {
                stackView.addArrangedSubview(prepareSectionHeader(inSection: sectionIndex))
                
                for rowIndex in 0..<numberOfRows {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    if let cell = dataSource?.tableView(self, cellForRowAt: indexPath) {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTouchUpInside(_:)))
                        cell.addGestureRecognizer(tapGesture)
                        stackView.addArrangedSubview(cell)
                    }
                }
                
                if let module = dataSource?.tableView?(self, moduleForSectionAt: sectionIndex) {
                    if addModuleToSection(module, at: sectionIndex) {
                        dataSource?.didAddModule?(module)
                    }
                    module.prepareModule()
                }
                
                stackView.addArrangedSubview(prepareSectionFooter(inSection: sectionIndex))
                let sectionGapView = prepareSectionGap()
                stackView.addArrangedSubview(sectionGapView)
            }
        }
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: bottomPadding ?? Constants.padding))
        stackView.addArrangedSubview(paddingView)
    }
    
    private func addModuleToSection(_ module: SSTableViewSectionModuleCapable, at section: Int) -> Bool{
        if let cell = stackView
            .arrangedSubviews
            .first(where: { ($0 as? SSTableViewCell)?.indexPath == IndexPath(row: 0, section: section) })
            as? SSTableViewCell,
            let viewController = module as? UIViewController {
            let moduleTag = section + TagShift.module.rawValue
            viewController.view.tag = moduleTag
            if (cell.subviews.first{$0.tag == viewController.view.tag}) == nil {
                cell.gestureRecognizers?.forEach{cell.removeGestureRecognizer($0)}
                cell.addSubview(viewController.view)
                viewController.view.translatesAutoresizingMaskIntoConstraints = false
                viewController.view.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
                viewController.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
                viewController.view.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
                viewController.view.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
                moduleDict[moduleTag] = module
                return true
            }
        }
        return false
    }
    
    private func prepareSectionHeader(inSection section: Int) -> UIView {
        if let headerView = tableDelegate?.tableView?(self, viewForHeaderInSection: section) {
            let headerViewHeight = headerView.frame.height
            headerView.tag = section + TagShift.header.rawValue
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
            headerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: headerViewHeight)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedModuleHeader(_:)))
            headerView.addGestureRecognizer(tapGesture)
            return headerView
        } else {
            let headerView = UIView()
            headerView.tag = section + TagShift.header.rawValue
            let headerViewHeight = tableDelegate?.tableView?(self, heightForHeaderInSection: section) ?? Constants.sectionHeaderFooterHeight
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
            headerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: headerViewHeight)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedModuleHeader(_:)))
            headerView.addGestureRecognizer(tapGesture)
            let titleLabel = UILabel()
            headerView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.leadingSpace)
                ])
            return headerView
        }
    }
    
    private func prepareSectionFooter(inSection section: Int) -> UIView {
        if let footerView =  tableDelegate?.tableView?(self, viewForFooterInSection: section) {
            let footerViewHeight = footerView.frame.height
            footerView.tag = section + TagShift.footer.rawValue
            footerView.translatesAutoresizingMaskIntoConstraints = false
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true
            footerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: footerViewHeight)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedModuleFooter(_:)))
            footerView.addGestureRecognizer(tapGesture)
            return footerView
        } else {
            let footerView = UIView()
            let footerViewHeight = tableDelegate?.tableView?(self, heightForFooterInSection: section) ?? Constants.sectionHeaderFooterHeight
            footerView.tag = section + TagShift.footer.rawValue
            footerView.translatesAutoresizingMaskIntoConstraints = false
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true
            footerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: footerViewHeight)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedModuleFooter(_:)))
            footerView.addGestureRecognizer(tapGesture)
            let titleLabel = UILabel()
            footerView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Constants.sectionGapHeight)
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
    
    func dequeueCell(withNibName identifier: String?, for indexPath: IndexPath) -> SSTableViewCell? {
        if let cell = cellForRow(at: indexPath) { return cell }
        guard let identifier = identifier,
            let ssTableViewCell = UINib(nibName: identifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SSTableViewCell else { return nil }
        ssTableViewCell.indexPath = indexPath
        ssTableViewCell.translatesAutoresizingMaskIntoConstraints = false
        let height = tableDelegate?.tableView?(self, heightForRowAt: indexPath) ?? SSTableView.automaticDimension
        if height == SSTableView.automaticDimension {
            if let subView = ssTableViewCell.subviews.max(by: { $0.frame.height < $1.frame.height })
            {
                ssTableViewCell.heightAnchor.constraint(equalTo: subView.heightAnchor).isActive = true
            }
        } else {
            ssTableViewCell.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        ssTableViewCell.isUserInteractionEnabled = true
        return ssTableViewCell
    }
    
    func cellForRow(at indexPath: IndexPath) -> SSTableViewCell? {
        return stackView.arrangedSubviews.first { ($0 as? SSTableViewCell)?.indexPath == indexPath
            } as? SSTableViewCell
    }
    
    @objc private func cellTouchUpInside(_ gesture: UITapGestureRecognizer) {
        if let indexPath = (gesture.view as? SSTableViewCell)?.indexPath {
            tableDelegate?.tableView?(self, didSelectRowAt: indexPath)
        }
    }
}

// MARK: - Support Module
extension SSTableView {
    
    func reloadModule(at section: Int) {
        if let module = moduleDict[section + TagShift.module.rawValue] {
            module.prepareModule()
        } else if let module = dataSource?.tableView?(self, moduleForSectionAt: section) {
            if addModuleToSection(module, at: section){
                dataSource?.didAddModule?(module)
                module.prepareModule()
            }
        }
        _ = dataSource?.tableView(self, cellForRowAt: IndexPath(row: 0, section: section))
    }
    
    @objc func tappedModuleFooter(_ gesture: UITapGestureRecognizer) {
        guard let sectionTag = gesture.view?.tag else { return }
        let section = sectionTag - TagShift.footer.rawValue
        tableDelegate?.tableView?(self, didTapFotterInSection: section)
    }
    
    @objc func tappedModuleHeader(_ gesture: UITapGestureRecognizer) {
        guard let sectionTag = gesture.view?.tag else { return }
        let section = sectionTag - TagShift.header.rawValue
        tableDelegate?.tableView?(self, didTapHeaderInSection: section)
    }
    
}
