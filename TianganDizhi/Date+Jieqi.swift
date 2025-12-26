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
  
  
  var jieQiDisplayText: String {
    if let jieqi = Jieqi.current {
      let nextDate = preciseNextSolarTermDate()
      
      let diff = nextDate.dayDifference(Date())
      
      if diff >= 1 && diff <= 14 {
        return "\(Self.formatter.string(from: NSNumber(value: diff)) ?? "")日後\(nextDate.jieqi?.chineseName ?? "")\((nextDate.jieqi?.qi == true) ? "(氣)" : "(節)")"
      } else {
        return jieqi.chineseName
      }
      
    } else {
      return ""
    }
  }
}
