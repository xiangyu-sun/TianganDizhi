//
//  TodayViewController.swift
//  Today
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var informationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let now = Date()
        informationLabel.text = "\(now.year)\n\(now.shichen)"
        completionHandler(NCUpdateResult.newData)
    }
    
}
