import ChineseAstrologyCalendar
import Foundation
import Testing
@testable import TianganDizhi

/// The 節日曆 screen and the 節氣與節日 widget both read ``SpecialDayCatalog``.
@Suite struct SpecialDayCatalogTests {

  private let losAngeles = TimeZone(identifier: "America/Los_Angeles")!

  private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, in timeZone: TimeZone) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
  }

  private func calendar(_ timeZone: TimeZone) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar
  }

  @Test func festivalDayShowsTodayNotTheNextEvent() {
    // 2027 春節 is February 6. The widget used to show 雨水 on the day itself.
    let day = date(2027, 2, 6, in: .chinaStandardTime)
    let result = day.currentOrNextSpecialDay(
      sources: SpecialDayCatalog.sources(customHolidays: [], timeZone: .chinaStandardTime),
      calendar: calendar(.chinaStandardTime)
    )
    #expect(result?.day.name == "春節")
    #expect(result?.daysUntil == 0)
  }

  @Test func customHolidayTakesPriorityOnSharedDay() {
    let birthday = CustomHoliday(day: RecurringDay(name: "生日", reckoning: .lunar, month: 1, day: 1))
    let day = date(2027, 2, 6, in: .chinaStandardTime)
    let result = day.currentOrNextSpecialDay(
      sources: SpecialDayCatalog.sources(customHolidays: [birthday], timeZone: .chinaStandardTime),
      calendar: calendar(.chinaStandardTime)
    )
    #expect(result?.day.name == "生日")
    #expect(result?.day.kind == .custom)
  }

  @Test func sourcesFollowTheirTimeZone() {
    // Every 2026 solar-term day the catalog reports must match the time zone
    // it was built for — the 東八區 setting chooses that zone.
    for tz in [TimeZone.chinaStandardTime, losAngeles] {
      let sources = SpecialDayCatalog.sources(customHolidays: [], timeZone: tz)
      let start = date(2026, 1, 1, in: tz)
      for event in start.upcomingSpecialDays(sources: sources, within: 364, calendar: calendar(tz)) where event.day.kind == .jieqi {
        #expect(event.day.date.isJieqiDay(in: tz))
      }
    }
  }

  @Test func upcomingListHasEveryKindAndNoDuplicates() {
    let holiday = CustomHoliday(day: RecurringDay(name: "紀念日", reckoning: .gregorian, month: 5, day: 1))
    let events = date(2026, 1, 1, in: .chinaStandardTime).upcomingSpecialDays(
      sources: SpecialDayCatalog.sources(customHolidays: [holiday], timeZone: .chinaStandardTime),
      within: 364,
      calendar: calendar(.chinaStandardTime)
    )
    #expect(Set(events.map(\.day.kind)) == [.festival, .jieqi, .custom])
    #expect(events.filter { $0.day.name == "冬至" }.count == 1)
    #expect(events.filter { $0.day.name == "紀念日" }.map(\.daysUntil) == [120])
  }

  @Test func customHolidaysOnDate() {
    let holiday = CustomHoliday(day: RecurringDay(name: "紀念日", reckoning: .gregorian, month: 5, day: 1))
    #expect(SpecialDayCatalog.customHolidays(on: date(2026, 5, 1, in: .chinaStandardTime), customHolidays: [holiday], timeZone: .chinaStandardTime).map(\.name) == ["紀念日"])
    #expect(SpecialDayCatalog.customHolidays(on: date(2026, 5, 2, in: .chinaStandardTime), customHolidays: [holiday], timeZone: .chinaStandardTime).isEmpty)
  }

  @Test func storeRoundTripsAndToleratesBadData() {
    let holidays = [CustomHoliday(day: RecurringDay(name: "媽媽生日", detail: "打電話", reckoning: .lunar, month: 8, day: 3))]
    #expect(CustomHolidayStore.decode(CustomHolidayStore.encode(holidays)) == holidays)
    #expect(CustomHolidayStore.decode(Data()).isEmpty)
    #expect(CustomHolidayStore.decode(Data("not json".utf8)).isEmpty)
  }

  @Test func displayText() {
    #expect(RecurringDay(name: "", reckoning: .lunar, month: 12, day: 23).dateText == "農曆臘月廿三")
    #expect(RecurringDay(name: "", reckoning: .gregorian, month: 5, day: 1).dateText == "公曆5月1日")
    #expect(0.daysUntilText == "今日")
    #expect(15.daysUntilText == "十五日後")
  }
}
