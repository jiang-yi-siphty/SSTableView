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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mockTableView.tableDelegate = self
    mockTableView.dataSource = self
    mockTableView.reloadData()
  }


}

extension ViewController: SSTableViewDelegate, SSTableViewDataSource {
  
  func tableView(_ tableView: SSTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 200
  }
  
  func tableView(_ tableView: SSTableView, numberOfRowsInSection section: Int) -> Int {
    return 13
  }
  
  func tableView(_ tableView: SSTableView, cellForRowAt indexPath: IndexPath) -> SSTableViewCell {
    if let cell = tableView.dequeueCell(withIdentifier: "DemoView", for: indexPath)  {
      cell.title = "I SSTableViewCell in a stack view"
      
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
  
  
}
