//
//  File.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//
import Foundation
import Astral
import ChineseAstrologyCalendar

extension Date {
  var jieQiText: String {
    if let jieqi = Jieqi.current {
      let nextDate = preciseNextSolarTermDate()
    
      let interval = nextDate.timeIntervalSince(Date())
      let days = Int(ceil(interval / 86_400))  // floor of full days
      
      if days < 14 {
        return "\(days)天之後\(nextDate.jieqi?.chineseName ?? "")"
      } else {
        return jieqi.chineseName
      }
      
    } else {
      return ""
    }
  }
}
