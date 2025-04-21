import ChineseAstrologyCalendar
import Foundation

enum MinuteTimeLineScheduler {
  static func buildTimeLine() -> [Date] {
    var timeline = [Date]()
    let currentDate = Date()

    for minuteOffset in 0 ... 4 * 12 {
      let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 15, to: currentDate) ?? Date()
      timeline.append(entryDate)
    }
    return timeline
  }
}
