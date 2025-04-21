//
//  TimelineScheduler.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 07/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Foundation

enum ShichenTimeLineSceduler {
  static func buildTimeLine() -> [Date] {
    var timeline = [Date]()
    let currentDate = Date()

    timeline.append(currentDate)

    guard
      let currentShichen = currentDate.shichen
    else {
      return backup()
    }
    let nextShichenStart = currentShichen.nextStartDate

    for hourOffset in 0 ..< 11 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: nextShichenStart) ?? Date()
      timeline.append(entryDate)
    }
    return timeline
  }

  static func backup() -> [Date] {
    let currentDate = Date()
    var timeline = [Date]()
    for hourOffset in 0 ..< 11 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) ?? Date()
      timeline.append(entryDate)
    }
    return timeline
  }
}
