//
//  File.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//
import ChineseAstrologyCalendar
import Foundation

extension Date {
  static let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "zh-Hant")
    return formatter
  }()

  /// The last instant of this date's local calendar day.
  ///
  /// Seeding solar-term math here keeps the day count calendar-stable. The
  /// package's `isJieqiDay`/`nextJieqi` are *instant*-sensitive (a transition
  /// counts on day `D` only once its astronomical moment has passed), so a
  /// midnight seed pushes a same-day morning transition onto the following
  /// day. Evaluating at end of day makes every transition land on its own
  /// calendar day regardless of the time the calculation runs — this is what
  /// kept the main screen (real-time seed) and the Jieqi medium widget
  /// (`DailyTimeLineSceduler` midnight seed) one day apart.
  var endOfLocalDay: Date {
    let calendar = Calendar.current
    let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: self)) ?? self
    return startOfNextDay.addingTimeInterval(-1)
  }

  /// `nextJieqi` evaluated at a calendar-stable point in the day, so the
  /// returned day count does not depend on the time of day it is computed.
  var nextJieqiDayAligned: (jieqi: Jieqi, days: Int)? {
    endOfLocalDay.nextJieqi
  }

  var jieQiDisplayText: String {
    let upcoming = nextJieqiDayAligned
    if let upcoming, upcoming.days > 0 {
      let daysString = Self.formatter.string(from: NSNumber(value: upcoming.days)) ?? ""
      return "\(daysString)日後\(upcoming.jieqi.chineseName)\(upcoming.jieqi.qi ? "氣" : "節")"
    }
    if let current = upcoming?.jieqi ?? jieqi ?? Jieqi.current {
      return current.chineseName + (current.qi ? "氣" : "節")
    }
    return ""
  }
}
