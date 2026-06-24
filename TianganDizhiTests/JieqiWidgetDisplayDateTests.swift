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

  /// Noon on the given day in `Calendar.current`. `jieQiDisplayText` normalises
  /// through `endOfLocalDay`, which reads `Calendar.current`, so anchoring test
  /// dates in the same calendar keeps the day count stable across timezones.
  private func localNoon(year: Int, month: Int, day: Int) throws -> Date {
    let components = DateComponents(year: year, month: month, day: day, hour: 12)
    return try #require(Calendar.current.date(from: components))
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

  @Test("On a jieqi day, nextJieqi skips that day's term and points to the next one")
  func nextJieqiOnTransitionDaySkipsToFollowingTerm() throws {
    // Apr 5 2026 is the Qingming (清明) transition day (18:28 UTC Apr 4).
    let today = try utcNoon(year: 2026, month: 4, day: 4)
    let dayAfter = try utcNoon(year: 2026, month: 4, day: 5)
    #expect(dayAfter.isJieqiDay, "Apr 5 should be recognised as a jieqi day (Qingming)")
    let result = try #require(dayAfter.nextJieqi)
    // Package contract: nextJieqi is ALWAYS a future term (≥ 1 day away) and never
    // returns the current day's own term — so on the 清明 day it points to 穀雨.
    #expect(result.days >= 1)
    #expect(result.jieqi.chineseName == "穀雨")
    // day.jieqi resolves to the term that has begun.
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

  // The two tests below previously asserted the old "only show the countdown
  // within a 14-day window, otherwise show the current term name" behaviour.
  // Commit 805946c ("fixing Jieqi calculation bug") removed that window across
  // the app (Date+Jieqi, JieqiWidget, JieqiHealthMediumView) and bumped the
  // ChineseAstrologyCalendar package. The built package's `nextJieqi` now always
  // returns a future term at least 1 day away (`days` starts at 1, never 0), so
  // `jieQiDisplayText` shows the countdown unconditionally and never falls back
  // to a bare current-term name. These tests are rewritten to pin that behaviour
  // and anchored in `Calendar.current` (via localNoon) so they are timezone-robust.

  @Test("jieQiDisplayText shows the countdown even when the next term is far away")
  func displayTextShowsCountdownWhenFar() throws {
    // 2025-05-06: ~15 days before Xiaoman (小滿, ~May 21 2025) — beyond the old 14-day window.
    let today = try localNoon(year: 2025, month: 5, day: 6)
    let text = today.jieQiDisplayText
    #expect(text.contains("日後"), "Countdown is now shown unconditionally, even >14 days out")
    #expect(text.contains("小滿"), "Should name the upcoming Xiaoman (小滿)")
  }

  @Test("jieQiDisplayText counts down to the next term even on a term's own start day")
  func displayTextShowsCountdownOnTransitionDay() throws {
    // Apr 5 2026 is the Qingming (清明) start day. `nextJieqi` always points to a
    // future term (穀雨), so the display counts down to 穀雨 rather than showing the
    // bare current-term name "清明" — the bare-name branch is no longer reachable.
    let qingmingDay = try localNoon(year: 2026, month: 4, day: 5)
    let text = qingmingDay.jieQiDisplayText
    #expect(text.contains("日後"), "Countdown is always shown; no bare-name branch on the start day")
    #expect(text.contains("穀雨"), "Counts down to the following term 穀雨")
    #expect(!text.contains("清明"), "The current term's bare name is no longer shown on its start day")
  }

  // MARK: - Regression: countdown must not depend on time of day

  /// The Jieqi medium widget seeds `jieQiDisplayText` at local midnight
  /// (`DailyTimeLineSceduler.startOfDay`) while the main screen seeds it at the
  /// real current time. Because the package's `isJieqiDay`/`nextJieqi` are
  /// instant-sensitive, a same-day morning transition was counted one day later
  /// from a midnight seed — the widget showed "one day after" the main screen.
  ///
  /// `jieQiDisplayText` now normalises to end of local day, so the rendered text
  /// must be identical regardless of the time of day it is computed.
  @Test("jieQiDisplayText is identical at 00:00, 12:00 and 23:59 of the same day")
  func displayTextStableAcrossTimeOfDay() throws {
    let calendar = Calendar.current
    let firstDay = calendar.startOfDay(for: Date())

    // Sweep ~2 months so the window straddles at least one solar-term transition.
    for offset in 0..<60 {
      let day = try #require(calendar.date(byAdding: .day, value: offset, to: firstDay))
      let atMidnight = day.jieQiDisplayText
      let atNoon = day.addingTimeInterval(12 * 3600).jieQiDisplayText
      let atEndOfDay = day.addingTimeInterval(24 * 3600 - 1).jieQiDisplayText

      #expect(atMidnight == atNoon && atNoon == atEndOfDay,
              "Countdown text must not depend on the time of day (day offset \(offset)): 00:00=\(atMidnight) 12:00=\(atNoon) 23:59=\(atEndOfDay)")
    }
  }
}
