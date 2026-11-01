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
    timeZone: TimeZone = .solarTerm,
    language: DisplayLanguage = .app
  ) -> [SpecialDaySource] {
    var lunar = Calendar(identifier: .chinese)
    lunar.timeZone = timeZone
    // Traditional Chinese (and every locale that keeps Chinese glyphs) uses
    // the library's defaults; Simplified Chinese swaps in Simplified strings.
    let festivals: any ChineseFestivalContentProvider = language.glyphLanguage == .zhHans
      ? LocalizedFestivalContentProvider(language: .zhHans)
      : DefaultFestivalContentProvider()
    let jieqi: any JieqiContentProvider = language.glyphLanguage == .zhHans
      ? SimplifiedJieqiContentProvider()
      : DefaultJieqiContentProvider()
    return [
      RecurringDaySource(days: customHolidays.map(\.day), timeZone: timeZone),
      FestivalSource(converter: DayConverter(calendar: lunar), timeZone: timeZone, contentProvider: festivals),
      JieqiSource(timeZone: timeZone, contentProvider: jieqi),
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

// MARK: - SimplifiedJieqiContentProvider

/// 節氣 names, category and health tips in Simplified Chinese. The library
/// translates the names; the tips are Traditional-only prose, so they go
/// through the script transform.
private struct SimplifiedJieqiContentProvider: JieqiContentProvider {
  private let base = LocalizedJieqiContentProvider(language: .zhHans)

  var category: String { base.category }
  func name(for jieqi: Jieqi) -> String { base.name(for: jieqi) }
  func detail(for jieqi: Jieqi) -> String { base.detail(for: jieqi).converted(to: .zhHans) }
}

// MARK: - Display text

extension RecurringDay {
  /// The month as shown in pickers and lists: 正月…臘月 or 1月…12月.
  static func monthText(_ month: Int, reckoning: Reckoning, language: DisplayLanguage = .app) -> String {
    switch reckoning {
    case .lunar: LunarMonth(number: month)?.localizedName(in: language.glyphLanguage) ?? String(localized: "\(month)月")
    case .gregorian: String(localized: "\(month)月", comment: "Gregorian month, e.g. 5月")
    }
  }

  /// The day as shown in pickers and lists: 初一…三十 or 1日…31日.
  static func dayText(_ day: Int, reckoning: Reckoning, language: DisplayLanguage = .app) -> String {
    switch reckoning {
    case .lunar: Day(rawValue: day)?.localizedName(in: language.glyphLanguage) ?? "\(day)"
    case .gregorian: String(localized: "\(day)日", comment: "Gregorian day of month, e.g. 1日")
    }
  }

  /// e.g. "農曆八月初三" or "公曆5月1日".
  var dateText: String {
    dateText(language: .app)
  }

  /// ``dateText`` with the lunar month and day in the script of `language`.
  func dateText(language: DisplayLanguage) -> String {
    let month = Self.monthText(month, reckoning: reckoning, language: language)
    let day = Self.dayText(day, reckoning: reckoning, language: language)
    return switch reckoning {
    case .lunar: String(localized: "農曆\(month)\(day)", comment: "Lunar date; %1$@ month (八月), %2$@ day (初三)")
    case .gregorian: String(localized: "公曆\(month)\(day)", comment: "Gregorian date; %1$@ month (5月), %2$@ day (1日)")
    }
  }
}

extension Int {
  /// "今日", or the day count spelled out, e.g. 15 → "十五日後".
  var daysUntilText: String {
    guard self > 0 else { return String(localized: "今日") }
    let spelled = Date.jieqiCountdownFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    return String(localized: "\(spelled)日後", comment: "Days until an event; %@ is the count spelled out (十五)")
  }
}
