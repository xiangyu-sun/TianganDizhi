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

    let components1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    let components2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: other)
    
    if let date1 = calendar.date(from: components1),
       let date2 = calendar.date(from: components2) {
      
      let diff = calendar.dateComponents([.day], from: date2, to: date1).day ?? 0
     
      return diff
    }
    
    return 0
  }
  
  
  var jieQiDisplayText: String {
    if let jieqi = Jieqi.current {
      let nextDate = preciseNextSolarTermDate()
      
      let diff = nextDate.dayDifference(Date())
      
      if diff >= 1 && diff <= 14 {
        return "\(diff)日後\(nextDate.jieqi?.chineseName ?? "")"
      } else {
        return jieqi.chineseName
      }
      
    } else {
      return ""
    }
  }
}
