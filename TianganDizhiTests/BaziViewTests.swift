import Foundation
import Testing
@testable import TianganDizhi

/// `Bazi(date:)` always reads its input as a GMT+8 wall clock. When a user
/// outside China enters a birth time and says it happened in China, the app
/// must produce a `Date` that, when re-read at GMT+8, shows the *same*
/// wall-clock numbers the user typed — not a doubled, wrong-direction shift.
@Suite struct BaziViewTests {

  @Test func adjustsToSameWallClockAtChinaOffset() throws {
    let newYork = try #require(TimeZone(identifier: "America/New_York"))
    var nyCalendar = Calendar(identifier: .gregorian)
    nyCalendar.timeZone = newYork
    let birthDate = try #require(nyCalendar.date(from: DateComponents(year: 1990, month: 1, day: 1, hour: 12)))

    let adjusted = BaziView.adjustedForChinaTimezone(birthDate, useChinaTimezone: true, localTimeZone: newYork)

    var chinaCalendar = Calendar(identifier: .gregorian)
    chinaCalendar.timeZone = try #require(TimeZone(secondsFromGMT: 8 * 3600))
    let displayed = chinaCalendar.dateComponents([.year, .month, .day, .hour], from: adjusted)

    #expect(displayed.year == 1990)
    #expect(displayed.month == 1)
    #expect(displayed.day == 1, "Should stay on the same day, not roll over")
    #expect(displayed.hour == 12, "Should keep the same wall-clock hour the user typed")
  }

  @Test func noAdjustmentWhenToggleIsOff() {
    let date = Date()
    #expect(BaziView.adjustedForChinaTimezone(date, useChinaTimezone: false) == date)
  }

  @Test func noOpWhenLocalTimeZoneIsAlreadyChina() throws {
    let china = try #require(TimeZone(identifier: "Asia/Shanghai"))
    let birthDate = Date()
    let adjusted = BaziView.adjustedForChinaTimezone(birthDate, useChinaTimezone: true, localTimeZone: china)
    #expect(abs(adjusted.timeIntervalSince(birthDate)) < 1)
  }
}
