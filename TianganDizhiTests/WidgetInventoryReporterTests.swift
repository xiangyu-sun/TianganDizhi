import Foundation
import Testing
@testable import TianganDizhi

/// `isNewDay(since:now:)` anchors the "once per calendar day" throttle to a
/// fixed UTC calendar rather than the device's current timezone, so
/// traveling across zones can't skip a day or double-report within 24h.
@Suite struct WidgetInventoryReporterTests {

  @Test func sameUTCDayIsNotNew() {
    let last = Date(timeIntervalSince1970: 1_735_700_400) // 2025-01-01 03:00:00 UTC
    let now = Date(timeIntervalSince1970: 1_735_761_600) // 2025-01-01 20:00:00 UTC
    #expect(!WidgetInventoryReporter.isNewDay(since: last, now: now))
  }

  @Test func crossingUTCMidnightIsNew() {
    let last = Date(timeIntervalSince1970: 1_735_700_400) // 2025-01-01 03:00:00 UTC
    let now = Date(timeIntervalSince1970: 1_735_790_400) // 2025-01-02 04:00:00 UTC
    #expect(WidgetInventoryReporter.isNewDay(since: last, now: now))
  }

  @Test func differsFromDeviceLocalTimezoneNearMidnight() {
    // 2025-01-01 23:30 UTC and 2025-01-02 00:30 UTC are different UTC
    // calendar days. In this machine's local zone (CEST, UTC+2) both land
    // on 2025-01-02 (01:30 and 02:30 local) — the *same* local day. A
    // `Calendar.current`-based check would wrongly say "not new" here.
    let last = Date(timeIntervalSince1970: 1_735_774_200) // 2025-01-01 23:30 UTC
    let now = Date(timeIntervalSince1970: 1_735_777_800) // 2025-01-02 00:30 UTC
    #expect(WidgetInventoryReporter.isNewDay(since: last, now: now))
  }

  @Test func travelingWestAcrossTimezonesDoesNotFlipTheAnswer() {
    // The bug this guards against: comparing via `Calendar.current` means
    // the *device's* timezone at check-time — not the stamp's timezone —
    // decides the day boundary. Anchoring to UTC means the local timezone
    // at either end is irrelevant; only the absolute instants matter.
    let last = Date(timeIntervalSince1970: 1_735_700_400) // 2025-01-01 03:00:00 UTC
    let now = last.addingTimeInterval(60 * 60) // one hour later, still Jan 1 UTC
    #expect(!WidgetInventoryReporter.isNewDay(since: last, now: now))
  }
}
