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
    #expect(result.days(from: today) > 14, "Should be more than 14 days away")
  }

  @Test("nextJieqi returns days within 1–14 when upcoming jieqi is in the window")
  func nextJieqiReturnsWithinWindow() throws {
    // 2025-05-11 UTC noon: ~10 days before Xiaoman (小滿, ~May 21 2025)
    let today = try utcNoon(year: 2025, month: 5, day: 11)
    let result = try #require(today.nextJieqi)
    #expect(result.days(from: today) >= 1 && result.days(from: today) <= 14)
    #expect(result.jieqi.chineseName == "小滿")
  }

  @Test("nextJieqi returns days == 14 when exactly 14 days away")
  func nextJieqiReturnsExactly14Days() throws {
    // 2025-04-21 UTC noon: 14 days before Lixia (~May 5 2025)
    let today = try utcNoon(year: 2025, month: 4, day: 21)
    let result = try #require(today.nextJieqi)
    #expect(result.days(from: today) == 14)
  }

  @Test("nextJieqi returns days == 1 when one day before Guyu")
  func nextJieqiReturnsOneDayAway() throws {
    // 2025-04-19 UTC noon: 1 day before Guyu (穀雨, Apr 20 UTC)
    let today = try utcNoon(year: 2025, month: 4, day: 19)
    let result = try #require(today.nextJieqi)
    #expect(result.days(from: today) == 1)
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
    #expect(result.days(from: dayAfter) >= 1)
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
      if let upcoming = dayAfter.nextJieqi, upcoming.days(from: dayAfter) <= 14 {
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

  // MARK: - jieqiDayAligned — the current term, stable across the day

  // `jieQiDisplayText` names the term that has begun on a Jieqi day (小暑 on the
  // 小暑 day) and otherwise counts down to the next term. All reads are
  // day-aligned so they never lag on the previous term the way an
  // instant-sensitive `date.jieqi` read from a midnight-seeded widget would.

  @Test("jieqiDayAligned resolves to the term that begins on its start day (小暑, Jul 7 2026)")
  func jieqiDayAlignedOnStartDay() throws {
    // Jul 7 2026 is the Xiaoshu (小暑) start day; Jul 6 is still Xiazhi (夏至).
    let xiaoshuDay = try localNoon(year: 2026, month: 7, day: 7)
    let dayBefore = try localNoon(year: 2026, month: 7, day: 6)
    #expect(xiaoshuDay.jieqiDayAligned?.chineseName == "小暑",
            "On the 小暑 start day the current term is 小暑, not the previous 夏至")
    #expect(dayBefore.jieqiDayAligned?.chineseName == "夏至",
            "The day before 小暑 is still 夏至")
  }

  @Test("currentJieqiDayAligned start date lands on the term's own calendar day")
  func currentJieqiDayAlignedStartDate() throws {
    let xiaoshuDay = try localNoon(year: 2026, month: 7, day: 7)
    let occurrence = try #require(xiaoshuDay.currentJieqiDayAligned)
    #expect(occurrence.jieqi.chineseName == "小暑")
    #expect(Calendar.current.isDate(occurrence.startDate, inSameDayAs: xiaoshuDay),
            "The current 小暑 occurrence begins on Jul 7, so the small widget's 'starts today' check is true")
  }

  // MARK: - jieQiDisplayText — term name on a Jieqi day, countdown otherwise

  @Test("jieQiDisplayText counts down to the next term when today is NOT a Jieqi day")
  func displayTextCountsDownOnNonJieqiDay() throws {
    // 2025-05-11: inside the Lixia (立夏, ~May 5) period, before Xiaoman (小滿, ~May 21).
    let today = try localNoon(year: 2025, month: 5, day: 11)
    #expect(!today.isJieqiDayAligned, "May 11 is mid-term, not a Jieqi start day")
    let text = today.jieQiDisplayText
    #expect(text.contains("日後"), "Non-Jieqi day shows a '…日後' countdown")
    #expect(text.contains("小滿"), "Counts down to the upcoming 小滿")
    #expect(!text.contains("立夏"), "The current term name is not shown on a non-Jieqi day")
  }

  @Test("On a term's own start day, jieQiDisplayText names that term with no countdown")
  func displayTextOnStartDayNamesThatTerm() throws {
    // Derive an actual start day from the data rather than hardcoding a civil
    // date: solar-term moments near local midnight land on different calendar
    // days per timezone, so the "start day" is timezone-relative.
    let seed = try localNoon(year: 2026, month: 4, day: 1)
    let upcoming = try #require(seed.nextJieqiDayAligned, "There is always an upcoming term")
    let startDay = upcoming.startDate

    #expect(startDay.isJieqiDayAligned, "The next occurrence's start date is, by definition, a Jieqi day")
    let text = startDay.jieQiDisplayText
    #expect(!text.contains("日後"), "No countdown on the term's own start day")
    #expect(text.contains(upcoming.jieqi.chineseName), "Names the term that has begun on its start day")
  }

  @Test("jieQiDisplayText names 小暑 on the 小暑 start day (regression: was showing 大暑/夏至)")
  func displayTextOnXiaoshuDay() throws {
    let xiaoshuDay = try localNoon(year: 2026, month: 7, day: 7)
    #expect(xiaoshuDay.isJieqiDayAligned, "Jul 7 2026 is the 小暑 start day")
    let text = xiaoshuDay.jieQiDisplayText
    #expect(!text.contains("日後"), "The start day names the term, it does not count down")
    #expect(text.contains("小暑"), "Current term on Jul 7 is 小暑")
    #expect(!text.contains("大暑"), "Must not name the next term 大暑")
    #expect(!text.contains("夏至"), "Must not lag on the previous term 夏至")
  }

  @Test("The day before a term counts down '一日後' to it (Jul 6 2026 → 小暑)")
  func displayTextOneDayBeforeTerm() throws {
    let dayBefore = try localNoon(year: 2026, month: 7, day: 6)
    #expect(!dayBefore.isJieqiDayAligned, "Jul 6 is not itself a Jieqi start day")
    let text = dayBefore.jieQiDisplayText
    #expect(text.contains("日後"), "Counts down to the imminent 小暑")
    #expect(text.contains("小暑"), "The next term is 小暑")
  }

  // MARK: - displayedJieqi — the term the widgets highlight

  @Test("displayedJieqi highlights the current term on a Jieqi day, the next term otherwise")
  func displayedJieqiSwitchesOnJieqiDay() throws {
    // Start day → current term.
    let xiaoshuDay = try localNoon(year: 2026, month: 7, day: 7)
    #expect(xiaoshuDay.displayedJieqi?.jieqi.chineseName == "小暑",
            "On the 小暑 start day the widgets highlight 小暑 itself")

    // Mid-term day → upcoming term (matches the countdown text).
    let midTerm = try localNoon(year: 2026, month: 7, day: 10)
    #expect(!midTerm.isJieqiDayAligned)
    #expect(midTerm.displayedJieqi?.jieqi.chineseName == "大暑",
            "Mid-term, the widgets highlight the upcoming 大暑 the countdown points to")
  }

  // MARK: - Regression: display must not depend on time of day

  /// The Jieqi widgets seed `jieQiDisplayText` at local midnight while the main
  /// screen seeds it at the real current time. Because the package's `jieqi` is
  /// instant-sensitive, a same-day morning transition reported the previous term
  /// from a midnight seed — the widget lagged a day behind the main screen.
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
