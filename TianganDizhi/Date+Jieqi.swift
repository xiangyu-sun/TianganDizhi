//
//  File.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//
import ChineseAstrologyCalendar
import Foundation

extension Date {
  /// Spells out the day count for the countdown text, e.g. 15 → "十五".
  ///
  /// `nonisolated(unsafe)` rather than `@MainActor`: `jieQiDisplayText` is read
  /// from widget views and the menu bar off the main actor. `NumberFormatter` is
  /// thread-safe for formatting, and this instance is never mutated after init.
  nonisolated(unsafe) static let jieqiCountdownFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "zh-Hant")
    return formatter
  }()

  /// The solar-term period active on this date's calendar day in the
  /// user's chosen time zone (``TimeZone/solarTerm``). On a term's own start
  /// day this is that term, whatever the time of day the calculation runs, so
  /// the main screen (real-time) and the widgets (midnight-seeded timelines)
  /// always agree.
  var jieqiDayAligned: Jieqi? {
    jieqi(in: .solarTerm)
  }

  /// The current solar-term occurrence (the active term plus the day it
  /// began), on the user's chosen calendar day.
  var currentJieqiDayAligned: JieqiOccurrence? {
    currentJieqi(in: .solarTerm)
  }

  /// The next solar-term occurrence after this date's calendar day in the
  /// user's chosen time zone.
  var nextJieqiDayAligned: JieqiOccurrence? {
    nextJieqi(in: .solarTerm)
  }

  /// Whether this date is a solar-term start day in the user's chosen time zone.
  var isJieqiDayAligned: Bool {
    isJieqiDay(in: .solarTerm)
  }

  /// The solar term a date's UI highlights:
  /// - on the term's own start day, the term that has just begun (小暑 on the
  ///   小暑 day);
  /// - otherwise the upcoming term the countdown text points to.
  ///
  /// Keeps the widget content (name, health tip, background image) in step with
  /// `jieQiDisplayText`, which names the same term.
  var displayedJieqi: JieqiOccurrence? {
    if isJieqiDayAligned {
      return currentJieqiDayAligned
    }
    return nextJieqiDayAligned
  }

  /// Display text for the Jieqi surfaces (main screen, menu bar, share text and
  /// the Jieqi widgets):
  /// - on a term's start day, the term that has begun, e.g. "小暑節";
  /// - otherwise a countdown to the next term, e.g. "十五日後大暑氣".
  var jieQiDisplayText: String {
    if isJieqiDayAligned, let current = jieqiDayAligned ?? Jieqi.current {
      return current.chineseName + (current.qi ? "氣" : "節")
    }

    if let next = nextJieqiDayAligned {
      let days = next.days(from: self, calendar: .solarTerm)
      if days > 0 {
        let daysString = Self.jieqiCountdownFormatter.string(from: NSNumber(value: days)) ?? "\(days)"
        return "\(daysString)日後\(next.jieqi.chineseName)\(next.jieqi.qi ? "氣" : "節")"
      }
    }

    // Fallback: name whatever term is in effect (e.g. no upcoming occurrence found).
    guard let current = jieqiDayAligned ?? Jieqi.current else { return "" }
    return current.chineseName + (current.qi ? "氣" : "節")
  }
}

// MARK: - Lunar date text

extension Date {
  /// The lunar date with the year's zodiac animal, in the device's time zone,
  /// e.g. 甲辰龍年正月初一.
  var lunarDateWithZodiac: String {
    lunarDate()?.formatted(.yearZodiacMonthDay, in: .zhHant) ?? ""
  }

  /// The lunar date with the year's zodiac animal, in China Standard Time.
  var lunarDateWithZodiacGTM8: String {
    lunarDate(.chineseCalendarGTM8)?.formatted(.yearZodiacMonthDay, in: .zhHant) ?? ""
  }

  /// The lunar day alone in the device's time zone, e.g. 初一.
  var lunarDayText: String {
    lunarDate()?.formatted(.day, in: .zhHant) ?? ""
  }
}

// MARK: - Solar-term time zone

extension TimeZone {
  /// The time zone solar-term days are reckoned in: China Standard Time when
  /// the user turns on 使用東八區 (`Constants.useGTM8`), otherwise the device's
  /// own, matching how the app's lunar dates follow the same setting.
  static var solarTerm: TimeZone {
    Constants.sharedUserDefault?.bool(forKey: Constants.useGTM8) == true ? .chinaStandardTime : .current
  }
}

extension Calendar {
  /// A Gregorian calendar in ``Foundation/TimeZone/solarTerm``, for counting
  /// days to solar-term start dates.
  static var solarTerm: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .solarTerm
    return calendar
  }
}

extension JieqiOccurrence {
  /// Calendar days from `date` to this occurrence's start date.
  func days(from date: Date, calendar: Calendar = .current) -> Int {
    let start = calendar.startOfDay(for: date)
    return calendar.dateComponents([.day], from: start, to: startDate).day ?? 0
  }
}
