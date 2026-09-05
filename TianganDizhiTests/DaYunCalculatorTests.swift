import ChineseAstrologyCalendar
import Foundation
import Testing
@testable import TianganDizhi

/// Regression tests for the 起運 age bug: the original code measured days to
/// the nearest of all 24 節氣, when the traditional rule counts only the 12
/// 節 (month-boundary terms). Using every term roughly halves the interval
/// and understates `startAge`.
///
/// Fixture values were computed by walking the package's own
/// `isJieqiDay`/`jieqi` day-by-day — the same primitives `DaYunCalculator`
/// uses — so they mirror production logic exactly. Each one is marked below
/// with whether it actually distinguishes the fix from the pre-fix behavior
/// (a few birth dates land within a day of both a 節 and a 氣, where the two
/// approaches coincide).
///
/// `Bazi(date:)` always reads its input as a GMT+8 wall clock, and
/// `DaYunCalculator`'s day-walk is pinned to GMT+8 to match — so fixtures
/// are built with an explicit GMT+8 calendar here too. Building them with an
/// *ambient*-timezone calendar (`Calendar(identifier: .gregorian)` with no
/// explicit `timeZone`) made this file pass on a CEST dev machine but fail
/// on a US/Pacific CI runner: the same wall-clock numbers resolve to a
/// different absolute instant per timezone, occasionally crossing a 節
/// boundary and shifting `ceil(days/3)` by one.
@Suite struct DaYunCalculatorTests {

  private static var gmt8: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
    return cal
  }

  @Test func forwardMaleDiscriminating() throws {
    // 1988-11-20 22h GMT+8: nian stem 戊 (yang) + male → 順. Next 節 (大雪) is
    // 17 days out; the nearest of all 24 terms (小雪, a 氣) is only 2 days out
    // — so this catches the 12-vs-24 bug directly (would give startAge 1, not 6).
    let date = try #require(Self.gmt8.date(from: DateComponents(year: 1988, month: 11, day: 20, hour: 22)))
    let result = try #require(DaYunCalculator.calculate(birthDate: date, isMale: true))
    #expect(result.startAge == 6)
  }

  @Test func reverseFemaleDiscriminating() throws {
    // 2000-06-01 10h GMT+8: nian stem 庚 (yang) + female → 逆. Previous 節
    // (立夏) is 26 days back; the nearest of all 24 terms (小滿, a 氣) is only
    // 11 days back — startAge would be 4, not 9, under the old logic.
    let date = try #require(Self.gmt8.date(from: DateComponents(year: 2000, month: 6, day: 1, hour: 10)))
    let result = try #require(DaYunCalculator.calculate(birthDate: date, isMale: false))
    #expect(result.startAge == 9)
  }

  @Test func forwardFemaleDiscriminating() throws {
    // 1995-03-15 8h GMT+8: nian stem 乙 (yin) + female → 順. Next 節 (清明) is
    // 22 days out; the nearest of all 24 terms (春分, a 氣) is only 7 days out
    // — startAge would be 3, not 8, under the old logic.
    let date = try #require(Self.gmt8.date(from: DateComponents(year: 1995, month: 3, day: 15, hour: 8)))
    let result = try #require(DaYunCalculator.calculate(birthDate: date, isMale: false))
    #expect(result.startAge == 8)
  }

  @Test func eightCyclesStepInTheDeclaredDirection() throws {
    let date = try #require(Self.gmt8.date(from: DateComponents(year: 1988, month: 11, day: 20, hour: 22)))
    let result = try #require(DaYunCalculator.calculate(birthDate: date, isMale: true))
    #expect(result.cycles.count == 8)
    // ages are startAge, startAge+10, ... in order
    for (index, cycle) in result.cycles.enumerated() {
      #expect(cycle.startAge == result.startAge + index * 10)
      #expect(cycle.endAge == cycle.startAge + 9)
    }
  }
}
