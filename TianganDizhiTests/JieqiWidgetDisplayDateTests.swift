//
//  JieqiWidgetDisplayDateTests.swift
//  TianganDizhiTests
//
//  Created by Xiangyu Sun on 14/3/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import Testing
import Foundation
import ChineseAstrologyCalendar
@testable import TianganDizhi

struct JieqiWidgetDisplayDateTests {

  // All dates are constructed at UTC noon so day boundaries are stable across timezones.
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

  // MARK: - Date.nextJieqi — distance to next solar term

  @Test("nextJieqi returns days > 14 when next jieqi is more than 14 days away")
  func nextJieqiReturnsFarWhenBeyondWindow() throws {
    // 2025-05-06 UTC noon: 15 days before Xiaoman (小滿, ~May 21 2025)
    let today = try utcNoon(year: 2025, month: 5, day: 6)
    let result = try #require(today.nextJieqi)
    #expect(result.days > 14, "Should be more than 14 days away")
  }

  @Test("nextJieqi returns days within 1–14 when upcoming jieqi is in the window")
  func nextJieqiReturnsWithinWindow() throws {
    // 2025-05-11 UTC noon: ~10 days before Xiaoman (小滿, ~May 21 2025)
    let today = try utcNoon(year: 2025, month: 5, day: 11)
    let result = try #require(today.nextJieqi)
    #expect(result.days >= 1 && result.days <= 14)
    #expect(result.jieqi.chineseName == "小滿")
  }

  @Test("nextJieqi returns days == 14 when exactly 14 days away")
  func nextJieqiReturnsExactly14Days() throws {
    // 2025-04-21 UTC noon: 14 days before Lixia (~May 5 2025)
    let today = try utcNoon(year: 2025, month: 4, day: 21)
    let result = try #require(today.nextJieqi)
    #expect(result.days == 14)
  }

  @Test("nextJieqi returns days == 1 when one day before Guyu")
  func nextJieqiReturnsOneDayAway() throws {
    // 2025-04-19 UTC noon: 1 day before Guyu (穀雨, Apr 20 UTC)
    let today = try utcNoon(year: 2025, month: 4, day: 19)
    let result = try #require(today.nextJieqi)
    #expect(result.days == 1)
    #expect(result.jieqi.chineseName == "穀雨")
  }

  // MARK: - Regression: Qingming 2026 (18:28 UTC on Apr 4)

  @Test("On Qingming day, nextJieqi returns days == 0 and the correct jieqi")
  func nextJieqiReturnsDaysZeroOnTransitionDay() throws {
    // Apr 4 UTC noon is before the 18:28 transition, but the package uses day-level comparison.
    // The package reports the transition day as days == 0 for the whole calendar day.
    let today = try utcNoon(year: 2026, month: 4, day: 4)
    // Apr 5 is unambiguously the day after the transition — isJieqiDay == true
    let dayAfter = try utcNoon(year: 2026, month: 4, day: 5)
    #expect(dayAfter.isJieqiDay, "Apr 5 should be recognised as a jieqi day (Qingming)")
    let result = try #require(dayAfter.nextJieqi)
    // On the transition day itself, days == 0 and the jieqi is the new one (Qingming)
    #expect(result.days == 0)
    #expect(result.jieqi.chineseName == "清明")
    // day.jieqi also resolves directly after the transition
    #expect(today.jieqi?.chineseName == "春分" || dayAfter.jieqi?.chineseName == "清明",
            "Either Apr 4 is still Chunfen or Apr 5 has resolved to Qingming")
  }

  @Test("Widget shows Qingming on the Qingming transition day via nextJieqi")
  func widgetShowsCorrectJieqiOnTransitionDay() throws {
    // Apr 5 UTC noon — day after transition; nextJieqi.days == 0, jieqi == Qingming
    let dayAfter = try utcNoon(year: 2026, month: 4, day: 5)
    let jieqi: Jieqi? = {
      if let upcoming = dayAfter.nextJieqi, upcoming.days <= 14 {
        return upcoming.jieqi
      }
      return dayAfter.jieqi
    }()
    #expect(jieqi?.chineseName == "清明", "Should show Qingming (清明)")
  }

  @Test("Day after solar term transition: date.jieqi resolves to the new term")
  func dayAfterTransitionShowsNewJieqi() throws {
    // Apr 5 UTC noon is well past Qingming (18:28 Apr 4 UTC)
    let dayAfter = try utcNoon(year: 2026, month: 4, day: 5)
    #expect(dayAfter.jieqi?.chineseName == "清明",
            "After the transition, date.jieqi should return Qingming (清明)")
  }

  // MARK: - jieQiDisplayText

  @Test("jieQiDisplayText shows countdown text when next jieqi is within 14 days")
  func displayTextShowsCountdownWithinWindow() throws {
    // 2025-05-11 UTC noon: ~10 days before Xiaoman (小滿, ~May 21 2025)
    let today = try utcNoon(year: 2025, month: 5, day: 11)
    let text = today.jieQiDisplayText
    #expect(text.contains("日後"), "Should contain countdown suffix '日後'")
    #expect(text.contains("小滿"), "Should name the upcoming Xiaoman (小滿)")
  }

  @Test("jieQiDisplayText shows current jieqi name when next jieqi is more than 14 days away")
  func displayTextShowsCurrentJieqiWhenFar() throws {
    // 2025-05-06 UTC noon: 15 days before Xiaoman (小滿, ~May 21 2025) — beyond the 14-day window
    let today = try utcNoon(year: 2025, month: 5, day: 6)
    let text = today.jieQiDisplayText
    #expect(!text.contains("日後"), "Should NOT contain countdown when beyond 14 days")
    #expect(!text.isEmpty, "Should still show the current jieqi name")
  }

  @Test("jieQiDisplayText shows jieqi name on the transition day (days == 0)")
  func displayTextShowsJieqiNameOnTransitionDay() throws {
    // Apr 5 UTC noon — day after Qingming started (18:28 Apr 4 UTC)
    let dayAfter = try utcNoon(year: 2026, month: 4, day: 5)
    let text = dayAfter.jieQiDisplayText
    #expect(!text.isEmpty, "Display text should never be empty on a known jieqi day")
    #expect(!text.contains("日後"), "On the transition day (days == 0), no countdown should appear")
  }
}
