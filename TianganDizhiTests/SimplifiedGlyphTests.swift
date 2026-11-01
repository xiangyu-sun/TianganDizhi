//
//  SimplifiedGlyphTests.swift
//  TianganDizhiTests
//
//  Chinese terms the app shows from its libraries are Simplified for
//  Simplified Chinese and exactly today's Traditional text for every other
//  language. The simulator runs in English, so the language-parameterized
//  helpers are exercised directly.
//

import Bagua
import ChineseAstrologyCalendar
import Foundation
import Testing
@testable import TianganDizhi

@Suite struct SimplifiedGlyphTests {

  // MARK: Internal

  // MARK: glyphLanguage and the script transform

  @Test func glyphLanguageIsSimplifiedOnlyForSimplifiedChinese() {
    #expect(DisplayLanguage.zhHans.glyphLanguage == .zhHans)
    #expect(DisplayLanguage.zhHant.glyphLanguage == .zhHant)
    #expect(DisplayLanguage.en.glyphLanguage == .zhHant)
    #expect(DisplayLanguage.ru.glyphLanguage == .zhHant)
  }

  @Test func convertedToSimplifiedChinese() {
    #expect("夜半".converted(to: .zhHans) == "夜半")
    #expect("日後臟腑".converted(to: .zhHans) == "日后脏腑")
    #expect("大腸".converted(to: .zhHans) == "大肠")
  }

  @Test(arguments: [DisplayLanguage.zhHant, .en, .ru, .es])
  func convertedLeavesOtherLanguagesAlone(_ language: DisplayLanguage) {
    #expect("日後臟腑 大腸".converted(to: language) == "日後臟腑 大腸")
  }

  // MARK: Lunar date, 節氣, months

  @Test func lunarDateWithZodiac() throws {
    // 2024-02-10 is 甲辰龍年正月初一.
    let date = try localNoon(2024, 2, 10)
    #expect(date.lunarDateWithZodiac(language: .zhHant) == "甲辰龍年正月初一")
    #expect(date.lunarDateWithZodiac(language: .zhHans) == "甲辰龙年正月初一")
    // Outside Chinese the date is English (see EnglishLocalizationTests).
    #expect(date.lunarDateWithZodiac(language: .en) == "1st Month 1st, Year of the Dragon (Jiǎchén)")
    #expect(date.lunarDateWithZodiac(language: .app) == date.lunarDateWithZodiac)
    #expect(date.lunarDateWithZodiacGTM8(language: .zhHans).contains("龙"))
  }

  @Test func lunarMonthAndDayNames() {
    #expect(RecurringDay.monthText(12, reckoning: .lunar, language: .zhHant) == "臘月")
    #expect(RecurringDay.monthText(12, reckoning: .lunar, language: .zhHans) == "腊月")
    #expect(RecurringDay.monthText(12, reckoning: .lunar, language: .en) == "12th Month")
    #expect(RecurringDay.dayText(1, reckoning: .lunar, language: .zhHans) == "初一")
    #expect(RecurringDay.dayText(23, reckoning: .lunar, language: .zhHant) == "廿三")
  }

  @Test func lunarMonthNamesMatchTheTraditionalLiterals() {
    let literals = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月"]
    for (index, literal) in literals.enumerated() {
      #expect(RecurringDay.monthText(index + 1, reckoning: .lunar, language: .zhHant) == literal)
    }
  }

  @Test func jieqiDisplayName() {
    let name = Jieqi.awakeningOfInsects
    #expect(name.displayName(language: .zhHant).hasPrefix("驚蟄"))
    #expect(name.displayName(language: .zhHans).hasPrefix("惊蛰"))
    #expect(name.displayName(language: .en) == "Awakening of Insects")
    #expect(name.displayName(language: .app) == name.displayName)
  }

  @Test func jieqiDisplayTextOnAndBeforeATermDay() throws {
    let seed = try localNoon(2026, 3, 1)
    let upcoming = try #require(seed.nextJieqiDayAligned)
    #expect(upcoming.jieqi == .awakeningOfInsects)
    let startDay = upcoming.startDate

    #expect(startDay.jieQiDisplayText(language: .zhHant).contains("驚蟄"))
    #expect(startDay.jieQiDisplayText(language: .zhHans).contains("惊蛰"))
    #expect(!startDay.jieQiDisplayText(language: .zhHans).contains("驚蟄"))
    #expect(startDay.jieQiDisplayText(language: .en) == "Awakening of Insects")
    #expect(startDay.jieQiDisplayText(language: .app) == startDay.jieQiDisplayText)

    let dayBefore = try #require(Calendar.current.date(byAdding: .day, value: -1, to: startDay))
    #expect(dayBefore.jieQiDisplayText(language: .zhHans).contains("惊蛰"))
    #expect(dayBefore.jieQiDisplayText(language: .zhHant).contains("驚蟄"))
  }

  // MARK: Names that must stay identical in Traditional Chinese

  @Test func traditionalNamesAreTheLibraryCanonicalStrings() {
    for jieqi in Jieqi.allCases {
      #expect(jieqi.localizedName(in: .zhHant) == jieqi.chineseName)
    }
    for festival in ChineseFestival.allCases {
      #expect(festival.localizedName(in: .zhHant) == festival.chineseName)
    }
    for god in TwelveGods.allCases {
      #expect(god.localizedName(in: .zhHant) == god.chinese)
    }
    for zodiac in Dizhi.allCases.map({ Zodiac($0) }) {
      #expect(zodiac.localizedName(in: .zhHant) == zodiac.rawValue)
    }
    for direction in FangWei.allCases {
      #expect(direction.localizedName(in: .zhHant) == direction.chineseCharacter)
    }
    for dizhi in Dizhi.allCases {
      #expect(dizhi.localizedHourName(in: .zhHant) == dizhi.displayHourText)
    }
    for mansion in LunarMansion.allCases {
      #expect(mansion.glyph(in: .zhHant) == mansion.rawValue)
      #expect(mansion.glyph(in: .en) == mansion.rawValue)
    }
    for hexagram in hexagramSymbols {
      #expect(hexagram.localizedName(in: .zhHant) == hexagram.chineseCharacter)
    }
    for hexagram in ShierPiguas {
      #expect(hexagram.localizedName(in: .zhHant) == hexagram.chineseCharacter)
    }
  }

  @Test func simplifiedNames() {
    #expect(Zodiac.dragon.localizedName(in: .zhHans) == "龙")
    #expect(FangWei.east.localizedName(in: .zhHans) == "东")
    #expect(Dizhi.zi.localizedHourName(in: .zhHans) == "子时")
    #expect(LunarMansion.emptiness.glyph(in: .zhHans) == "虚")
    #expect(LunarMansion.emptiness.glyph(in: .zhHant) == "虛")
    #expect(TwelveGods.opening.localizedName(in: .zhHans) == "开")
    #expect(Jieqi.grainRain.localizedName(in: .zhHans) == "谷雨")
  }

  // MARK: Moon phase

  @Test func moonPhaseNames() {
    for phase in ChineseMoonPhase.allCases {
      for traditional in [true, false] {
        let original = traditional ? phase.acientChineseName(.day8) : phase.modernChineseName(.day8)
        #expect(phase.name(traditionnal: traditional) == phase.name(traditionnal: traditional, language: .app))
        #expect(phase.name(traditionnal: traditional, language: .zhHant) == original)
        // The classical name stays Chinese; the modern one is English outside Chinese.
        #expect(phase.name(traditionnal: traditional, language: .en) == (traditional ? original : phase.localizedName(in: .en)))
        #expect(phase.name(traditionnal: traditional, language: .zhHans) == original.converted(to: .zhHans))
      }
    }
    #expect(ChineseMoonPhase.fullMoon.name(traditionnal: false, language: .zhHans).contains("满"))
  }

  // MARK: Trigrams (the script transform would turn 乾 into 干)

  @Test func trigramDescriptions() {
    #expect(Trigram.qian.description(in: .zhHans) == "☰ (乾) – 天")
    #expect(Trigram.li.description(in: .zhHans) == "☲ (离) – 火")
    #expect(Trigram.xun.description(in: .zhHans) == "☴ (巽) – 风")
    #expect(Trigram.dui.description(in: .zhHans) == "☱ (兑) – 泽")
    for trigram in [Trigram.qian, .xun, .kan, .gen, .kun, .zhen, .li, .dui] {
      #expect(trigram.description(in: .zhHant) == trigram.description)
      #expect(trigram.description(in: .en) == "\(trigram.symbol) (\(trigram.localizedName(in: .en))) – \(trigram.localizedXiang(in: .en))")
    }
  }

  @Test func hexagramNames() {
    let great = HexagramSymbol.allCases.first { $0.localizedName(in: .zhHant) == "大壯" }
    #expect(great?.localizedName(in: .zhHans) == "大壮")
    let heaven = HexagramSymbol.allCases.first { $0.localizedName(in: .zhHant) == "乾" }
    #expect(heaven?.localizedName(in: .zhHans) == "乾")
  }

  // MARK: Meridians

  @Test func meridianNames() {
    for dizhi in Dizhi.allCases {
      let meridian = dizhi.luizhu
      #expect(meridian.displayName(in: .zhHant) == meridian.rawValue)
      #expect(meridian.displayName(in: .en) == meridian.rawValue)
      let simplified = meridian.displayName(in: .zhHans)
      for traditional in ["經", "腸", "膽", "腎", "陰", "陽"] {
        #expect(!simplified.contains(traditional), "\(simplified) still has \(traditional)")
      }
    }
  }

  // MARK: Special days

  @Test func specialDaySourcesFollowTheLanguage() throws {
    let seed = try localNoon(2026, 3, 1)
    let jieqiName = { (language: DisplayLanguage) -> SpecialDay? in
      SpecialDayCatalog
        .sources(customHolidays: [], timeZone: .chinaStandardTime, language: language)
        .last?
        .nextSpecialDay(after: seed)
    }
    let traditional = try #require(jieqiName(.zhHant))
    #expect(traditional.name == "驚蟄")
    #expect(traditional.category == "節氣")

    let simplified = try #require(jieqiName(.zhHans))
    #expect(simplified.name == "惊蛰")
    #expect(simplified.category == "节气")
    #expect(!simplified.detail.contains("養"))

    let english = try #require(jieqiName(.en))
    #expect(english.name == "Awakening of Insects")
    #expect(english.detail == traditional.detail)
  }

  @Test func festivalNamesFollowTheLanguage() throws {
    let source = { (language: DisplayLanguage) in
      SpecialDayCatalog.sources(customHolidays: [], timeZone: .chinaStandardTime, language: language)[1]
    }
    // 2026-02-17 is Chinese New Year.
    let newYear = try localNoon(2026, 2, 17)
    let traditional = try #require(source(.zhHant).nextSpecialDay(after: newYear.addingTimeInterval(-86_400 * 3)))
    let simplified = try #require(source(.zhHans).nextSpecialDay(after: newYear.addingTimeInterval(-86_400 * 3)))
    #expect(traditional.name == ChineseFestival.springFestival.chineseName)
    #expect(simplified.name == ChineseFestival.springFestival.localizedName(in: .zhHans))
    #expect(simplified.category == "节日")
    #expect(traditional.category == "節日")
  }

  // MARK: Fonts

  @Test func weibeiFontFollowsTheAppLanguage() {
    // The test host runs in English, so the Traditional face is chosen.
    #expect(WeibeiFont.postScriptName == "WeibeiTC-Bold")
    #expect(WeibeiFont.fontName == "Weibei TC Bold")
  }

  // MARK: Private

  private func localNoon(_ year: Int, _ month: Int, _ day: Int) throws -> Date {
    let components = DateComponents(year: year, month: month, day: day, hour: 12)
    return try #require(Calendar.current.date(from: components))
  }
}
