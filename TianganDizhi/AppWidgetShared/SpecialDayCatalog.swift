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
  ///
  /// `language` picks the names: Traditional or Simplified Chinese, or English
  /// for every other language. It defaults to Traditional Chinese, so UI code
  /// passes `.app` (or its `displayLanguage`) explicitly.
  static func sources(
    customHolidays: [CustomHoliday] = CustomHolidayStore.load(),
    timeZone: TimeZone = .solarTerm,
    language: DisplayLanguage = .zhHant
  ) -> [SpecialDaySource] {
    var lunar = Calendar(identifier: .chinese)
    lunar.timeZone = timeZone
    // Traditional Chinese uses the library's defaults; Simplified Chinese swaps
    // in Simplified strings and every other language the English names. The
    // jieqi `detail` (health tips) and, in Chinese, the festival meanings stay
    // library prose: Chinese for jieqi, English for festivals.
    let festivals: any ChineseFestivalContentProvider
    let jieqi: any JieqiContentProvider
    switch language {
    case .zhHans:
      festivals = LocalizedFestivalContentProvider(language: .zhHans)
      jieqi = SimplifiedJieqiContentProvider()
    case .zhHant:
      festivals = DefaultFestivalContentProvider()
      jieqi = DefaultJieqiContentProvider()
    default:
      festivals = LocalizedFestivalContentProvider(language: .en)
      jieqi = LocalizedJieqiContentProvider(language: .en)
    }
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
  /// The month as shown in pickers and lists: 正月…臘月 / "1st Month" for lunar,
  /// 1月…12月 / "January" for Gregorian.
  static func monthText(_ month: Int, reckoning: Reckoning, language: DisplayLanguage = .app) -> String {
    switch reckoning {
    case .lunar:
      return LunarMonth(number: month)?.localizedName(in: language) ?? String(localized: "\(month)月", bundle: language.localizationBundle)
    case .gregorian:
      if !language.isChinese {
        let symbols = Calendar(identifier: .gregorian).monthSymbols
        if symbols.indices.contains(month - 1) { return symbols[month - 1] }
        return String(localized: "\(month)月", bundle: language.localizationBundle)
      }
      return String(localized: "\(month)月", bundle: language.localizationBundle, comment: "Gregorian month, e.g. 5月")
    }
  }

  /// The day as shown in pickers and lists: 初一…三十 / "1st" or 1日…31日 / "1".
  static func dayText(_ day: Int, reckoning: Reckoning, language: DisplayLanguage = .app) -> String {
    switch reckoning {
    case .lunar: Day(rawValue: day)?.localizedName(in: language) ?? "\(day)"
    case .gregorian:
      language.isChinese
        ? String(localized: "\(day)日", bundle: language.localizationBundle, comment: "Gregorian day of month, e.g. 1日")
        : "\(day)"
    }
  }

  /// e.g. "農曆八月初三" or "公曆5月1日".
  var dateText: String {
    dateText(language: .app)
  }

  /// ``dateText`` in `language`: "Lunar 8th Month 3rd" or "May 1" outside Chinese.
  func dateText(language: DisplayLanguage) -> String {
    let month = Self.monthText(month, reckoning: reckoning, language: language)
    let day = Self.dayText(day, reckoning: reckoning, language: language)
    let bundle = language.localizationBundle
    return switch reckoning {
    case .lunar: String(localized: "農曆\(month)\(day)", bundle: bundle, comment: "Lunar date; %1$@ month (八月), %2$@ day (初三)")
    case .gregorian: String(localized: "公曆\(month)\(day)", bundle: bundle, comment: "Gregorian date; %1$@ month (5月), %2$@ day (1日)")
    }
  }
}

extension Int {
  /// "今日", or the day count spelled out, e.g. 15 → "十五日後".
  var daysUntilText: String {
    daysUntilText(language: .app)
  }

  /// ``daysUntilText`` in `language`. Chinese spells the count out; other
  /// languages pass the `Int` to a plural-aware format ("In 15 days").
  func daysUntilText(language: DisplayLanguage) -> String {
    let bundle = language.localizationBundle
    guard self > 0 else { return String(localized: "今日", bundle: bundle) }
    guard language.isChinese else {
      return String(localized: "\(self)日後", bundle: bundle, comment: "Days until an event outside Chinese; %lld is the count. Needs plural variants.")
    }
    let spelled = Date.jieqiCountdownFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    return String(localized: "\(spelled)日後", bundle: bundle, comment: "Days until an event; %@ is the count spelled out (十五)")
  }
}
