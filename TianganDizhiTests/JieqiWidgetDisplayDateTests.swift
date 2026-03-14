//
//  JieqiWidgetDisplayDateTests.swift
//  TianganDizhiTests
//
//  Created by Xiangyu Sun on 14/3/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import Testing
import Foundation
import Astral
import ChineseAstrologyCalendar
@testable import TianganDizhi

struct JieqiWidgetDisplayDateTests {

  // All dates are constructed at UTC noon so day boundaries are stable across timezones.
  // Boundary values below were verified against preciseNextSolarTermDate using UTC noon timestamps.
  private var utcCalendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    return cal
  }()

  private func utcNoon(year: Int, month: Int, day: Int) throws -> Date {
    let components = DateComponents(calendar: utcCalendar, timeZone: utcCalendar.timeZone,
                                    year: year, month: month, day: day, hour: 12)
    return try #require(components.date)
  }

  // MARK: - >14 days before next jieqi → widget shows today

  @Test("Returns today when next jieqi is more than 14 days away")
  func returnsTodayWhenFarFromNextJieqi() throws {
    // 2025-04-20 UTC noon: 15 days before Lixia (立夏, ~May 5 2025); diff > 14 → returns self
    let today = try utcNoon(year: 2025, month: 4, day: 20)
    let displayDate = today.jieqiWidgetDisplayDate()
    #expect(displayDate == today)
  }

  // MARK: - Within 1–14 days before next jieqi → widget previews upcoming jieqi

  @Test("Returns upcoming jieqi date when next jieqi is within 14 days")
  func returnsUpcomingJieqiWhenWithin14Days() throws {
    // 2025-05-11 UTC noon: 10 days before Xiaoman (小滿, ~May 21 2025); diff = 10 → returns next
    let today = try utcNoon(year: 2025, month: 5, day: 11)
    let displayDate = today.jieqiWidgetDisplayDate()
    let days = displayDate.dayDifference(today)
    #expect(displayDate != today)
    #expect(days >= 1 && days <= 14)
  }

  @Test("Returns upcoming jieqi date when exactly 14 days away")
  func returnsUpcomingJieqiWhenExactly14DaysAway() throws {
    // 2025-04-21 UTC noon: 14 days before Lixia (~May 5 2025); diff = 14 → returns next
    let today = try utcNoon(year: 2025, month: 4, day: 21)
    let displayDate = today.jieqiWidgetDisplayDate()
    let days = displayDate.dayDifference(today)
    #expect(displayDate != today)
    #expect(days == 14)
  }

  @Test("Returns upcoming jieqi date when 1 day away")
  func returnsUpcomingJieqiWhenOneDayAway() throws {
    // 2025-04-18 UTC noon: 1 day before Guyu (谷雨, Apr 19 UTC); diff = 1 → returns next
    let today = try utcNoon(year: 2025, month: 4, day: 18)
    let displayDate = today.jieqiWidgetDisplayDate()
    let days = displayDate.dayDifference(today)
    #expect(displayDate != today)
    #expect(days == 1)
  }
}
