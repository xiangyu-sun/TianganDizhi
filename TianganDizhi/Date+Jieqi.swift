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
  var jieQiDisplayText: String {
    if let jieqi = Jieqi.current {
      let nextDate = preciseNextSolarTermDate()

      let interval = nextDate.timeIntervalSince(Date())
      let days = Int(round(interval / 86_400)) // floor of full days

      if days >= 1 && days <= 14 {
        return "\(days)日後\(nextDate.jieqi?.chineseName ?? "")"
      } else {
        return jieqi.chineseName
      }

    } else {
      return ""
    }
  }
}
