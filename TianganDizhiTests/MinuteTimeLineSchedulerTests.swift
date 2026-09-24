import Foundation
import Testing
@testable import TianganDizhi

struct MinuteTimeLineSchedulerTests {

  private static func date(_ hour: Int, _ minute: Int, _ second: Int = 0) -> Date {
    Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 24, hour: hour, minute: minute, second: second))!
  }

  @Test("Starts with now, then 48 quarter-hour boundaries")
  func startsWithNowThenBoundaries() {
    let now = Self.date(12, 7, 30)
    let timeline = MinuteTimeLineScheduler.buildTimeLine(now: now)

    #expect(timeline.count == 49)
    #expect(timeline.first == now)
    #expect(timeline[1] == Self.date(12, 15), "the next entry is the next 刻 boundary, not now + 15 min")
    #expect(timeline.last == Self.date(0, 0).addingTimeInterval(24 * 3600), "12 boundaries per 3h → last is midnight")
  }

  @Test("Boundary entries fall on :00/:15/:30/:45 and are 15 minutes apart")
  func boundariesAreQuarterHours() {
    let timeline = MinuteTimeLineScheduler.buildTimeLine(now: Self.date(22, 59, 59))
    for entry in timeline.dropFirst() {
      let parts = Calendar.current.dateComponents([.minute, .second, .nanosecond], from: entry)
      #expect([0, 15, 30, 45].contains(parts.minute ?? -1))
      #expect(parts.second == 0)
    }
    for (a, b) in zip(timeline.dropFirst(), timeline.dropFirst(2)) {
      #expect(b.timeIntervalSince(a) == 15 * 60)
    }
    #expect(timeline[1] == Self.date(23, 0), "a 時辰 change (子時 at 23:00) gets an entry exactly on time")
  }

  @Test("Strictly increasing, including when now is exactly on a boundary")
  func strictlyIncreasing() {
    for now in [Self.date(12, 15), Self.date(12, 7, 30), Date()] {
      let timeline = MinuteTimeLineScheduler.buildTimeLine(now: now)
      for (a, b) in zip(timeline, timeline.dropFirst()) {
        #expect(b > a, "WidgetKit requires strictly increasing entry dates")
      }
    }
  }
}
