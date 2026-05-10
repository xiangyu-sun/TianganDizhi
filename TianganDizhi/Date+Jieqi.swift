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

  var jieQiDisplayText: String {
    // Use the new package API: nextJieqi returns the upcoming jieqi and how many days until it.
    // days == 0: today IS the jieqi transition day.
    // days 1-14: upcoming within the display window.
    if let upcoming = nextJieqi {
      if upcoming.days == 0 {
        return upcoming.jieqi.chineseName + (upcoming.jieqi.qi ? "氣" : "節")
        
      } else if upcoming.days >= 1 && upcoming.days <= 14 {
        let daysString = Self.formatter.string(from: NSNumber(value: upcoming.days)) ?? ""
        return "\(daysString)日後\(upcoming.jieqi.chineseName)\(upcoming.jieqi.qi ? "氣" : "節")"
        
      }
    }
    // More than 14 days away or nil — show current jieqi name.
    if let current = jieqi ?? Jieqi.current {
      return current.chineseName
    }
    return ""
  }
}
