//
//  SpanishLocalizationTests.swift
//  TianganDizhiTests
//
//  Spanish takes the same non-Chinese branches as English, with the library's
//  Spanish names, notes and its own catalog values. The test host runs in
//  English, so every function takes an explicit language.
//

import ChineseAstrologyCalendar
import ChineseTranditionalCalendarUI
import Foundation
import JingluoShuxue
import Testing
@testable import TianganDizhi

@Suite struct SpanishLocalizationTests {

  // MARK: Internal

  @Test func localizationBundleIsSpanish() {
    let spanish = DisplayLanguage.es.localizationBundle
    #expect(spanish.localizedString(forKey: "節日曆", value: "missing", table: nil) == "Calendario festivo")
  }

  @Test func jieqiCountdownIsASpanishSentence() throws {
    let seed = try localNoon(2026, 3, 1)
    let upcoming = try #require(seed.nextJieqiDayAligned)
    let dayBefore = try #require(Calendar.current.date(byAdding: .day, value: -1, to: upcoming.startDate))
    #expect(dayBefore.jieQiDisplayText(language: .es) == "Despertar de los insectos mañana")
    let twoDaysBefore = try #require(Calendar.current.date(byAdding: .day, value: -2, to: upcoming.startDate))
    #expect(twoDaysBefore.jieQiDisplayText(language: .es) == "Despertar de los insectos en 2 días")
  }

  @Test func daysUntilTextHasPluralForms() {
    #expect(15.daysUntilText(language: .es) == "En 15 días")
    #expect(1.daysUntilText(language: .es) == "Mañana")
    #expect(0.daysUntilText(language: .es) == "Hoy")
  }

  @Test func recurringDayTextIsSpanish() {
    #expect(RecurringDay.monthText(5, reckoning: .gregorian, language: .es) == "mayo")
    let may = RecurringDay(name: "", reckoning: .gregorian, month: 5, day: 1)
    #expect(may.dateText(language: .es) == "1 de mayo")
    let lunar = RecurringDay(name: "", reckoning: .lunar, month: 8, day: 3)
    #expect(lunar.dateText(language: .es) == "Día 3 del 8.º mes lunar")
  }

  @Test func footerDateFollowsASpanishLocale() throws {
    let day = RecurringDay(name: "Viaje", reckoning: .gregorian, month: 5, day: 1)
    let text = CustomHolidayEditor.footerText(for: day, language: .es, locale: Locale(identifier: "es_ES"), now: try localNoon(2026, 1, 1))
    #expect(text.hasPrefix("1 de mayo, cada año."), "\(text)")
    #expect(text.contains("1 may 2026. Si el mes"), "\(text)")
  }

  @Test func lunarDateIsSpanish() throws {
    let date = try localNoon(2024, 2, 10)
    #expect(date.lunarDateWithZodiac(language: .es) == "Día 1 del 1.er mes, año del Dragón (Jiǎchén)")
    #expect(date.compactLunarDate(language: .es) == "Día 1 del 1.er mes · Dragón")
  }

  @Test func shichenSentencesAreSpanish() throws {
    let components = DateComponents(year: 2026, month: 3, day: 1, hour: 9, minute: 1)
    let date = try #require(Calendar.current.date(from: components))
    #expect(date.nextShichenCountdown(language: .es) == "1 h 59 min para la Hora Wǔ")
    let shichen = try #require(date.shichen)
    #expect(shichen.keText(language: .es) == "Cuarto \(shichen.currentKe + 1)")
  }

  @Test func organNamesAreSpanish() {
    #expect(Dizhi.zi.luizhu.organText(in: .es) == "Vesícula Biliar")
    for dizhi in Dizhi.allCases {
      #expect(!dizhi.luizhu.organText(in: .es).contains("Meridiano"))
      #expect(!dizhi.luizhu.organText(in: .en).contains("Meridian"))
    }
  }

  @Test func specialDaySourcesUseSpanishContent() throws {
    let sources = SpecialDayCatalog.sources(customHolidays: [], timeZone: .chinaStandardTime, language: .es)
    // 2026-02-17 is Chinese New Year.
    let newYear = try localNoon(2026, 2, 17)
    let festival = try #require(sources[1].nextSpecialDay(after: newYear.addingTimeInterval(-86_400 * 3)))
    #expect(festival.name == "Fiesta de la Primavera (Año Nuevo Chino)")
    #expect(festival.category == "Festividad")
    #expect(festival.detail.hasPrefix("El Año Nuevo"))

    let jieqi = try #require(sources[2].nextSpecialDay(after: try localNoon(2026, 3, 1)))
    #expect(jieqi.name == "Despertar de los insectos")
    #expect(jieqi.category == "Término solar")
    #expect(jieqi.detail.hasPrefix("En el despertar de los insectos"))
  }

  @Test(arguments: [
    (DisplayLanguage.zhHant, "自訂"),
    (.zhHans, "自定义"),
    (.en, "Custom"),
    (.es, "Personal"),
  ])
  func customDayCategoryFollowsTheLanguage(_ language: DisplayLanguage, _ expected: String) throws {
    let birthday = CustomHoliday(day: RecurringDay(name: "生日", reckoning: .gregorian, month: 5, day: 1))
    let sources = SpecialDayCatalog.sources(customHolidays: [birthday], timeZone: .current, language: language)
    let day = try #require(sources[0].nextSpecialDay(after: try localNoon(2026, 3, 1)))
    #expect(day.category == expected)
  }

  @Test(arguments: [
    (DisplayLanguage.zhHant, false),
    (.zhHans, false),
    (.es, false),
    (.en, true),
  ])
  func solarTermCaptionOnlyWhereTheNotesAreChinese(_ language: DisplayLanguage, _ expected: Bool) {
    #expect(SpecialDayCatalog.solarTermNotesNeedCaption(in: language) == expected)
  }

  @Test func monthTitleIsSpanish() throws {
    let month = CalendarMonth(containing: try localNoon(2026, 3, 15))
    #expect(month.title(in: .es, locale: Locale(identifier: "es_ES")) == "Marzo de 2026")
  }

  @Test func shareTextIsSpanish() throws {
    let text = try localNoon(2024, 2, 10).shichenShareText(language: .es)
    #expect(text.hasPrefix("Fecha: Día 1 del 1.er mes, año del Dragón"), "\(text)")
    #expect(text.contains("Cielo: "), "\(text)")
  }

  // MARK: Private

  private func localNoon(_ year: Int, _ month: Int, _ day: Int) throws -> Date {
    let components = DateComponents(year: year, month: month, day: day, hour: 12)
    return try #require(Calendar.current.date(from: components))
  }
}
