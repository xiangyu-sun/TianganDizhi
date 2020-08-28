//
//  TodayViewController.swift
//  Today
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import UIKit
import NotificationCenter
import ChineseAstrologyCalendar

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let now = Date()
        do {
            let year = try GanzhiDateConverter.nian(now).formatedYear
            let zodiac = try GanzhiDateConverter.zodiac(now)
            informationLabel.text = "\(year)\n\(zodiac)"
            let dizhi = try GanzhiDateConverter.shichen(now)
            yearLabel.text = dizhi.displayHourText
        } catch {
            
        }
        
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
