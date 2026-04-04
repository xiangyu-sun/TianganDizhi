//
//  File.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//
import Astral
import ChineseAstrologyCalendar
import Foundation




extension Date {
  func dayDifference(_ other: Date) -> Int {
    
    let calendar = Calendar.current

    let date1 = calendar.startOfDay(for: self)
    let date2 = calendar.startOfDay(for: other)
    
    let diff = calendar.dateComponents([.day], from: date2, to: date1).day ?? 0
    
    return diff
  }
  
  static let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "zh-Hant") // Simplified Chinese
    
    return formatter
  }()
  
  
  /// Returns the jieqi that begins at or just after the given solar term date.
  /// `preciseNextSolarTermDate` returns the exact boundary moment; adding 1 second
  /// moves past it so that `date.jieqi` resolves to the new term.
  func nextSolarTermJieqi() -> Jieqi? {
    addingTimeInterval(1).jieqi
  }

  /// Returns the date to display in the Jieqi widget.
  /// If the next solar term occurs today (but later) or within 1–14 days, returns that
  /// future date so the widget can show the correct jieqi for the calendar day;
  /// otherwise returns self (today).
  func jieqiWidgetDisplayDate() -> Date {
    let nextDate = preciseNextSolarTermDate(from: self)
    let days = nextDate.dayDifference(self)
    // days == 0 means the next solar term falls on the same calendar day but later in time
    if (days == 0 && nextDate > self) || (days >= 1 && days <= 14) {
      return nextDate
    } else {
      return self
    }
  }

  var jieQiDisplayText: String {
    let now = Date()
    let nextDate = preciseNextSolarTermDate(from: now)
    let diff = nextDate.dayDifference(now)

    // days == 0: next solar term is later today — treat it as today's jieqi
    if diff == 0 && nextDate > now {
      if let jieqi = nextDate.nextSolarTermJieqi() {
        return jieqi.chineseName
      }
    }

    if let jieqi = now.jieqi ?? Jieqi.current {
      let nextJieqi = jieqi.next
      if diff >= 1 && diff <= 14 {
        return "\(Self.formatter.string(from: NSNumber(value: diff)) ?? "")日後\(nextJieqi.chineseName)\(nextJieqi.qi ? "(氣)" : "(節)")"
      } else {
        return jieqi.chineseName
      }
    } else {
      return ""
    }
  }
}
