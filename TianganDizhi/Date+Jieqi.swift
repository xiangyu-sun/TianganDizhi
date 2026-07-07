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
  static let jieqiCountdownFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "zh-Hant")
    return formatter
  }()

  /// The last instant of this date's local calendar day.
  ///
  /// Seeding solar-term math here keeps the result calendar-stable. The
  /// package's `jieqi`/`isJieqiDay`/`currentJieqi` are *instant*-sensitive (a
  /// transition counts on day `D` only once its astronomical moment has passed),
  /// so a midnight seed still reports the previous term on the morning of a
  /// same-day transition. Evaluating at end of day makes every transition land
  /// on its own calendar day regardless of the time the calculation runs — this
  /// is what kept the main screen (real-time seed) and the Jieqi widgets
  /// (midnight-seeded timelines) reporting different terms.
  var endOfLocalDay: Date {
    let calendar = Calendar.current
    let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: self)) ?? self
    return startOfNextDay.addingTimeInterval(-1)
  }

  /// The solar-term period active on this date's calendar day, evaluated at a
  /// calendar-stable point (end of local day) so it does not depend on the time
  /// of day the calculation runs. On a term's own start day this resolves to
  /// that term (小暑 on the 小暑 day), never the previous term the way an
  /// instant-sensitive `jieqi` read from a midnight-seeded widget does.
  var jieqiDayAligned: Jieqi? {
    endOfLocalDay.jieqi
  }

  /// The current solar-term occurrence (the active term plus the day it began),
  /// evaluated day-aligned so the start date is stable across the day.
  var currentJieqiDayAligned: JieqiOccurrence? {
    endOfLocalDay.currentJieqi
  }

  /// The next solar-term occurrence, evaluated day-aligned so the returned
  /// term and its start date do not depend on the time of day.
  var nextJieqiDayAligned: JieqiOccurrence? {
    endOfLocalDay.nextJieqi
  }

  /// Whether this date is a solar-term start day, evaluated day-aligned so the
  /// answer is stable across the day (the package's `isJieqiDay` is
  /// instant-sensitive and would flip mid-morning from a midnight seed).
  var isJieqiDayAligned: Bool {
    endOfLocalDay.isJieqiDay
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
    if isJieqiDayAligned, let current = jieqiDayAligned ?? jieqi ?? Jieqi.current {
      return current.chineseName + (current.qi ? "氣" : "節")
    }

    if let next = nextJieqiDayAligned {
      let startOfDay = Calendar.current.startOfDay(for: self)
      let days = Calendar.current.dateComponents([.day], from: startOfDay, to: next.startDate).day ?? 0
      if days > 0 {
        let daysString = Self.jieqiCountdownFormatter.string(from: NSNumber(value: days)) ?? "\(days)"
        return "\(daysString)日後\(next.jieqi.chineseName)\(next.jieqi.qi ? "氣" : "節")"
      }
    }

    // Fallback: name whatever term is in effect (e.g. no upcoming occurrence found).
    guard let current = jieqiDayAligned ?? jieqi ?? Jieqi.current else { return "" }
    return current.chineseName + (current.qi ? "氣" : "節")
  }
}

extension JieqiOccurrence {
  /// Calendar days from `date` to this occurrence's start date.
  func days(from date: Date, calendar: Calendar = .current) -> Int {
    let start = calendar.startOfDay(for: date)
    return calendar.dateComponents([.day], from: start, to: startDate).day ?? 0
  }
}
