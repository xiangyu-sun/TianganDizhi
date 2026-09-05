import Foundation
import Testing
@testable import TianganDizhi

/// Regression tests for `isSameShichen(as:)`: the widget-reload matching in
/// `MainView.refreshLocationAndWeather` compared full `DateComponents`
/// (era…nanosecond) between a widget's configured date and "now" — two
/// values that, at nanosecond precision, could essentially never be equal.
/// `validWidgets` was always empty, so a weather refresh never reached any
/// widget's timeline.
@Suite struct DateWidgetIntentTests {

  private static func components(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ min: Int = 0) -> DateComponents {
    DateComponents(calendar: Calendar(identifier: .gregorian), year: y, month: m, day: d, hour: h, minute: min)
  }

  @Test func sameDayAndShichenMatches() {
    // Both fall in 午時 (11:00–12:59) on the same day, at different minutes —
    // exactly the case the nanosecond-precision equality check would miss.
    let configured = Self.components(2026, 6, 9, 11, 5)
    let now = Calendar(identifier: .gregorian).date(from: Self.components(2026, 6, 9, 11, 47))!
    #expect(configured.isSameShichen(as: now))
  }

  @Test func sameHourDifferentDayDoesNotMatch() {
    let configured = Self.components(2026, 6, 8, 11, 5)
    let now = Calendar(identifier: .gregorian).date(from: Self.components(2026, 6, 9, 11, 5))!
    #expect(!configured.isSameShichen(as: now))
  }

  @Test func sameDayDifferentShichenDoesNotMatch() {
    // 午時 (11:00) vs 子時 (23:00) — same calendar day, different shichen.
    let configured = Self.components(2026, 6, 9, 11, 0)
    let now = Calendar(identifier: .gregorian).date(from: Self.components(2026, 6, 9, 23, 0))!
    #expect(!configured.isSameShichen(as: now))
  }

  @Test func exactNanosecondMismatchStillMatchesWithinSameShichen() {
    // Regression for the literal bug: two DateComponents that are NOT ==
    // (different minute/second) but fall in the same shichen must match.
    let configured = Self.components(2026, 6, 9, 11, 0)
    let now = Calendar(identifier: .gregorian).date(from: Self.components(2026, 6, 9, 12, 59))!
    #expect(configured != Calendar.current.dateComponents(in: .current, from: now), "sanity: components genuinely differ")
    #expect(configured.isSameShichen(as: now))
  }
}
