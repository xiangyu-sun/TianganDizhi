//
//  EnglishLocalizationTests.swift
//  TianganDizhiTests
//
//  Outside Chinese the app's sentence-like text is English, its reference rows
//  are a Chinese glyph with an English gloss, and Chinese output is unchanged.
//  The test host runs in English, so every function takes an explicit language.
//

import ChineseAstrologyCalendar
import CoreText
import Foundation
import Testing
@testable import TianganDizhi

@Suite struct EnglishLocalizationTests {

  // MARK: Internal

  // MARK: isChinese

  @Test func isChineseOnlyForTheTwoChineseScripts() {
    #expect(DisplayLanguage.zhHant.isChinese)
    #expect(DisplayLanguage.zhHans.isChinese)
    #expect(!DisplayLanguage.en.isChinese)
    #expect(!DisplayLanguage.ru.isChinese)
    #expect(!DisplayLanguage.es.isChinese)
  }

  @Test func localizationBundleFollowsTheLanguage() throws {
    let traditional = DisplayLanguage.zhHant.localizationBundle
    #expect(traditional.localizedString(forKey: "節日曆", value: "missing", table: nil) == "節日曆")
    let english = DisplayLanguage.en.localizationBundle
    #expect(english.localizedString(forKey: "節日曆", value: "missing", table: nil) == "Festival Calendar")
  }

  // MARK: Solar terms

  @Test func jieqiDisplayNameHasNoChineseSuffixInEnglish() {
    #expect(Jieqi.minorHeat.displayName(language: .en) == "Minor Heat")
    #expect(Jieqi.majorHeat.displayName(language: .en) == "Major Heat")
    #expect(Jieqi.minorHeat.displayName(language: .zhHant) == "小暑節")
    #expect(Jieqi.majorHeat.displayName(language: .zhHant) == "大暑氣")
    #expect(Jieqi.majorHeat.displayName(language: .zhHans) == "大暑气")
  }

  @Test func jieqiCountdownPassesTheNumberOutsideChinese() throws {
    let seed = try localNoon(2026, 3, 1)
    let upcoming = try #require(seed.nextJieqiDayAligned)
    let dayBefore = try #require(Calendar.current.date(byAdding: .day, value: -1, to: upcoming.startDate))
    #expect(dayBefore.jieQiDisplayText(language: .en) == "Awakening of Insects tomorrow")
    let twoDaysBefore = try #require(Calendar.current.date(byAdding: .day, value: -2, to: upcoming.startDate))
    #expect(twoDaysBefore.jieQiDisplayText(language: .en) == "Awakening of Insects in 2 days")

    let chinese = dayBefore.jieQiDisplayText(language: .zhHant)
    #expect(chinese == "一日後驚蟄節")
  }

  @Test func daysUntilTextSpellsOutOnlyInChinese() {
    #expect(15.daysUntilText(language: .zhHant) == "十五日後")
    #expect(15.daysUntilText(language: .zhHans) == "十五日后")
    #expect(0.daysUntilText(language: .zhHant) == "今日")
    #expect(15.daysUntilText(language: .en) == "In 15 days")
    #expect(1.daysUntilText(language: .en) == "Tomorrow")
    #expect(0.daysUntilText(language: .en) == "Today")
  }

  // MARK: Dates

  @Test func recurringDayTextInEnglish() {
    #expect(RecurringDay.monthText(5, reckoning: .gregorian, language: .en) == Calendar(identifier: .gregorian).monthSymbols[4])
    #expect(RecurringDay.dayText(1, reckoning: .gregorian, language: .en) == "1")
    #expect(RecurringDay.monthText(8, reckoning: .lunar, language: .en) == "8th Month")
    #expect(RecurringDay.dayText(3, reckoning: .lunar, language: .en) == "3rd")
    #expect(RecurringDay.monthText(5, reckoning: .gregorian, language: .zhHant) == "5月")
    #expect(RecurringDay.dayText(1, reckoning: .gregorian, language: .zhHant) == "1日")

    let lunar = RecurringDay(name: "", reckoning: .lunar, month: 8, day: 3)
    #expect(lunar.dateText(language: .en) == "Lunar 8th Month 3rd")
    #expect(lunar.dateText(language: .zhHant) == "農曆八月初三")
  }

  @Test func lunarDateIsEnglishOutsideChinese() throws {
    let date = try localNoon(2024, 2, 10)
    #expect(date.lunarDateWithZodiac(language: .en) == "1st Month 1st, Year of the Dragon (Jiǎchén)")
    #expect(date.lunarDateWithZodiac(language: .zhHant) == "甲辰龍年正月初一")
    #expect(date.compactLunarDate(language: .en) == "1st Month 1st · Dragon")
    #expect(date.compactLunarDate(language: .zhHant) == "甲辰龍年正月初一")
  }

  @Test func footerDateUsesTheCurrentLocaleOutsideChinese() throws {
    let day = RecurringDay(name: "Trip", reckoning: .gregorian, month: 5, day: 1)
    let now = try localNoon(2026, 1, 1)
    let english = CustomHolidayEditor.footerText(for: day, language: .en, locale: Locale(identifier: "en_US"), now: now)
    #expect(english.contains("May 1, 2026"), "\(english)")
    let german = CustomHolidayEditor.footerText(for: day, language: .en, locale: Locale(identifier: "de_DE"), now: now)
    #expect(german.contains("1. Mai 2026"), "\(german)")
    let chinese = CustomHolidayEditor.footerText(for: day, language: .zhHant, locale: Locale(identifier: "en_US"), now: now)
    #expect(chinese.contains("2026年5月1日"), "\(chinese)")
    #expect(chinese.contains("每年重複"))
  }

  // MARK: Special days

  @Test func specialDaySourcesAreEnglishOutsideChinese() throws {
    let sources = SpecialDayCatalog.sources(customHolidays: [], timeZone: .chinaStandardTime, language: .en)
    // 2026-02-17 is Chinese New Year.
    let newYear = try localNoon(2026, 2, 17)
    let festival = try #require(sources[1].nextSpecialDay(after: newYear.addingTimeInterval(-86_400 * 3)))
    #expect(festival.name == ChineseFestival.springFestival.localizedName(in: .en))
    #expect(festival.category == "Festival")
    #expect(festival.detail.hasPrefix("Chinese New Year"))

    let jieqi = try #require(sources[2].nextSpecialDay(after: try localNoon(2026, 3, 1)))
    #expect(jieqi.name == "Awakening of Insects")
    // The health note is library prose and stays Chinese.
    #expect(jieqi.detail == Jieqi.awakeningOfInsects.healthTip)
  }

  @Test func specialDaySourcesDefaultToTraditionalChinese() throws {
    let sources = SpecialDayCatalog.sources(customHolidays: [], timeZone: .chinaStandardTime)
    let jieqi = try #require(sources[2].nextSpecialDay(after: try localNoon(2026, 3, 1)))
    #expect(jieqi.name == "驚蟄")
  }

  // MARK: Shichen

  @Test func keTextIsANumberedQuarterOutsideChinese() throws {
    let shichen = try #require(try localNoon(2026, 3, 1).shichen)
    #expect(shichen.keText(language: .zhHant) == "\(shichen.currentKeSpellOut)刻")
    let english = shichen.keText(language: .en)
    #expect(english == "Quarter \(shichen.currentKe + 1)")
  }

  @Test func shichenCountdownIsEnglishOutsideChinese() throws {
    let components = DateComponents(year: 2026, month: 3, day: 1, hour: 9, minute: 1)
    let date = try #require(Calendar.current.date(from: components))
    let english = date.nextShichenCountdown(language: .en)
    #expect(english.contains("Wǔ hour"), "\(english)")
    #expect(!english.contains("小時") && !english.contains("距離"))
  }

  // MARK: Names and glosses

  @Test func glossesCarryTheEnglishName() {
    #expect(Dizhi.zi.gloss(in: .en) == "Zǐ · Rat")
    #expect(Dizhi.zi.gloss(in: .zhHant).isEmpty)
    #expect(Tiangan.jia.gloss(in: .en) == "Jiǎ · Wood")
    #expect(Wuxing.wood.gloss(in: .en) == "Wood")
    #expect(Wuxing.wood.sentenceText(in: .en) == "Wood")
    #expect(Wuxing.wood.sentenceText(in: .zhHans) == "木")
    #expect(getJiazhi().first?.gloss(in: .en).hasPrefix("Jiǎzǐ") == true)
  }

  @Test func accessibilityTextReadsGlyphThenGloss() {
    #expect(GlossedText.accessibilityText(glyph: "子", gloss: "Zǐ · Rat") == "子, Zǐ, Rat")
    #expect(GlossedText.accessibilityText(glyph: "子", gloss: "") == "子")
  }

  @Test func moonPhaseAndMansionNamesAreEnglish() {
    #expect(ChineseMoonPhase.fullMoon.name(traditionnal: false, language: .en) == "Full Moon")
    #expect(ChineseMoonPhase.fullMoon.name(traditionnal: true, language: .en) == ChineseMoonPhase.fullMoon.acientChineseName(.day8))
    #expect(ChineseMoonPhase.fullMoon.name(traditionnal: false, language: .zhHant) == ChineseMoonPhase.fullMoon.modernChineseName(.day8))
    #expect(LunarMansion.horn.shortName(in: .en) == "Horn")
    #expect(LunarMansion.horn.shortName(in: .zhHant) == "角")
  }

  @Test func shareTextIsEnglishOutsideChinese() throws {
    let date = try localNoon(2024, 2, 10)
    let text = date.shichenShareText(language: .en)
    #expect(text.contains("Year of the Dragon"), "\(text)")
    #expect(text.contains("Symbol:") || text.contains("Sky:"), "\(text)")
    let chinese = date.shichenShareText(language: .zhHant)
    #expect(chinese.contains("甲辰龍年正月初一"))
  }

  // MARK: Fonts

  @Test func latinFriendlyFontNeverFailsWithoutACalligraphyFont() {
    // Falls back to the bold system style when no calligraphy font is registered.
    _ = CalligraphyFont.latinFriendly(size: 22, relativeTo: .body)
    if let font = CalligraphyFont.cascadingFont(size: 22) {
      #expect(CTFontGetSize(font) == 22)
    }
  }

  @MainActor @Test func countdownFormatterFollowsTheLanguage() {
    #expect(RelativeDateTimeFormatter.countdown(for: .zhHant).locale.identifier == "zh-Hant")
    #expect(RelativeDateTimeFormatter.countdown(for: .en).locale.identifier != "zh-Hant")
  }

  // MARK: Private

  private func localNoon(_ year: Int, _ month: Int, _ day: Int) throws -> Date {
    let components = DateComponents(year: year, month: month, day: day, hour: 12)
    return try #require(Calendar.current.date(from: components))
  }
}
