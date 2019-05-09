//
//  ViewController.swift
//  ScrollStackViewLikeATableView
//
//  Created by Yi JIANG on 27/11/18.
//  Copyright © 2018 Yi JIANG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mockTableView: SSTableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        refreshControl.addTarget(self, action:
            #selector(handleRefreshPulled),
                                 for: UIControl.Event.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mockTableView.tableDelegate = self
        mockTableView.dataSource = self
        mockTableView.reloadData()
        mockTableView.refreshControl = refreshControl
    }
    
    @objc func handleRefreshPulled() {
        mockTableView.setContentOffset(.zero, animated: false)
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { 
            // Do something like call API
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
            }
        }  
    }
    
}

extension ViewController: SSTableViewDelegate, SSTableViewDataSource {
    
    func tableView(_ tableView: SSTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: SSTableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: SSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: SSTableView, cellForRowAt indexPath: IndexPath) -> SSTableViewCell {
        if let cell = tableView.dequeueCell(withNibName: "DemoView", for: indexPath) {
            cell.title = "This is a SSTableViewCell in a stack view"
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let contentViewController = storyboard.instantiateViewController(withIdentifier: "DemoContainerViewContent")
            addChild(contentViewController)
            cell.containerView.addSubview(contentViewController.view)
            contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentViewController.view.topAnchor.constraint(equalTo: cell.containerView.topAnchor),
                contentViewController.view.bottomAnchor.constraint(equalTo: cell.containerView.bottomAnchor),
                contentViewController.view.trailingAnchor.constraint(equalTo: cell.containerView.trailingAnchor),
                contentViewController.view.leadingAnchor.constraint(equalTo: cell.containerView.leadingAnchor)
                ])
            return cell
        }
        return SSTableViewCell()
    }
    
    
    func tableView(_ tableView: SSTableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: \(indexPath)")
    }
    
    
    func tableView(_ tableView: SSTableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header =  UINib(nibName: "SectionHeader",
                                  bundle: nil)
            .instantiate(withOwner: nil,
                         options: nil)[0] as? SectionHeader else { return nil }
        return header
        
    }
    
    func tableView(_ tableView: SSTableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer =  UINib(nibName: "SectionFooter",
                                  bundle: nil)
            .instantiate(withOwner: nil,
                         options: nil)[0] as? SectionFooter else { return nil }
        return footer
        
    }
    
}

