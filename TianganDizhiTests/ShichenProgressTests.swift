//
//  ShichenProgressTests.swift
//  TianganDizhiTests
//

import ChineseAstrologyCalendar
import Foundation
import Testing
@testable import TianganDizhi

@Suite struct ShichenProgressTests {

  // 2023-06-15 09:07:30 local — 7.5 minutes into Si hour (巳時, 09:00–11:00), ke 0
  // ke 0 spans 09:00–09:15, so 7.5 min in = 50% through ke 0
  private func makeDateAt(hour: Int, minute: Int, second: Int = 0) -> Date {
    var c = DateComponents()
    c.year = 2023
    c.month = 6
    c.day = 15
    c.hour = hour
    c.minute = minute
    c.second = second
    return Calendar.current.date(from: c)!
  }

  @Test func keProgressAtStartOfKe() {
    // Exactly at start of ke 0 (09:00:00) → progress ~0.0
    let date = makeDateAt(hour: 9, minute: 0, second: 0)
    #expect(date.keProgress < 0.05)
  }

  @Test func keProgressAtMidpointOfKe() {
    // 7.5 min into Si hour → 50% through ke 0
    let date = makeDateAt(hour: 9, minute: 7, second: 30)
    let progress = date.keProgress
    #expect(progress > 0.45 && progress < 0.55)
  }

  @Test func keProgressAtEndOfKe() {
    // 14 min 59 s into Si hour → near end of ke 0
    let date = makeDateAt(hour: 9, minute: 14, second: 59)
    #expect(date.keProgress > 0.95)
  }

  @Test func keProgressNeverOutOfBounds() {
    // Test a few points across one full Shichen
    let startDate = makeDateAt(hour: 9, minute: 0)
    for offsetMin in stride(from: 0, through: 119, by: 7) {
      let date = startDate.addingTimeInterval(TimeInterval(offsetMin * 60))
      let p = date.keProgress
      #expect(p >= 0.0 && p <= 1.0, "keProgress out of bounds at offset \(offsetMin) min")
    }
  }

  @Test func nextShichenTimeMatchesLibrary() {
    let date = makeDateAt(hour: 9, minute: 30)
    let fromExtension = date.nextShichenTime
    let fromLibrary = date.shichen?.nextStartDate

    #expect(fromLibrary != nil)
    if let libraryDate = fromLibrary {
      #expect(abs(fromExtension.timeIntervalSince(libraryDate)) < 1.0)
    }
  }

  @Test func nextShichenTimeIsInFuture() {
    let date = makeDateAt(hour: 9, minute: 30)
    #expect(date.nextShichenTime > date)
  }

  @Test func nextShichenCountdownIsNonEmpty() {
    let date = makeDateAt(hour: 9, minute: 30)
    #expect(!date.nextShichenCountdown.isEmpty)
  }

  @Test func nextShichenCountdownContainsNextDizhiCharacter() {
    // Si hour (09:00–11:00) → next is Wu (午)
    let date = makeDateAt(hour: 9, minute: 30)
    #expect(date.nextShichenCountdown.contains("午"))
  }

  @Test func nextShichenCountdownMinutesOnlyFormat() {
    // 58 minutes until next shichen → "XX 分鐘" format
    let date = makeDateAt(hour: 10, minute: 2)
    let text = date.nextShichenCountdown
    #expect(text.contains("分鐘"))
  }

  @Test func nextShichenCountdownHoursFormat() {
    // Just entered Si hour → ~2 hours remaining → hours format
    let date = makeDateAt(hour: 9, minute: 1)
    let text = date.nextShichenCountdown
    #expect(text.contains("小時"))
  }
}
