//
//  Date+ShichenProgress.swift
//  TianganDizhi
//
//  Created by Claude Code
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Foundation

extension Date {
  /// Progress through the current Ke (0.0 to 1.0).
  var keProgress: Double {
    guard let shichen else { return 0.0 }
    let elapsed = timeIntervalSince1970 - shichen.startDate.timeIntervalSince1970
    let keElapsed = elapsed - Double(shichen.currentKe) * Shichen.keLength
    return min(max(keElapsed / Shichen.keLength, 0.0), 1.0)
  }

  /// Start of the next Shichen.
  var nextShichenTime: Date {
    shichen?.nextStartDate ?? self
  }

  /// Countdown string to next Shichen.
  var nextShichenCountdown: String {
    guard let shichen else { return "" }
    let nextTime = shichen.nextStartDate
    let nextDizhi = shichen.dizhi.next
    let nextName = nextDizhi.localizedHourName(in: DisplayLanguage.app.glyphLanguage)
    let totalSeconds = Int(nextTime.timeIntervalSince(self))
    guard totalSeconds > 0 else { return nextName }
    let hours = totalSeconds / 3600
    let mins = (totalSeconds % 3600) / 60
    if hours == 0 {
      return String(localized: "距離\(nextName)還有 \(mins) 分鐘", comment: "Countdown to the next Shichen; %1$@ is its name (丑時)")
    } else if mins == 0 {
      return String(localized: "距離\(nextName)還有 \(hours) 小時", comment: "Countdown to the next Shichen; %1$@ is its name (丑時)")
    } else {
      return String(localized: "距離\(nextName)還有 \(hours) 小時 \(mins) 分鐘", comment: "Countdown to the next Shichen; %1$@ is its name (丑時)")
    }
  }
}
