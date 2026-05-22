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
    let upcoming = nextJieqi
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
