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
    
  }


}

extension ViewController: SSTableViewDelegate, SSTableViewDataSource {
  
  func tableView(_ tableView: SSTableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: SSTableView, cellForRowAt indexPath: IndexPath) -> UIViewController {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DemoViewID", for: indexPath)
    return cell
  }
  
  
}
