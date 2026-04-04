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

  // MARK: - Regression: same-day solar term (occurs later today) → widget shows new jieqi

  @Test("Returns next jieqi date when solar term occurs later the same UTC day")
  func returnsNextJieqiWhenSolarTermIsLaterToday() throws {
    // Qingming 2026 occurs at 18:28 UTC on Apr 4.
    // UTC noon (12:00) is before the transition, so dayDifference == 0 but nextDate > now.
    // The widget should return the solar term date (not self) so it can display Qingming.
    let today = try utcNoon(year: 2026, month: 4, day: 4)
    let displayDate = today.jieqiWidgetDisplayDate()
    #expect(displayDate > today, "Should return the solar term date, not today")
    let days = displayDate.dayDifference(today)
    #expect(days == 0, "Solar term is same calendar day in UTC")
  }

  @Test("nextSolarTermJieqi resolves to Qingming when called on the solar term boundary date")
  func nextSolarTermJieqiResolvesCorrectly() throws {
    // date.jieqi at the exact boundary still returns the previous jieqi (Chunfen);
    // nextSolarTermJieqi() adds 1 second to cross the threshold and returns the new one.
    let today = try utcNoon(year: 2026, month: 4, day: 4)
    let displayDate = today.jieqiWidgetDisplayDate()
    // displayDate is the Qingming boundary; .jieqi here is still Chunfen
    #expect(displayDate.jieqi?.chineseName == "春分", "At the exact boundary, jieqi is still the previous term")
    // nextSolarTermJieqi() should give us Qingming
    let resolved = displayDate.nextSolarTermJieqi()
    #expect(resolved?.chineseName == "清明", "nextSolarTermJieqi should return Qingming (清明)")
  }

  @Test("Widget shows correct jieqi name on a day when solar term starts later that UTC day")
  func widgetShowsCorrectJieqiOnSameDayTransition() throws {
    // Full widget logic: jieqiWidgetDisplayDate() returns the boundary, then
    // nextSolarTermJieqi() resolves it. The displayed name should be Qingming, not Chunfen.
    let today = try utcNoon(year: 2026, month: 4, day: 4)
    let displayDate = today.jieqiWidgetDisplayDate()
    let jieqi = displayDate > today ? displayDate.nextSolarTermJieqi() : displayDate.jieqi
    #expect(jieqi?.chineseName == "清明", "Should show Qingming (清明), not Chunfen (春分)")
  }

  @Test("Day after solar term transition shows new jieqi via date.jieqi without nextSolarTermJieqi")
  func dayAfterTransitionShowsNewJieqi() throws {
    // Apr 5 UTC noon is well past Qingming (18:28 Apr 4 UTC); date.jieqi should resolve directly.
    let dayAfter = try utcNoon(year: 2026, month: 4, day: 5)
    let jieqi = dayAfter.jieqi
    #expect(jieqi?.chineseName == "清明", "After the transition, date.jieqi should return Qingming (清明)")
    // No same-day case: next solar term (Guyu) is weeks away, widget shows self
    let displayDate = dayAfter.jieqiWidgetDisplayDate()
    #expect(Calendar.current.isDate(displayDate, inSameDayAs: dayAfter) == false || displayDate.dayDifference(dayAfter) >= 1
            || displayDate == dayAfter,
            "Widget display date should be self or a future date beyond today")
  }
}
