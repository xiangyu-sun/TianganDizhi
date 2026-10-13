//
//  SpecialDayCatalog.swift
//  TianganDizhi
//
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Foundation

// MARK: - CustomHoliday

/// A user-defined yearly day (自訂節日), persisted in the shared app-group
/// UserDefaults so the 節氣與節日 widget sees the same list as the app.
struct CustomHoliday: Codable, Hashable, Identifiable, Sendable {
  var id = UUID()
  var day: RecurringDay
}

// MARK: - CustomHolidayStore

enum CustomHolidayStore {
  /// Decodes the stored list. Unreadable data yields an empty list rather than
  /// taking down a widget render.
  static func decode(_ data: Data) -> [CustomHoliday] {
    guard !data.isEmpty else { return [] }
    return (try? JSONDecoder().decode([CustomHoliday].self, from: data)) ?? []
  }

  static func encode(_ holidays: [CustomHoliday]) -> Data {
    (try? JSONEncoder().encode(holidays)) ?? Data()
  }

  static func load(from defaults: UserDefaults? = Constants.sharedUserDefault) -> [CustomHoliday] {
    decode(defaults?.data(forKey: Constants.customHolidays) ?? Data())
  }
}

// MARK: - SpecialDayCatalog

/// The one place the app and widgets build their `SpecialDaySource` list, so
/// the 節日曆 screen and the 節氣與節日 widget always agree.
///
/// Every source reckons calendar days in ``Foundation/TimeZone/solarTerm``,
/// i.e. it follows the 節日與節氣使用東八區時間 setting.
enum SpecialDayCatalog {

  /// Sources in priority order: when several fall on one day, the user's own
  /// day is shown first, then the festival, then the solar term.
  static func sources(
    customHolidays: [CustomHoliday] = CustomHolidayStore.load(),
    timeZone: TimeZone = .solarTerm
  ) -> [SpecialDaySource] {
    var lunar = Calendar(identifier: .chinese)
    lunar.timeZone = timeZone
    return [
      RecurringDaySource(days: customHolidays.map(\.day), timeZone: timeZone),
      FestivalSource(converter: DayConverter(calendar: lunar), timeZone: timeZone),
      JieqiSource(timeZone: timeZone),
    ]
  }

  /// The custom days that fall on `date`'s calendar day.
  static func customHolidays(
    on date: Date,
    customHolidays: [CustomHoliday] = CustomHolidayStore.load(),
    timeZone: TimeZone = .solarTerm
  ) -> [SpecialDay] {
    RecurringDaySource(days: customHolidays.map(\.day), timeZone: timeZone).specialDays(on: date)
  }
}

// MARK: - Display text

extension RecurringDay {
  static let lunarMonthNames = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月"]

  /// The month as shown in pickers and lists: 正月…臘月 or 1月…12月.
  static func monthText(_ month: Int, reckoning: Reckoning) -> String {
    switch reckoning {
    case .lunar: lunarMonthNames.indices.contains(month - 1) ? lunarMonthNames[month - 1] : "\(month)月"
    case .gregorian: "\(month)月"
    }
  }

  /// The day as shown in pickers and lists: 初一…三十 or 1日…31日.
  static func dayText(_ day: Int, reckoning: Reckoning) -> String {
    switch reckoning {
    case .lunar: Day(rawValue: day)?.name ?? "\(day)"
    case .gregorian: "\(day)日"
    }
  }

  /// e.g. "農曆八月初三" or "公曆5月1日".
  var dateText: String {
    let prefix = reckoning == .lunar ? "農曆" : "公曆"
    return prefix + Self.monthText(month, reckoning: reckoning) + Self.dayText(day, reckoning: reckoning)
  }
}

extension Int {
  /// "今日", or the day count spelled out, e.g. 15 → "十五日後".
  var daysUntilText: String {
    guard self > 0 else { return "今日" }
    let spelled = Date.jieqiCountdownFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    return "\(spelled)日後"
  }
}
