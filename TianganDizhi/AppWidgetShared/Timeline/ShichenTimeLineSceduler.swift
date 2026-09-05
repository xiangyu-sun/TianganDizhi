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

    // A `?? Date()` fallback here would insert "now" — earlier than the
    // already-appended entries — breaking WidgetKit's requirement that
    // timeline entries be strictly increasing. Skipping a failed entry
    // instead just shortens the timeline by one step.
    for hourOffset in 0 ..< 12 {
      if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: nextShichenStart) {
        timeline.append(entryDate)
      }
    }
    return timeline
  }

  static func backup() -> [Date] {
    let currentDate = Date()
    var timeline = [Date]()
    for hourOffset in 0 ..< 12 {
      if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
        timeline.append(entryDate)
      }
    }
    return timeline
  }
}
