import Testing
import Foundation
@testable import TianganDizhi

struct MinuteTimeLineSchedulerTests {

  @Test("Timeline contains correct number of entries")
  func timelineContainsCorrectNumberOfEntries() {
    let timeline = MinuteTimeLineScheduler.buildTimeLine()

    // 0...48 = 49 entries
    #expect(timeline.count == 49)
  }

  @Test("First entry is approximately current time")
  func firstEntryIsApproximatelyCurrentTime() {
    let beforeCall = Date()
    let timeline = MinuteTimeLineScheduler.buildTimeLine()
    let afterCall = Date()

    guard let firstEntry = timeline.first else {
      Issue.record("Timeline should have at least one entry")
      return
    }

    // First entry should be within a few seconds of current time
    let timeDifference = abs(firstEntry.timeIntervalSince(beforeCall))
    #expect(timeDifference < 2.0, "First entry should be within 2 seconds of current time")

    // Also verify it's between before and after the call
    #expect(firstEntry >= beforeCall)
    #expect(firstEntry <= afterCall)
  }

  @Test("Entries are spaced 15 minutes apart")
  func entriesAreSpaced15MinutesApart() {
    let timeline = MinuteTimeLineScheduler.buildTimeLine()

    // Check spacing between consecutive entries
    for i in 0..<(timeline.count - 1) {
      let currentEntry = timeline[i]
      let nextEntry = timeline[i + 1]

      let interval = nextEntry.timeIntervalSince(currentEntry)
      let expectedInterval: TimeInterval = 15 * 60 // 15 minutes in seconds

      // Allow small floating point differences
      #expect(abs(interval - expectedInterval) < 0.1,
              "Entry \(i) to \(i+1) should be 15 minutes apart")
    }
  }

  @Test("Total timeline spans 12 hours")
  func totalTimelineSpans12Hours() {
    let timeline = MinuteTimeLineScheduler.buildTimeLine()

    guard let firstEntry = timeline.first,
          let lastEntry = timeline.last else {
      Issue.record("Timeline should have first and last entries")
      return
    }

    let totalInterval = lastEntry.timeIntervalSince(firstEntry)

    // 48 intervals * 15 minutes = 720 minutes = 12 hours
    let expectedInterval: TimeInterval = 48 * 15 * 60 // 12 hours in seconds

    // Allow small floating point differences
    #expect(abs(totalInterval - expectedInterval) < 1.0,
            "Timeline should span 12 hours (720 minutes)")
  }

  @Test("All entries have valid dates")
  func allEntriesHaveValidDates() {
    let timeline = MinuteTimeLineScheduler.buildTimeLine()

    // All entries should be valid dates (not fallback nil values)
    // We can verify this by checking they're all reasonable dates
    let referenceDate = Date()
    let calendar = Calendar.current

    for (index, entry) in timeline.enumerated() {
      // Each entry should be within a reasonable range (not a distant past date indicating nil fallback)
      let difference = entry.timeIntervalSince(referenceDate)

      // Should be between now and 13 hours from now (allowing some buffer)
      #expect(difference >= -5.0, "Entry \(index) should not be in the past")
      #expect(difference <= 13 * 60 * 60, "Entry \(index) should not be more than 13 hours in future")

      // Verify it's a valid date by checking we can get components
      let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: entry)
      #expect(components.year != nil, "Entry \(index) should have valid year component")
      #expect(components.month != nil, "Entry \(index) should have valid month component")
    }
  }

  @Test("Entries are in chronological order")
  func entriesAreInChronologicalOrder() {
    let timeline = MinuteTimeLineScheduler.buildTimeLine()

    // Verify each entry is later than the previous one
    for i in 0..<(timeline.count - 1) {
      let currentEntry = timeline[i]
      let nextEntry = timeline[i + 1]

      #expect(nextEntry > currentEntry,
              "Entry \(i+1) should be later than entry \(i)")
    }
  }

  @Test("Timeline entries increment by correct minute offsets")
  func timelineEntriesIncrementByCorrectMinuteOffsets() {
    let timeline = MinuteTimeLineScheduler.buildTimeLine()

    guard let firstEntry = timeline.first else {
      Issue.record("Timeline should have at least one entry")
      return
    }

    let calendar = Calendar.current

    // Verify each entry is at the expected offset from the first entry
    for (index, entry) in timeline.enumerated() {
      let expectedMinuteOffset = index * 15

      if let expectedDate = calendar.date(byAdding: .minute, value: expectedMinuteOffset, to: firstEntry) {
        let difference = abs(entry.timeIntervalSince(expectedDate))

        #expect(difference < 0.1,
                "Entry \(index) should be \(expectedMinuteOffset) minutes from first entry")
      }
    }
  }
}
