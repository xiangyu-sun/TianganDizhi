//
//  TimelineScheduler.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 07/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import Foundation
import ChineseAstrologyCalendar

struct TimeLineSceduler {
    static func buildTimeLine() -> [Date]{
        var timeline = [Date]()
        let currentDate = Date()
    
        timeline.append(currentDate)
        
        guard let currentShichen = try? GanzhiDateConverter.shichen(currentDate),
              let nextShichenStart = currentShichen.next.startDateComponent else {
            return backup()
        }
        
        for hourOffset in 1 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset * 2, to: nextShichenStart)!
            timeline.append(entryDate)
        }
        return timeline
    }
    
    
    static func backup() -> [Date] {
        let currentDate = Date()
        var timeline = [Date]()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset * 2, to: currentDate)!
            timeline.append(entryDate)
        }
        return timeline
    }
}
